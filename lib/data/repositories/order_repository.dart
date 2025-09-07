import '../sources/api/order_api.dart';
import '../models/order_model.dart';

class OrderRepository {
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
  Future<bool> updateOrderStatus(String orderId, String status) async {
    return await OrderApi.updateOrderStatus(orderId, status);
  }

  /// Получение заказов как OrderModel
  Future<List<OrderModel>> fetchOrdersAsModels() async {
    final ordersData = await fetchOrders();
    return ordersData.map((data) => OrderModel.fromJson(data)).toList();
  }

  /// Получение заказов продавца как OrderModel
  Future<List<OrderModel>> fetchSellerOrdersAsModels() async {
    final ordersData = await fetchSellerOrders();
    return ordersData.map((data) => OrderModel.fromJson(data)).toList();
  }

  /// Получение заказов техника как OrderModel
  Future<List<OrderModel>> fetchTechOrdersAsModels() async {
    final ordersData = await fetchTechOrders();
    return ordersData.map((data) => OrderModel.fromJson(data)).toList();
  }
}
