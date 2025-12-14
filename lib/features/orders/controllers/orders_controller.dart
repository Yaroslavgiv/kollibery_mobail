import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

/// Контроллер для управления заказами
class OrdersController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  // Список всех заказов
  var orders = <OrderModel>[].obs;

  // Список заказов продавца
  var sellerOrders = <OrderModel>[].obs;

  // Список заказов техника
  var techOrders = <OrderModel>[].obs;

  // Состояние загрузки
  var isLoading = false.obs;

  // Текущий выбранный заказ
  var selectedOrder = Rxn<OrderModel>();

  // Статусы заказов
  final List<String> orderStatuses = [
    'pending', // Ожидает
    'processing', // Обрабатывается
    'preparing', // Готовится
    'in_transit', // В пути
    'shipped', // Отправлен
    'delivered', // Доставлен
    'cancelled', // Отменен
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// Загрузка всех заказов с полной информацией о товарах
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final ordersList = await _orderRepository.fetchOrdersAsModels();
      orders.value = ordersList;
      print(
          '✅ Загружено ${ordersList.length} заказов с полной информацией о товарах');
    } catch (e) {
      print('❌ Ошибка загрузки заказов с информацией о товарах: $e');
      Get.snackbar('Ошибка', 'Не удалось загрузить заказы: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Загрузка заказов продавца
  Future<void> loadSellerOrders() async {
    try {
      isLoading.value = true;
      final ordersList = await _orderRepository.fetchSellerOrdersAsModels();
      sellerOrders.value = ordersList;
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось загрузить заказы продавца: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Загрузка заказов техника
  Future<void> loadTechOrders() async {
    try {
      isLoading.value = true;
      final ordersList = await _orderRepository.fetchTechOrdersAsModels();
      techOrders.value = ordersList;
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось загрузить заказы техника: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Создание нового заказа
  Future<bool> createOrder({
    required String userId,
    required int productId,
    required int quantity,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    try {
      isLoading.value = true;
      final success = await _orderRepository.placeOrder(
        userId: userId,
        productId: productId,
        quantity: quantity,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
      );

      if (success) {
        // Перезагружаем список заказов
        await loadOrders();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Выбор заказа
  void selectOrder(OrderModel order) {
    selectedOrder.value = order;
  }

  /// Получение заказов по статусу
  List<OrderModel> getOrdersByStatus(String status) {
    return orders.where((order) => order.status == status).toList();
  }

  /// Получение заказов продавца по статусу
  List<OrderModel> getSellerOrdersByStatus(String status) {
    return sellerOrders.where((order) => order.status == status).toList();
  }

  /// Получение заказов техника по статусу
  List<OrderModel> getTechOrdersByStatus(String status) {
    return techOrders.where((order) => order.status == status).toList();
  }

  /// Эмитация обновления статуса заказа
  void simulateOrderStatusUpdate(OrderModel order, String newStatus) {
    // Находим заказ в списке и обновляем его статус
    final orderIndex = orders.indexWhere((o) => o.id == order.id);
    if (orderIndex != -1) {
      final updatedOrder = OrderModel(
        id: order.id,
        userId: order.userId,
        productId: order.productId,
        quantity: order.quantity,
        deliveryLatitude: order.deliveryLatitude,
        deliveryLongitude: order.deliveryLongitude,
        status: newStatus,
        productName: order.productName,
        productImage: order.productImage,
        price: order.price,
        buyerName: order.buyerName,
        sellerName: order.sellerName,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
        productDescription: order.productDescription,
        productCategory: order.productCategory,
      );

      orders[orderIndex] = updatedOrder;

      // Обновляем выбранный заказ, если это он
      if (selectedOrder.value?.id == order.id) {
        selectedOrder.value = updatedOrder;
      }
    }
  }

  /// Эмитация процесса доставки для заказа
  void simulateDeliveryProcess(OrderModel order) {
    // Последовательность статусов для эмитации доставки
    final deliveryStatuses = [
      'processing', // Обрабатывается
      'preparing', // Готовится
      'in_transit', // В пути
      'delivered', // Доставлен
    ];

    // Обновляем статусы с задержкой
    for (int i = 0; i < deliveryStatuses.length; i++) {
      Future.delayed(
        Duration(seconds: (i + 1) * 3), // 3, 6, 9 секунд
        () => simulateOrderStatusUpdate(order, deliveryStatuses[i]),
      );
    }
  }

  /// Очистка выбранного заказа
  void clearSelectedOrder() {
    selectedOrder.value = null;
  }

  /// Обновление списка заказов
  Future<void> refreshOrders() async {
    await loadOrders();
  }
}
