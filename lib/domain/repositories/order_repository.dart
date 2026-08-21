import '../../data/models/order_model.dart';

/// Контракт репозитория заказов.
abstract class OrderRepository {
  Future<List<OrderModel>> fetchOrdersAsModels();

  Future<List<OrderModel>> fetchSellerOrdersAsModels();

  Future<List<OrderModel>> fetchTechOrdersAsModels();

  Future<List<OrderModel>> fetchLastFiveOrdersAsModels();

  Future<bool> placeOrder({
    required String userId,
    required int productId,
    required int quantity,
    required double deliveryLatitude,
    required double deliveryLongitude,
  });

  Future<bool> updateOrderStatus(String orderId, String status);

  Future<bool> deleteOrder(String orderId);

  String? getLocalOrderStatus(String orderId);
}
