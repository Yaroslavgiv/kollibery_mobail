import '../sources/api/order_api.dart';
import '../models/order_model.dart';
import '../../utils/local_storage/storage_utility.dart';

class OrderRepository {
  final KLocalStorage _localStorage = KLocalStorage();
  static const String _orderStatusesKey = 'order_statuses';
  /// Получение всех заказов
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    return await OrderApi.fetchOrders();
  }

  /// Размещение нового заказа
  Future<bool> placeOrder({
    required String userId,
    required int productId,
    required int quantity,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    return await OrderApi.placeOrder(
      userId: userId,
      productId: productId,
      quantity: quantity,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );
  }

  /// Получение заказов по роли пользователя
  Future<List<Map<String, dynamic>>> fetchOrdersByRole(String role) async {
    return await OrderApi.fetchOrdersByRole(role);
  }

  /// Получение заказов продавца
  Future<List<Map<String, dynamic>>> fetchSellerOrders() async {
    return await OrderApi.fetchSellerOrders();
  }

  /// Получение заказов техника
  Future<List<Map<String, dynamic>>> fetchTechOrders() async {
    return await OrderApi.fetchTechOrders();
  }

  /// Обновление статуса заказа
  /// Сохраняет статус локально, даже если API не поддерживает обновление
  Future<bool> updateOrderStatus(String orderId, String status) async {
    // Сохраняем статус локально в любом случае
    final statuses = _localStorage.readData<Map<String, dynamic>>(_orderStatusesKey) ?? {};
    statuses[orderId] = status;
    await _localStorage.saveData(_orderStatusesKey, statuses);
    print('✅ Статус заказа $orderId сохранен локально: $status');
    
    // Пытаемся обновить на сервере, но не критично если не получится
    try {
      final result = await OrderApi.updateOrderStatus(orderId, status);
      if (result) {
        print('✅ Статус заказа $orderId также обновлен на сервере');
      }
      return true; // Возвращаем true, так как локальное обновление успешно
    } catch (e) {
      print('⚠️ Не удалось обновить статус на сервере (используется локальное обновление): $e');
      // Возвращаем true, так как локальное обновление успешно
      return true;
    }
  }
  
  /// Получение локально сохраненного статуса заказа
  String? getLocalOrderStatus(String orderId) {
    final statuses = _localStorage.readData<Map<String, dynamic>>(_orderStatusesKey);
    if (statuses != null && statuses.containsKey(orderId)) {
      return statuses[orderId] as String?;
    }
    return null;
  }
  
  /// Применение локально сохраненных статусов к списку заказов
  List<OrderModel> _applyLocalStatuses(List<OrderModel> orders) {
    final statuses = _localStorage.readData<Map<String, dynamic>>(_orderStatusesKey);
    if (statuses == null || statuses.isEmpty) {
      return orders;
    }
    
    return orders.map((order) {
      final localStatus = statuses[order.id.toString()] as String?;
      if (localStatus != null && localStatus != order.status) {
        // Создаем новый заказ с обновленным статусом
        return OrderModel(
          id: order.id,
          userId: order.userId,
          productId: order.productId,
          quantity: order.quantity,
          deliveryLatitude: order.deliveryLatitude,
          deliveryLongitude: order.deliveryLongitude,
          status: localStatus,
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
      }
      return order;
    }).toList();
  }

  /// Получение заказов как OrderModel
  Future<List<OrderModel>> fetchOrdersAsModels() async {
    final ordersData = await fetchOrders();
    final orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();
    // Применяем локально сохраненные статусы
    return _applyLocalStatuses(orders);
  }

  /// Получение заказов продавца как OrderModel
  Future<List<OrderModel>> fetchSellerOrdersAsModels() async {
    final ordersData = await fetchSellerOrders();
    final orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();
    // Применяем локально сохраненные статусы
    return _applyLocalStatuses(orders);
  }

  /// Получение заказов техника как OrderModel
  Future<List<OrderModel>> fetchTechOrdersAsModels() async {
    final ordersData = await fetchTechOrders();
    final orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();
    // Применяем локально сохраненные статусы
    return _applyLocalStatuses(orders);
  }

  /// Удаление заказа
  Future<bool> deleteOrder(String orderId) async {
    return await OrderApi.deleteOrder(orderId);
  }
}
