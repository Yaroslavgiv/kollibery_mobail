import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../data/models/order_model.dart';

/// Сервис для работы с историей заказов в локальном кеше
class OrderHistoryService {
  static const String _historyKey = 'seller_order_history';
  static const int _maxHistorySize = 5;
  static final GetStorage _storage = GetStorage();

  /// Сохранение заказа в историю
  /// Автоматически удаляет старые заказы, если их больше 5
  static Future<void> addToHistory(OrderModel order) async {
    try {
      final historyJson = _storage.read(_historyKey);
      List<Map<String, dynamic>> history = [];
      
      if (historyJson != null) {
        if (historyJson is String) {
          history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
        } else if (historyJson is List) {
          history = List<Map<String, dynamic>>.from(historyJson);
        }
      }

      // Преобразуем заказ в Map
      final orderMap = order.toJson();
      
      // Добавляем дату добавления в историю
      orderMap['addedToHistoryAt'] = DateTime.now().toIso8601String();
      
      // Удаляем дубликаты по ID заказа
      history.removeWhere((item) => item['id'] == order.id);
      
      // Добавляем новый заказ в начало списка
      history.insert(0, orderMap);
      
      // Ограничиваем размер истории до 5 заказов
      if (history.length > _maxHistorySize) {
        history = history.sublist(0, _maxHistorySize);
      }
      
      // Сохраняем обновленную историю
      await _storage.write(_historyKey, jsonEncode(history));
      
      print('✅ Заказ #${order.id} добавлен в историю. Всего в истории: ${history.length}');
    } catch (e) {
      print('❌ Ошибка при добавлении заказа в историю: $e');
    }
  }

  /// Получение истории заказов
  static List<OrderModel> getHistory() {
    try {
      final historyJson = _storage.read(_historyKey);
      if (historyJson == null) {
        return [];
      }

      List<Map<String, dynamic>> history = [];
      if (historyJson is String) {
        history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      } else if (historyJson is List) {
        history = List<Map<String, dynamic>>.from(historyJson);
      }

      return history.map((item) {
        // Удаляем служебное поле перед созданием модели
        final orderData = Map<String, dynamic>.from(item);
        orderData.remove('addedToHistoryAt');
        return OrderModel.fromJson(orderData);
      }).toList();
    } catch (e) {
      print('❌ Ошибка при получении истории заказов: $e');
      return [];
    }
  }

  /// Очистка истории заказов
  static Future<void> clearHistory() async {
    try {
      await _storage.remove(_historyKey);
      print('✅ История заказов очищена');
    } catch (e) {
      print('❌ Ошибка при очистке истории заказов: $e');
    }
  }

  /// Удаление конкретного заказа из истории
  static Future<void> removeFromHistory(int orderId) async {
    try {
      final historyJson = _storage.read(_historyKey);
      if (historyJson == null) {
        return;
      }

      List<Map<String, dynamic>> history = [];
      if (historyJson is String) {
        history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      } else if (historyJson is List) {
        history = List<Map<String, dynamic>>.from(historyJson);
      }

      history.removeWhere((item) => item['id'] == orderId);
      
      await _storage.write(_historyKey, jsonEncode(history));
      print('✅ Заказ #$orderId удален из истории');
    } catch (e) {
      print('❌ Ошибка при удалении заказа из истории: $e');
    }
  }
}




