/// Файл маршрутов для всего приложения.
/// Используется в `GetMaterialApp` для управления навигацией.
import 'package:get/get.dart'; // Импорт GetX для маршрутов и состояния
// Импорты страниц и маршрутов приложения
import '../features/auth/views/login_screen.dart'; // Экран авторизации
import '../features/auth/views/registration_screen.dart'; // Экран регистрации
import '../features/auth/views/forgot_password_screen.dart'; // Экран восстановления пароля
import '../features/home/views/main_screen.dart'; // Главная страница приложения
import '../features/onboarding/views/onboarding_screen.dart'; // Страницы онбординга
import '../features/orders/views/delivery_status_screen.dart';
import '../features/orders/views/delivery_completed_screen.dart';
import '../features/profile/views/delivery_point_screen.dart';
import '../features/profile/views/edit_profile_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/seller/views/seller_main__screen.dart'; // Исправить на правильное имя
import '../features/tech/views/tech_main_screen.dart';
import '../features/seller/views/seller_order_status_screen.dart';
import '../features/seller/views/seller_order_completed_screen.dart';
import '../features/seller/views/seller_pickup_location_screen.dart';
import '../features/tech/views/tech_pickup_location_screen.dart';
import '../features/tech/views/tech_delivery_status_screen.dart';
import '../features/tech/views/tech_delivery_completed_screen.dart';
import '../features/tech/views/tech_autopilot_pick_screen.dart';

class AppRoutes {
  static const String login = '/login'; // Маршрут для экрана авторизации
  static const String register = '/register'; // Маршрут для экрана регистрации
  static const String forgotPassword =
      '/forgot-password'; // Маршрут для экрана восстановления пароля
  static const String home = '/home'; // Маршрут для главного экрана
  static const String onboarding = '/onboarding'; // Онбординг
  static const String profile = '/profile'; // Профиль
  static const String profileEdit = '/edit-profile'; // Редактирование профиля
  static const String deliveryPoint = '/delivery-point'; // Точка доставки
  static const String deliveryStatus = '/delivery-status'; // Статус доставки
  static const String deliveryCompleted =
      '/delivery-completed'; // Завершение доставки
  static const String notFound =
      '/not-found'; // Обработчик неизвестных маршрутов
  static const String sellerHome = '/seller-home'; // Продавецкий экран
  static const String techHome = '/tech-home'; // Маршрут для экрана техника
  static const String sellerOrderStatus =
      '/seller-order-status'; // Статус обработки заказа продавца
  static const String sellerOrderCompleted =
      '/seller-order-completed'; // Завершение обработки заказа продавца
  static const String sellerPickupLocation =
      '/seller-pickup-location'; // Выбор точки отправки
  static const String techPickupLocation =
      '/tech-pickup-location'; // Выбор точки посадки дрона для техника
  static const String techDeliveryStatus =
      '/tech-delivery-status'; // Статус отправки заказа для техника
  static const String techDeliveryCompleted = '/tech-delivery-completed';
  static const String techAutopilotPick = '/tech-autopilot-pick';

  static final List<GetPage> pages = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegistrationScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: home, page: () => MainScreen()),
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: profileEdit, page: () => EditProfileScreen()),
    GetPage(name: deliveryPoint, page: () => DeliveryPointScreen()),
    GetPage(name: deliveryStatus, page: () => DeliveryStatusScreen()),
    GetPage(name: deliveryCompleted, page: () => DeliveryCompletedScreen()),
    GetPage(name: sellerHome, page: () => SellerMainScreen()), // продавец
    GetPage(name: techHome, page: () => TechMainScreen()), // экран техника
    GetPage(
        name: sellerOrderStatus,
        page: () =>
            SellerOrderStatusScreen()), // статус обработки заказа продавца
    GetPage(
        name: sellerOrderCompleted,
        page: () =>
            SellerOrderCompletedScreen()), // завершение обработки заказа продавца
    GetPage(
        name: sellerPickupLocation,
        page: () => SellerPickupLocationScreen.fromArguments(Get.arguments)),
    GetPage(
        name: techPickupLocation,
        page: () => TechPickupLocationScreen.fromArguments(Get.arguments)),
    GetPage(name: techDeliveryStatus, page: () => TechDeliveryStatusScreen()),
    GetPage(
      name: techDeliveryCompleted,
      page: () => TechDeliveryCompletedScreen(),
    ),
    GetPage(name: techAutopilotPick, page: () => TechAutopilotPickScreen()),
  ];
}
