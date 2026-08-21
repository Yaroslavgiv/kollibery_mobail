import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/logging/app_logger.dart';
import '../../../domain/services/auth_service.dart';
import '../../../presentation/providers/session_provider.dart';
import '../../../routes/app_routes.dart';

/// Manager авторизации. View работает только с этим классом.
class AuthController extends GetxController {
  AuthController({
    AuthService? authService,
    SessionProvider? session,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _session = session ?? Get.find<SessionProvider>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final roleController = TextEditingController();

  final AuthService _authService;
  final SessionProvider _session;
  final RxBool isLoading = false.obs;

  /// Регистрация пользователя.
  Future<void> register() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final role = roleController.text.trim();
    final phone = phoneController.text.trim();

    try {
      final failure = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        phoneNumber: phone,
      );
      if (failure != null) return;

      await _session.writeProfile({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'deliveryPoint': '',
        'profileImage': '',
      });

      await autoLoginAfterRegistration(email, password);
    } catch (e) {
      AppLogger.error('Ошибка регистрации', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Автоматический вход после регистрации.
  Future<void> autoLoginAfterRegistration(String email, String password) async {
    try {
      await _completeLogin(email, password);
    } catch (e) {
      AppLogger.error('Автологин после регистрации не удался', e);
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Авторизация.
  Future<void> login() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await _completeLogin(email, password);
    } catch (e) {
      AppLogger.error('Ошибка входа', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completeLogin(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    final userData = result.$1;
    final failure = result.$2;
    if (failure != null || userData == null) return;

    await _session.persistLogin(
      email: email,
      userData: userData,
      existingProfile: _session.readProfile(),
    );

    try {
      await _resolveProfileFromServer(email);
    } catch (e) {
      AppLogger.warning('Не удалось получить имя с сервера: $e');
    }

    Get.offAllNamed(_session.initialRoute);
  }

  Future<void> _resolveProfileFromServer(String email) async {
    final userId = _session.userId.value;
    if (userId != null && userId.isNotEmpty) {
      final accountUser = await _authService.getAccountUser(userId);
      if (accountUser.isNotEmpty) {
        await _session.mergeAccountUser(accountUser, email);
      }
      return;
    }

    final accountUser = await _authService.getAccountUserByUsername(email);
    if (accountUser.isEmpty) return;
    await _session.mergeAccountUser(accountUser, email);

    final resolvedId = _session.userId.value;
    if (resolvedId == null || resolvedId.isEmpty) return;
    final fullUser = await _authService.getAccountUser(resolvedId);
    if (fullUser.isNotEmpty) {
      await _session.mergeAccountUser(fullUser, email);
    }
  }

  String? getToken() => _session.getToken();

  String? getEmail() => _session.email.value;

  Future<void> resetPassword() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _authService.forgotPassword(emailController.text.trim());
    } catch (e) {
      AppLogger.error('Ошибка сброса пароля', e);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _session.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    roleController.dispose();
    super.onClose();
  }
}
