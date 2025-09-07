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

  /// Регистрация пользователя
  Future<void> register() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final role = roleController.text.trim(); // 'buyer' или 'seller'

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        role.isEmpty) {
      Get.snackbar('Ошибка', 'Заполните все поля и выберите роль');
      return;
    }

    if (role != 'buyer' && role != 'seller' && role != 'tech') {
      Get.snackbar('Ошибка', 'Выберите роль: покупатель, продавец или техник');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Ошибка', 'Пароли не совпадают');
      return;
    }

    try {
      await _authRepository.register(
          firstName, lastName, email, password, confirmPassword);
      Get.snackbar('Успех', 'Вы успешно зарегистрировались');

      // Сохраняем роль пользователя
      box.write('role', role);
      print('=== REGISTRATION DEBUG ===');
      print('Role saved: $role');
      print('=== END REGISTRATION DEBUG ===');

      // Автоматически входим в систему после регистрации
      await autoLoginAfterRegistration(email, password, role);
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    }
  }

  /// Автоматический вход после регистрации
  Future<void> autoLoginAfterRegistration(
      String email, String password, String role) async {
    try {
      final userData = await _authRepository.login(email, password);

      // Сохраняем данные пользователя
      box.write('loggedIn', true);
      box.write('email', email);

      // Сохраняем userId, если он есть в ответе
      if (userData['userId'] != null) {
        box.write('userId', userData['userId']);
        print('✅ UserId сохранен: ${userData['userId']}');
      } else if (userData['id'] != null) {
        box.write('userId', userData['id']);
        print('✅ UserId сохранен (из поля id): ${userData['id']}');
      } else {
        print('⚠️ UserId не найден в ответе сервера');
        print('Доступные поля в ответе: ${userData.keys.toList()}');
        print('Полный ответ сервера: $userData');
      }

      // Сохраняем токен, если он есть в ответе
      if (userData['token'] != null) {
        box.write('token', userData['token']);
        print('Токен сохранен: ${userData['token']}');

        // Тестируем API товаров с полученным токеном
        await _authRepository.testProductsAPI(userData['token']);

        // Тестируем разные форматы авторизации
        await _authRepository
            .testProductsAPIWithDifferentAuth(userData['token']);
      } else {
        print('Токен не найден в ответе сервера');
        print('Полный ответ сервера: $userData');

        // Тестируем API товаров без авторизации
        await _authRepository.testProductsAPIWithoutAuth();

        // Тестируем альтернативные пути API
        await _authRepository.testAlternativeProductPaths();
      }

      Get.snackbar('Успех', 'Вы успешно вошли в систему');

      // Перенаправляем согласно роли
      print('=== AUTO LOGIN DEBUG ===');
      print('Role for redirect: $role');
      if (role == 'seller') {
        print('Redirecting to sellerHome');
        Get.offAllNamed(AppRoutes.sellerHome);
      } else if (role == 'tech') {
        print('Redirecting to techHome');
        Get.offAllNamed(AppRoutes.techHome);
      } else {
        print('Redirecting to home');
        Get.offAllNamed(AppRoutes.home);
      }
      print('=== END AUTO LOGIN DEBUG ===');
    } catch (e) {
      print('Ошибка автоматического входа: $e');
      // Если автоматический вход не удался, перенаправляем на экран входа
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Авторизация
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Ошибка', 'Введите email и пароль');
      return;
    }

    try {
      print('=== НАЧАЛО ЛОГИНА ===');
      print('Email: $email');
      print('Пароль: ${password.length} символов');

      final userData = await _authRepository.login(email, password);

      print('=== ОТВЕТ СЕРВЕРА ПРИ ЛОГИНЕ ===');
      print('Полный ответ: $userData');
      print('Тип ответа: ${userData.runtimeType}');
      print('Ключи в ответе: ${userData.keys.toList()}');
      print('=== КОНЕЦ ОТВЕТА СЕРВЕРА ===');

      // Сохраняем данные пользователя
      box.write('loggedIn', true);
      box.write('email', email);

      // Сохраняем userId, если он есть в ответе
      if (userData['userId'] != null) {
        box.write('userId', userData['userId']);
        print('✅ UserId сохранен: ${userData['userId']}');
      } else if (userData['id'] != null) {
        box.write('userId', userData['id']);
        print('✅ UserId сохранен (из поля id): ${userData['id']}');
      } else {
        print('⚠️ UserId не найден в ответе сервера');
        print('Доступные поля в ответе: ${userData.keys.toList()}');
        print('Полный ответ сервера: $userData');
      }

      // Сохраняем токен, если он есть в ответе
      if (userData['token'] != null) {
        box.write('token', userData['token']);
        print('✅ Токен сохранен: ${userData['token']}');
      } else {
        print('❌ Токен не найден в ответе сервера');
        print('Доступные поля в ответе: ${userData.keys.toList()}');
      }

      // Сохраняем роль, если она есть в ответе
      if (userData['role'] != null) {
        box.write('role', userData['role']);
        print('Роль сохранена: ${userData['role']}');
      } else {
        // Если роль не пришла с сервера, сохраняем существующую роль
        final existingRole = box.read('role');
        if (existingRole != null) {
          print('Используем существующую роль: $existingRole');
        } else {
          box.write('role', 'buyer'); // Роль по умолчанию
          print('Установлена роль по умолчанию: buyer');
        }
      }

      print('=== КОНЕЦ ЛОГИНА ===');
      Get.snackbar('Успех', 'Вы успешно вошли');

      // Перенаправляем согласно роли
      final userRole = userData['role'] ?? box.read('role') ?? 'buyer';
      if (userRole == 'seller') {
        Get.offAllNamed(AppRoutes.sellerHome);
      } else if (userRole == 'tech') {
        Get.offAllNamed(AppRoutes.techHome);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      print('❌ Ошибка при логине: $e');
      Get.snackbar('Ошибка', e.toString());
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
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Ошибка', 'Введите email');
      return;
    }

    try {
      await _authRepository.forgotPassword(email);
      Get.snackbar('Успех', 'Инструкции по сбросу пароля отправлены на email');
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    }
  }

  /// Выход
  void logout() {
    box.remove('loggedIn');
    box.remove('role');
    box.remove('token');
    box.remove('email');
    Get.offAllNamed(AppRoutes.login);
  }
}
