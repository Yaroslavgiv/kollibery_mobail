import '../../../utils/local_storage/storage_utility.dart';
import '../models/order_model.dart';

/// Репозиторий для работы с историей заказов в локальном кеше
class OrderHistoryRepository {
  static const String _historyKey = 'seller_order_history';
  final KLocalStorage _localStorage = KLocalStorage();

  /// Сохранение заказа в историю
  Future<void> saveOrderToHistory(OrderModel order) async {
    try {
      // Локальное сохранение истории отключено по требованию.
      // История берется с сервера через /order/getlastfiveorders.
      print('ℹ️ Локальное сохранение истории отключено для заказа ${order.id}');
    } catch (e) {
      print('❌ Ошибка при сохранении заказа в историю: $e');
    }
  }

  /// Получение истории заказов
  List<OrderModel> getOrderHistory() {
    try {
      final historyData = _localStorage.readData<List<dynamic>>(_historyKey);
      if (historyData == null || historyData.isEmpty) {
        return [];
      }
      
      return historyData
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Ошибка при чтении истории заказов: $e');
      return [];
    }
  }

  /// Очистка истории заказов
  Future<void> clearHistory() async {
    try {
      await _localStorage.removeData(_historyKey);
      print('✅ История заказов очищена');
    } catch (e) {
      print('❌ Ошибка при очистке истории заказов: $e');
    }
  }
}

