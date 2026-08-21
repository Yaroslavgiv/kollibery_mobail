import '../../data/models/order_model.dart';

/// Контракт локальной истории заказов.
abstract class OrderHistoryRepository {
  Future<void> saveOrderToHistory(OrderModel order);

  List<OrderModel> getOrderHistory();

  Future<void> clearHistory();

  Future<void> saveOrderToTechHistory(OrderModel order);

  List<OrderModel> getTechOrderHistory();

  Future<void> clearTechHistory();
}
