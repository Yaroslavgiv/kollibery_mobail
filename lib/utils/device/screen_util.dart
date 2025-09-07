import 'package:get/get.dart';

/// Утилита для адаптивности экрана
class ScreenUtil {
  /// Получить ширину как процент от экрана
  static double percentWidth(double percent) {
    return Get.width * percent / 100;
  }

  /// Получить высоту как процент от экрана
  static double percentHeight(double percent) {
    return Get.height * percent / 100;
  }

  /// Масштабировать размер на основе ширины экрана
  static double adaptiveWidth(double size) {
    return Get.width * (size / 375); // 375 - базовая ширина (iPhone 11)
  }

  /// Масштабировать размер на основе высоты экрана
  static double adaptiveHeight(double size) {
    return Get.height * (size / 812); // 812 - базовая высота (iPhone 11)
  }
}
