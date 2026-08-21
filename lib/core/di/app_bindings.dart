import 'package:get/get.dart';

import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/flight_repository_impl.dart';
import '../../data/repositories/order_history_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/flight_repository.dart';
import '../../domain/repositories/order_history_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/flight_service.dart';
import '../../domain/services/order_service.dart';
import '../../domain/services/product_service.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/cart/controllers/cart_controller.dart';
import '../../features/favorites/controllers/favorites_controller.dart';
import '../../features/orders/controllers/orders_controller.dart';
import '../../features/profile/controllers/profile_controller.dart';
import '../../presentation/managers/catalog_manager.dart';
import '../../presentation/managers/device_command_manager.dart';
import '../../presentation/providers/session_provider.dart';

/// Внедрение зависимостей по иерархии платы:
/// Repository → Service → Provider → Manager.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    /// Core
    Get.put<LocalStorage>(GetStorageLocalStorage(), permanent: true);
    Get.put<ApiClient>(ApiClient(Get.find<LocalStorage>()), permanent: true);

    /// Repository
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        storage: Get.find<LocalStorage>(),
      ),
      permanent: true,
    );
    Get.put<ProductRepository>(ProductRepositoryImpl(), permanent: true);
    Get.put<OrderRepository>(OrderRepositoryImpl(), permanent: true);
    Get.put<OrderHistoryRepository>(
      OrderHistoryRepositoryImpl(),
      permanent: true,
    );
    Get.put<FlightRepository>(FlightRepositoryImpl(), permanent: true);

    /// Service
    Get.put(AuthService(Get.find<AuthRepository>()), permanent: true);
    Get.put(ProductService(Get.find<ProductRepository>()), permanent: true);
    Get.put(
      OrderService(
        Get.find<OrderRepository>(),
        Get.find<OrderHistoryRepository>(),
      ),
      permanent: true,
    );
    Get.put(FlightService(Get.find<FlightRepository>()), permanent: true);

    /// Provider
    Get.put(
      SessionProvider(
        storage: Get.find<LocalStorage>(),
        authService: Get.find<AuthService>(),
      ).initFromStorage(),
      permanent: true,
    );

    /// Manager (GetX-контроллеры — конечная точка BL)
    Get.put(AuthController(), permanent: true);
    Get.put(DeviceCommandManager(), permanent: true);
    Get.put(CatalogManager(), permanent: true);
    Get.put(OrdersController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
  }
}
