import '../entities/user_entity.dart';

/// Контракт репозитория авторизации и профиля.
abstract class AuthRepository {
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? phoneNumber,
  });

  Future<Map<String, dynamic>> login(String email, String password);

  Future<void> forgotPassword(String email);

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  });

  Future<Map<String, dynamic>> getProfile();

  Future<Map<String, dynamic>> getAccountUser(String userId);

  Future<Map<String, dynamic>> getAccountUserByUsername(String userName);

  /// Сохранение сессии после логина — детализация в data/provider.
  Future<UserEntity?> resolveAccount(String email, String? userId);
}
