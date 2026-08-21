import '../../core/errors/failures.dart';
import '../../core/utils/jwt_decoder.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

/// Бизнес-логика авторизации.
/// Не знает про виджеты и GetX.
class AuthService {
  AuthService(this._repository);

  final AuthRepository _repository;

  /// Регистрация покупателя, продавца или техника.
  Future<Failure?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? phoneNumber,
  }) async {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        role.isEmpty) {
      return const ValidationFailure('Заполните все обязательные поля.');
    }
    if (UserRole.fromString(role) == null) {
      return const ValidationFailure('Неизвестная роль пользователя.');
    }
    if (password != confirmPassword) {
      return const ValidationFailure('Пароли не совпадают.');
    }
    try {
      await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        phoneNumber: phoneNumber,
      );
      return null;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  /// Вход. Возвращает сырой ответ API для разбора сессии в провайдере.
  Future<(Map<String, dynamic>?, Failure?)> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return (null, const ValidationFailure('Введите email и пароль.'));
    }
    try {
      final data = await _repository.login(email, password);
      return (data, null);
    } catch (e) {
      return (null, UnknownFailure(e.toString()));
    }
  }

  Future<Failure?> forgotPassword(String email) async {
    if (email.isEmpty) {
      return const ValidationFailure('Введите email.');
    }
    try {
      await _repository.forgotPassword(email);
      return null;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
  }

  Future<Map<String, dynamic>> getProfile() => _repository.getProfile();

  Future<Map<String, dynamic>> getAccountUser(String userId) =>
      _repository.getAccountUser(userId);

  Future<Map<String, dynamic>> getAccountUserByUsername(String userName) =>
      _repository.getAccountUserByUsername(userName);

  /// Роль только из JWT — источник истины.
  UserRole? extractRoleFromToken(String token) {
    final payload = JwtDecoder.decodePayload(token);
    if (payload == null) return null;
    final value = JwtDecoder.firstClaim(payload, const [
      'role',
      'roles',
      'userRole',
      'roleName',
      'Role',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/roles',
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role-name',
    ]);
    if (value == null) return null;
    if (value is List && value.isNotEmpty) {
      return UserRole.fromString(value.first.toString());
    }
    return UserRole.fromString(value.toString());
  }

  String? extractUserIdFromToken(String token) {
    final payload = JwtDecoder.decodePayload(token);
    if (payload == null) return null;
    final value = JwtDecoder.firstClaim(payload, const [
      'userId',
      'sub',
      'id',
      'nameid',
      'unique_name',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
    ]);
    return value?.toString();
  }

  String? guidOrNull(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty || !JwtDecoder.isGuid(text)) return null;
    return text;
  }

  UserEntity mergeProfile({
    required UserEntity current,
    required Map<String, dynamic> data,
  }) {
    final firstName = _pick(data, const ['firstName', 'givenName']) ??
        current.firstName;
    final lastName = _pick(
          data,
          const ['lastName', 'surname', 'surName', 'familyName'],
        ) ??
        current.lastName;
    return current.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: _pick(data, const ['email']) ?? current.email,
      phone: _pick(data, const ['phone', 'phoneNumber']) ?? current.phone,
    );
  }

  String? _pick(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
