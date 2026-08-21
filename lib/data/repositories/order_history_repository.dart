import '../../../utils/local_storage/order_history_service.dart';
import '../../domain/repositories/order_history_repository.dart' as contracts;
import '../models/order_model.dart';

/// Реализация локальной истории заказов.
class OrderHistoryRepositoryImpl implements contracts.OrderHistoryRepository {

  /// Сохранение заказа в историю
  /// Сохраняет только выполненные заказы (статус 'delivered')
  /// Автоматически ограничивает историю до 5 последних заказов
  Future<void> saveOrderToHistory(OrderModel order) async {
    try {
      // Сохраняем только выполненные заказы
      if (order.status.toLowerCase() == 'delivered') {
        await OrderHistoryService.addToHistory(order);
        print('✅ Заказ #${order.id} сохранен в локальную историю (статус: delivered)');
      } else {
        print('ℹ️ Заказ #${order.id} не сохранен в историю (статус: ${order.status}, требуется: delivered)');
      }
    } catch (e) {
      print('❌ Ошибка при сохранении заказа в историю: $e');
    }
  }

  /// Получение истории заказов из локального хранилища
  List<OrderModel> getOrderHistory() {
    try {
      // Используем OrderHistoryService для получения истории
      final history = OrderHistoryService.getHistory();
      print('📥 Загружено ${history.length} заказов из локальной истории');
      return history;
    } catch (e) {
      print('❌ Ошибка при чтении истории заказов: $e');
      return [];
    }
  }

  /// Очистка истории заказов
  Future<void> clearHistory() async {
    try {
      await OrderHistoryService.clearHistory();
      print('✅ История заказов очищена');
    } catch (e) {
      print('❌ Ошибка при очистке истории заказов: $e');
    }
  }

  /// Сохранение заказа в историю техника
  /// Сохраняет только выполненные заказы (статус 'delivered')
  /// Автоматически ограничивает историю до 5 последних заказов
  Future<void> saveOrderToTechHistory(OrderModel order) async {
    try {
      // Сохраняем только выполненные заказы
      if (order.status.toLowerCase() == 'delivered') {
        await OrderHistoryService.addToTechHistory(order);
        print('✅ Заказ #${order.id} сохранен в локальную историю техника (статус: delivered)');
      } else {
        print('ℹ️ Заказ #${order.id} не сохранен в историю техника (статус: ${order.status}, требуется: delivered)');
      }
    } catch (e) {
      print('❌ Ошибка при сохранении заказа в историю техника: $e');
    }
  }

  /// Получение истории заказов техника из локального хранилища
  List<OrderModel> getTechOrderHistory() {
    try {
      // Используем OrderHistoryService для получения истории техника
      final history = OrderHistoryService.getTechHistory();
      print('📥 Загружено ${history.length} заказов из локальной истории техника');
      return history;
    } catch (e) {
      print('❌ Ошибка при чтении истории заказов техника: $e');
      return [];
    }
  }

  /// Очистка истории заказов техника
  Future<void> clearTechHistory() async {
    try {
      await OrderHistoryService.clearTechHistory();
      print('✅ История заказов техника очищена');
    } catch (e) {
      print('❌ Ошибка при очистке истории заказов техника: $e');
    }
  }
}

