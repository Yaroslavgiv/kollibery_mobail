/// Базовый сбой доменного слоя.
/// UI и менеджеры работают с Failure, а не с Dio/HTTP.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// Ошибка сети или таймаут.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Проблема с подключением к серверу.']);
}

/// Ошибка авторизации (401/403, нет токена).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Требуется авторизация.']);
}

/// Ошибка валидации входных данных.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Неверные данные.']);
}

/// Ошибка сервера (4xx/5xx кроме авторизации).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ошибка сервера. Попробуйте позже.']);
}

/// Непредвиденная ошибка.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Произошла ошибка. Попробуйте ещё раз.']);
}
