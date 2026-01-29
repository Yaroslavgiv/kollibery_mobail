import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final roleController = TextEditingController(); // 'buyer' или 'seller'

  final AuthRepository _authRepository = AuthRepository();
  final box = GetStorage();

  // Добавляем флаг для отслеживания состояния загрузки
  final RxBool isLoading = false.obs;

  /// Регистрация пользователя
  Future<void> register() async {
    if (isLoading.value) return; // Предотвращаем множественные запросы

    isLoading.value = true;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final role =
        roleController.text.trim(); // 'buyer' | 'seller' | 'technician'

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        role.isEmpty) {
      isLoading.value = false;
      return;
    }

    if (role != 'buyer' && role != 'seller' && role != 'technician') {
      isLoading.value = false;
      return;
    }

    if (password != confirmPassword) {
      isLoading.value = false;
      return;
    }

    final phone = phoneController.text.trim();

    try {
      await _authRepository.register(
          firstName, lastName, email, password, confirmPassword, role, phone);

      // Сохраняем данные профиля в локальное хранилище
      box.write('userProfile', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'deliveryPoint': '',
        'profileImage': '',
      });

      // Отладочная информация для проверки сохранения
      print('✅ Данные профиля сохранены при регистрации:');
      print('   - firstName: $firstName');
      print('   - lastName: $lastName');
      print('   - email: $email');

      // Автоматически входим в систему после регистрации
      await autoLoginAfterRegistration(email, password);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Автоматический вход после регистрации
  Future<void> autoLoginAfterRegistration(String email, String password) async {
    try {
      final userData = await _authRepository.login(email, password);

      // Отладочная информация
      print('📥 Ответ сервера при автологине после регистрации:');
      print('   - Ключи в ответе: ${userData.keys.toList()}');
      print('   - userData: $userData');

      // Сохраняем данные пользователя
      box.write('loggedIn', true);
      box.write('email', email);

      // Сохраняем userId, если он есть в ответе
      if (userData['userId'] != null) {
        print('✅ userId найден в ответе: ${userData['userId']}');
        _saveUserIdIfGuid(userData['userId']);
      } else if (userData['id'] != null) {
        print('✅ id найден в ответе: ${userData['id']}');
        _saveUserIdIfGuid(userData['id']);
      } else {
        print('⚠️ userId и id не найдены в ответе сервера');
        print('   - Проверяем другие возможные ключи...');
        // Пробуем найти userId в других возможных ключах
        for (var key in userData.keys) {
          if (key.toLowerCase().contains('user') ||
              key.toLowerCase().contains('id')) {
            print('   - Найден ключ $key: ${userData[key]}');
          }
        }
      }

      // Сохраняем токен и роль только из токена
      final token = userData['token']?.toString();
      if (token != null && token.isNotEmpty) {
        box.write('token', token);
        final roleFromToken = _extractRoleFromToken(token);
        if (roleFromToken != null) {
          box.write('role', roleFromToken);
        } else {
          box.remove('role');
        }
        final userIdFromToken = _extractUserIdFromToken(token);
        if (userIdFromToken != null) {
          _saveUserIdIfGuid(userIdFromToken);
        }
      }

      // Обновляем данные профиля, если сервер их возвращает
      // Важно: сохраняем данные из регистрации, если сервер их не вернул
      final existingProfile =
          box.read<Map<String, dynamic>>('userProfile') ?? {};

      // Получаем данные из ответа сервера или используем существующие данные из регистрации
      final serverFirstName = userData['firstName']?.toString().trim();
      final serverLastName = userData['lastName']?.toString().trim();

      box.write('userProfile', {
        'firstName': serverFirstName ??
            existingProfile['firstName']?.toString().trim() ??
            '',
        'lastName': serverLastName ??
            existingProfile['lastName']?.toString().trim() ??
            '',
        'email': userData['email']?.toString().trim() ?? email,
        'phone': userData['phone']?.toString().trim() ??
            existingProfile['phone']?.toString().trim() ??
            '',
        'deliveryPoint': userData['deliveryPoint']?.toString().trim() ??
            existingProfile['deliveryPoint']?.toString().trim() ??
            '',
        'profileImage': userData['profileImage']?.toString().trim() ??
            existingProfile['profileImage']?.toString().trim() ??
            '',
      });

      // Дополнительно подтягиваем имя из /account/user (или /account/username)
      try {
        await _resolveProfileFromServer(email);
      } catch (e) {
        // Не прерываем автологин, если эндпоинт недоступен
        print('Не удалось получить имя с сервера: $e');
      }

      // Убеждаемся, что данные профиля сохранены
      print('✅ Данные профиля сохранены после автологина:');
      print(
          '   - firstName: ${box.read<Map<String, dynamic>>('userProfile')?['firstName']}');
      print(
          '   - lastName: ${box.read<Map<String, dynamic>>('userProfile')?['lastName']}');
      print(
          '   - email: ${box.read<Map<String, dynamic>>('userProfile')?['email']}');

      // Перенаправляем согласно роли из токена
      final roleFromToken = box.read('role');
      if (roleFromToken == 'seller') {
        Get.offAllNamed(AppRoutes.sellerHome);
      } else if (roleFromToken == 'technician') {
        Get.offAllNamed(AppRoutes.techHome);
      } else if (roleFromToken == 'buyer') {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      // Если автоматический вход не удался, перенаправляем на экран входа
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Авторизация
  Future<void> login() async {
    if (isLoading.value) return; // Предотвращаем множественные запросы

    isLoading.value = true;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      final userData = await _authRepository.login(email, password);

      // Отладочная информация
      print('📥 Ответ сервера при логине:');
      print('   - Ключи в ответе: ${userData.keys.toList()}');
      print('   - userData: $userData');

      // Сохраняем данные пользователя
      box.write('loggedIn', true);
      box.write('email', email);

      // Сохраняем userId, если он есть в ответе
      if (userData['userId'] != null) {
        print('✅ userId найден в ответе: ${userData['userId']}');
        _saveUserIdIfGuid(userData['userId']);
      } else if (userData['id'] != null) {
        print('✅ id найден в ответе: ${userData['id']}');
        _saveUserIdIfGuid(userData['id']);
      } else {
        print('⚠️ userId и id не найдены в ответе сервера');
        print('   - Проверяем другие возможные ключи...');
        // Пробуем найти userId в других возможных ключах
        for (var key in userData.keys) {
          if (key.toLowerCase().contains('user') ||
              key.toLowerCase().contains('id')) {
            print('   - Найден ключ $key: ${userData[key]}');
          }
        }
      }

      // Сохраняем токен и роль только из токена
      final token = userData['token']?.toString();
      if (token != null && token.isNotEmpty) {
        box.write('token', token);
        final roleFromToken = _extractRoleFromToken(token);
        if (roleFromToken != null) {
          box.write('role', roleFromToken);
        } else {
          box.remove('role');
        }
        final userIdFromToken = _extractUserIdFromToken(token);
        if (userIdFromToken != null) {
          _saveUserIdIfGuid(userIdFromToken);
        }
      } else {
        box.remove('role');
      }

      // Сохраняем или обновляем данные профиля из ответа сервера
      // Важно: сохраняем существующие данные, если сервер их не вернул
      final existingProfile =
          box.read<Map<String, dynamic>>('userProfile') ?? {};
      box.write('userProfile', {
        'firstName': userData['firstName']?.toString().trim() ??
            existingProfile['firstName']?.toString().trim() ??
            '',
        'lastName': userData['lastName']?.toString().trim() ??
            existingProfile['lastName']?.toString().trim() ??
            '',
        'email': userData['email']?.toString().trim() ?? email,
        'phone': userData['phone']?.toString().trim() ??
            existingProfile['phone']?.toString().trim() ??
            '',
        'deliveryPoint': userData['deliveryPoint']?.toString().trim() ??
            existingProfile['deliveryPoint']?.toString().trim() ??
            '',
        'profileImage': userData['profileImage']?.toString().trim() ??
            existingProfile['profileImage']?.toString().trim() ??
            '',
      });

      // Дополнительно подтягиваем имя из /account/user (или /account/username)
      try {
        await _resolveProfileFromServer(email);
      } catch (e) {
        // Не прерываем логин, если эндпоинт недоступен
        print('Не удалось получить имя с сервера: $e');
      }

      // Отладочная информация для проверки сохранения
      print('✅ Данные профиля сохранены после логина:');
      print(
          '   - firstName: ${box.read<Map<String, dynamic>>('userProfile')?['firstName']}');
      print(
          '   - lastName: ${box.read<Map<String, dynamic>>('userProfile')?['lastName']}');
      print(
          '   - email: ${box.read<Map<String, dynamic>>('userProfile')?['email']}');

      // Перенаправляем согласно роли из токена
      final userRole = box.read('role');
      if (userRole == 'seller') {
        Get.offAllNamed(AppRoutes.sellerHome);
      } else if (userRole == 'technician') {
        Get.offAllNamed(AppRoutes.techHome);
      } else if (userRole == 'buyer') {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Получить токен авторизации
  String? getToken() {
    return box.read('token');
  }

  String? _extractRoleFromToken(String token) {
    final payloadMap = _decodeTokenPayload(token);
    if (payloadMap == null) {
      return null;
    }

    final possibleKeys = [
      'role',
      'roles',
      'userRole',
      'roleName',
      'Role',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/roles',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role-name',
    ];

    final roleValue = _extractFirstMatchingClaim(payloadMap, possibleKeys);
    if (roleValue == null) {
      return null;
    }

    if (roleValue is String) {
      return roleValue;
    }
    if (roleValue is List && roleValue.isNotEmpty) {
      return roleValue.first.toString();
    }
    return roleValue.toString();
  }

  String? _extractUserIdFromToken(String token) {
    final payloadMap = _decodeTokenPayload(token);
    if (payloadMap == null) {
      return null;
    }

    final possibleKeys = [
      'userId',
      'sub',
      'id',
      'nameid',
      'unique_name',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
    ];

    final userIdValue = _extractFirstMatchingClaim(payloadMap, possibleKeys);
    return userIdValue?.toString();
  }

  Map<String, dynamic>? _decodeTokenPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = parts[1];
    String normalizedPayload = payload;
    switch (payload.length % 4) {
      case 1:
        normalizedPayload += '===';
        break;
      case 2:
        normalizedPayload += '==';
        break;
      case 3:
        normalizedPayload += '=';
        break;
    }

    try {
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Ошибка декодирования токена: $e');
      return null;
    }
  }

  dynamic _extractFirstMatchingClaim(
      Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      if (payload.containsKey(key)) {
        return payload[key];
      }
    }
    return null;
  }

  /// Получить email пользователя
  String? getEmail() {
    return box.read('email');
  }

  bool _isGuid(String value) {
    final guidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return guidRegex.hasMatch(value);
  }

  void _saveUserIdIfGuid(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) {
      return;
    }
    if (_isGuid(text)) {
      box.write('userId', text);
    } else {
      print('⚠️ userId не GUID ($text), очищаем неверное значение');
      box.remove('userId');
    }
  }

  Future<void> _resolveProfileFromServer(String email) async {
    final userId = box.read<String>('userId');
    if (userId != null && userId.isNotEmpty && _isGuid(userId)) {
      final accountUser = await _authRepository.getAccountUser(userId);
      if (accountUser.isNotEmpty) {
        _mergeProfileNameFromAccountUser(accountUser, email);
        _saveUserIdIfGuid(accountUser['userId'] ?? accountUser['id']);
      }
      return;
    }

    final value = userId ?? '';
    print(
        '⚠️ userId отсутствует или не GUID ($value), вызываем /account/username');
    final accountUser = await _authRepository.getAccountUserByUsername(email);
    if (accountUser.isNotEmpty) {
      _mergeProfileNameFromAccountUser(accountUser, email);
      _saveUserIdIfGuid(accountUser['userId'] ?? accountUser['id']);

      final resolvedId = box.read<String>('userId');
      if (resolvedId != null && resolvedId.isNotEmpty && _isGuid(resolvedId)) {
        final fullUser = await _authRepository.getAccountUser(resolvedId);
        if (fullUser.isNotEmpty) {
          _mergeProfileNameFromAccountUser(fullUser, email);
          _saveUserIdIfGuid(fullUser['userId'] ?? fullUser['id']);
        }
      } else {
        print('⚠️ userId не получен после /account/username');
      }
    }
  }

  void _mergeProfileNameFromAccountUser(
      Map<String, dynamic> data, String fallbackEmail) {
    final existingProfile = box.read<Map<String, dynamic>>('userProfile') ?? {};
    final rawName = _extractFullName(data);
    final rawFirstName = _extractString(data, ['firstName', 'givenName']);
    final rawLastName =
        _extractString(data, ['lastName', 'surname', 'surName', 'familyName']);

    String firstName = existingProfile['firstName']?.toString().trim() ?? '';
    String lastName = existingProfile['lastName']?.toString().trim() ?? '';

    if ((rawFirstName != null && rawFirstName.isNotEmpty) ||
        (rawLastName != null && rawLastName.isNotEmpty)) {
      if (rawFirstName != null && rawFirstName.isNotEmpty) {
        firstName = rawFirstName;
      }
      if (rawLastName != null && rawLastName.isNotEmpty) {
        lastName = rawLastName;
      }
    } else if (rawName != null && rawName.isNotEmpty) {
      final parts = rawName.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        firstName = parts.first;
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    box.write('userProfile', {
      'firstName': firstName,
      'lastName': lastName,
      'email': existingProfile['email']?.toString().trim() ?? fallbackEmail,
      'phone': existingProfile['phone']?.toString().trim() ?? '',
      'deliveryPoint':
          existingProfile['deliveryPoint']?.toString().trim() ?? '',
      'profileImage': existingProfile['profileImage']?.toString().trim() ?? '',
    });
  }

  String? _extractFullName(Map<String, dynamic> data) {
    return _extractString(
        data, ['fullName', 'name', 'fio', 'displayName', 'userName']);
  }

  String? _extractString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }

  /// Сброс пароля — если ваше API это поддерживает
  Future<void> resetPassword() async {
    if (isLoading.value) return;

    isLoading.value = true;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      await _authRepository.forgotPassword(email);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Выход
  void logout() {
    box.remove('loggedIn');
    box.remove('token');
    box.remove('role');
    box.remove('email');
    box.remove('userId');
    // Очищаем данные профиля при выходе, чтобы следующий пользователь не видел чужие данные
    box.remove('userProfile');
    Get.offAllNamed(AppRoutes.login);
  }

  /// Получить понятное сообщение об ошибке
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('connection') || errorString.contains('network')) {
      return 'Проблема с подключением к серверу. Проверьте интернет-соединение.';
    } else if (errorString.contains('timeout')) {
      return 'Превышено время ожидания. Попробуйте еще раз.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Неверный email или пароль.';
    } else if (errorString.contains('404')) {
      return 'Сервер не найден. Обратитесь к администратору.';
    } else if (errorString.contains('500')) {
      return 'Ошибка сервера. Попробуйте позже.';
    } else {
      return 'Произошла ошибка. Попробуйте еще раз.';
    }
  }
}
