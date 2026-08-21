import 'package:flutter_test/flutter_test.dart';
import 'package:kollibry/core/errors/failures.dart';
import 'package:kollibry/domain/entities/user_entity.dart';
import 'package:kollibry/domain/repositories/auth_repository.dart';
import 'package:kollibry/domain/services/auth_service.dart';

class _FakeAuthRepository implements AuthRepository {
  Map<String, dynamic> loginResult = {'token': 't'};
  bool loginCalled = false;

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<Map<String, dynamic>> getAccountUser(String userId) async => {};

  @override
  Future<Map<String, dynamic>> getAccountUserByUsername(String userName) async =>
      {};

  @override
  Future<Map<String, dynamic>> getProfile() async => {};

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    loginCalled = true;
    return loginResult;
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? phoneNumber,
  }) async {}

  @override
  Future<UserEntity?> resolveAccount(String email, String? userId) async =>
      null;

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) async =>
      {};
}

void main() {
  late _FakeAuthRepository repository;
  late AuthService service;

  setUp(() {
    repository = _FakeAuthRepository();
    service = AuthService(repository);
  });

  test('валидирует пустые поля регистрации', () async {
    final failure = await service.register(
      firstName: '',
      lastName: 'Иванов',
      email: 'a@b.c',
      password: '123456',
      confirmPassword: '123456',
      role: 'buyer',
    );
    expect(failure, isA<ValidationFailure>());
  });

  test('не пускает неизвестную роль', () async {
    final failure = await service.register(
      firstName: 'Иван',
      lastName: 'Иванов',
      email: 'a@b.c',
      password: '123456',
      confirmPassword: '123456',
      role: 'admin',
    );
    expect(failure, isA<ValidationFailure>());
  });

  test('не пускает разные пароли', () async {
    final failure = await service.register(
      firstName: 'Иван',
      lastName: 'Иванов',
      email: 'a@b.c',
      password: '123456',
      confirmPassword: '654321',
      role: 'buyer',
    );
    expect(failure, isA<ValidationFailure>());
  });

  test('логин с пустым email возвращает ошибку и не ходит в репозиторий',
      () async {
    final result = await service.login(email: '', password: 'x');
    expect(result.$1, isNull);
    expect(result.$2, isA<ValidationFailure>());
    expect(repository.loginCalled, isFalse);
  });

  test('успешный логин возвращает данные репозитория', () async {
    final result = await service.login(email: 'a@b.c', password: 'x');
    expect(result.$2, isNull);
    expect(result.$1?['token'], 't');
    expect(repository.loginCalled, isTrue);
  });
}
