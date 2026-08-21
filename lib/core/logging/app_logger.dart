import '../../utils/logging/logger.dart';

/// Обёртка логгера для слоёв архитектуры.
/// View и бизнес-логика не вызывают print напрямую.
class AppLogger {
  AppLogger._();

  static void debug(String message) => KLoggerHelper.debug(message);

  static void info(String message) => KLoggerHelper.info(message);

  static void warning(String message) => KLoggerHelper.warning(message);

  static void error(String message, [dynamic error]) =>
      KLoggerHelper.error(message, error);
}
