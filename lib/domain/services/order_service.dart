import '../../data/models/order_model.dart';
import '../repositories/order_history_repository.dart';
import '../repositories/order_repository.dart';

/// Бизнес-сценарии заказов для всех трёх ролей.
class OrderService {
  OrderService(this._repository, this._historyRepository);

  final OrderRepository _repository;
  final OrderHistoryRepository _historyRepository;

  Future<List<OrderModel>> getBuyerOrders() =>
      _repository.fetchOrdersAsModels();

  Future<List<OrderModel>> getSellerOrders() =>
      _repository.fetchSellerOrdersAsModels();

  Future<List<OrderModel>> getTechOrders() =>
      _repository.fetchTechOrdersAsModels();

  Future<List<OrderModel>> getLastFiveOrders() =>
      _repository.fetchLastFiveOrdersAsModels();

  /// Покупатель заказывает только один товар.
  Future<bool> placeSingleItemOrder({
    required String userId,
    required int productId,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) {
    return _repository.placeOrder(
      userId: userId,
      productId: productId,
      quantity: 1,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );
  }

  Future<bool> placeOrder({
    required String userId,
    required int productId,
    required int quantity,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) {
    return _repository.placeOrder(
      userId: userId,
      productId: productId,
      quantity: quantity,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );
  }

  Future<bool> updateStatus(String orderId, String status) =>
      _repository.updateOrderStatus(orderId, status);

  Future<bool> deleteOrder(String orderId) => _repository.deleteOrder(orderId);

  Future<void> archiveDelivered(OrderModel order) =>
      _historyRepository.saveOrderToHistory(order);

  List<OrderModel> sellerHistory() => _historyRepository.getOrderHistory();

  List<OrderModel> techHistory() => _historyRepository.getTechOrderHistory();

  Future<void> archiveTechDelivered(OrderModel order) =>
      _historyRepository.saveOrderToTechHistory(order);
}
