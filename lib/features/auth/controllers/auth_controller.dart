import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
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

    try {
      await _authRepository.register(
          firstName, lastName, email, password, confirmPassword, role);

      // Сохраняем роль пользователя
      box.write('role', role);
      // Привязываем роль к email для последующих логинов
      box.write('roleByEmail:$email', role);

      // Сохраняем данные профиля в локальное хранилище
      box.write('userProfile', {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': '', // Телефон можно добавить позже при редактировании профиля
        'deliveryPoint': '', // Точка доставки устанавливается позже
        'profileImage': '', // Фото профиля загружается позже
      });

      // Автоматически входим в систему после регистрации
      await autoLoginAfterRegistration(email, password, role);
    } catch (e) {
      Get.snackbar('Ошибка', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Автоматический вход после регистрации
  Future<void> autoLoginAfterRegistration(
String email, String password, String role) async {
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
        box.write('userId', userData['userId']);
      } else if (userData['id'] != null) {
        print('✅ id найден в ответе: ${userData['id']}');
        box.write('userId', userData['id']);
      } else {
        print('⚠️ userId и id не найдены в ответе сервера');
        print('   - Проверяем другие возможные ключи...');
        // Пробуем найти userId в других возможных ключах
        for (var key in userData.keys) {
          if (key.toLowerCase().contains('user') || key.toLowerCase().contains('id')) {
            print('   - Найден ключ $key: ${userData[key]}');
          }
        }
      }

      // Сохраняем токен, если он есть в ответе
      if (userData['token'] != null) {
        box.write('token', userData['token']);
      }

      // Обновляем данные профиля, если сервер их возвращает
      final existingProfile = box.read<Map<String, dynamic>>('userProfile') ?? {};
      box.write('userProfile', {
        'firstName': userData['firstName'] ?? existingProfile['firstName'] ?? '',
        'lastName': userData['lastName'] ?? existingProfile['lastName'] ?? '',
        'email': userData['email'] ?? email,
        'phone': userData['phone'] ?? existingProfile['phone'] ?? '',
        'deliveryPoint': userData['deliveryPoint'] ?? existingProfile['deliveryPoint'] ?? '',
        'profileImage': userData['profileImage'] ?? existingProfile['profileImage'] ?? '',
      });

      // Перенаправляем согласно роли
      if (role == 'seller') {
        Get.offAllNamed(AppRoutes.sellerHome);
      } else if (role == 'technician') {
        Get.offAllNamed(AppRoutes.techHome);
      } else {
        Get.offAllNamed(AppRoutes.home);
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
        box.write('userId', userData['userId']);
      } else if (userData['id'] != null) {
        print('✅ id найден в ответе: ${userData['id']}');
        box.write('userId', userData['id']);
      } else {
        print('⚠️ userId и id не найдены в ответе сервера');
        print('   - Проверяем другие возможные ключи...');
        // Пробуем найти userId в других возможных ключах
        for (var key in userData.keys) {
          if (key.toLowerCase().contains('user') || key.toLowerCase().contains('id')) {
            print('   - Найден ключ $key: ${userData[key]}');
          }
        }
      }

      // Сохраняем токен, если он есть в ответе
      if (userData['token'] != null) {
        box.write('token', userData['token']);
      }

      // Сохраняем роль, если она есть в ответе
      if (userData['role'] != null) {
        box.write('role', userData['role']);
        // Кэшируем соответствие email→role
        box.write('roleByEmail:$email', userData['role']);
      } else {
        // Если роль не пришла с сервера, пробуем взять из кэша по email
        final cachedRoleByEmail = box.read('roleByEmail:$email');
        if (cachedRoleByEmail != null) {
          box.write('role', cachedRoleByEmail);
        } else {
          // Если ничего нет, сохраняем роль по умолчанию
          final existingRole = box.read('role');
          if (existingRole == null) {
            box.write('role', 'buyer');
          }
        }
      }

      // Сохраняем или обновляем данные профиля из ответа сервера
      final existingProfile = box.read<Map<String, dynamic>>('userProfile') ?? {};
      box.write('userProfile', {
        'firstName': userData['firstName'] ?? existingProfile['firstName'] ?? '',
        'lastName': userData['lastName'] ?? existingProfile['lastName'] ?? '',
        'email': userData['email'] ?? email,
        'phone': userData['phone'] ?? existingProfile['phone'] ?? '',
        'deliveryPoint': userData['deliveryPoint'] ?? existingProfile['deliveryPoint'] ?? '',
        'profileImage': userData['profileImage'] ?? existingProfile['profileImage'] ?? '',
      });

      // Перенаправляем согласно роли
      final userRole = userData['role'] ?? box.read('role') ?? 'buyer';
      if (userRole == 'seller') {
        Get.offAllNamed(AppRoutes.sellerHome);
      } else if (userRole == 'technician') {
        Get.offAllNamed(AppRoutes.techHome);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      Get.snackbar('Ошибка', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Получить токен авторизации
  String? getToken() {
    return box.read('token');
  }

  /// Получить email пользователя
  String? getEmail() {
    return box.read('email');
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
      Get.snackbar('Ошибка', _getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Выход
  void logout() {
    box.remove('loggedIn');
    // Не удаляем role, чтобы сохранить привязку роли, если сервер не возвращает роль при следующем логине
    box.remove('token');
    // Храним последнюю роль и кэш соответствия email→role; очищаем только активный email и userId
    final currentEmail = box.read('email');
    if (currentEmail != null) {
      // соответствие roleByEmail:<email> сохраняем, чтобы использовать при следующем входе
    }
    box.remove('email');
    box.remove('userId');
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
