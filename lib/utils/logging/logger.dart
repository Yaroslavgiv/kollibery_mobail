import 'package:logger/logger.dart';

class KLoggerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of stack trace methods to show
      errorMethodCount: 5, // Number of stack trace methods for errors
      lineLength: 120, // Width of each log line
      colors: true, // Colorful log messages
      printEmojis: true, // Print emojis for log levels
      printTime: true, // Print timestamps
    ),
    level: Level.debug, // Set default log level
  );

  static void debug(String message) {
    _logger.d('Отладка: $message');
  }

  static void info(String message) {
    _logger.i('Информация: $message');
  }

  static void warning(String message) {
    _logger.w('Предупреждение: $message');
  }

  static void error(String message, [dynamic error]) {
    _logger.e('Ошибка: $message', error: error, stackTrace: StackTrace.current);
  }

  static void logCustom(String message, {Level level = Level.verbose}) {
    _logger.log(level, 'Пользовательское сообщение: $message');
  }
}
