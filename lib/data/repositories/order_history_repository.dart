import '../../../utils/local_storage/storage_utility.dart';
import '../models/order_model.dart';

/// Репозиторий для работы с историей заказов в локальном кеше
class OrderHistoryRepository {
  static const String _historyKey = 'seller_order_history';
  final KLocalStorage _localStorage = KLocalStorage();
  static const int _maxHistorySize = 5; // Максимум 5 последних заказов

  /// Сохранение заказа в историю
  Future<void> saveOrderToHistory(OrderModel order) async {
    try {
      // Получаем текущую историю
      final history = getOrderHistory();
      
      // Добавляем новый заказ в начало списка
      history.insert(0, order);
      
      // Ограничиваем размер истории до 5 заказов
      if (history.length > _maxHistorySize) {
        history.removeRange(_maxHistorySize, history.length);
      }
      
      // Сохраняем обновленную историю
      final historyJson = history.map((order) => order.toJson()).toList();
      await _localStorage.saveData(_historyKey, historyJson);
      
      print('✅ Заказ ${order.id} сохранен в историю. Всего в истории: ${history.length}');
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

