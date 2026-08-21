/// Исключения слоя данных. Сервисы преобразуют их в [Failure].
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Ошибка сети.']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Ошибка авторизации.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Ошибка сервера.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Ошибка локального хранилища.']);
}
