import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../data/models/order_model.dart';

/// Сервис для работы с историей заказов в локальном кеше
class OrderHistoryService {
  static const String _sellerHistoryKey = 'seller_order_history';
  static const String _techHistoryKey = 'tech_order_history';
  static const int _maxHistorySize = 5;
  static final GetStorage _storage = GetStorage();

  /// Сохранение заказа в историю продавца
  /// Автоматически удаляет старые заказы, если их больше 5
  static Future<void> addToHistory(OrderModel order) async {
    await _addToHistory(order, _sellerHistoryKey);
  }

  /// Сохранение заказа в историю техника
  /// Автоматически удаляет старые заказы, если их больше 5
  static Future<void> addToTechHistory(OrderModel order) async {
    await _addToHistory(order, _techHistoryKey);
  }

  /// Внутренний метод для сохранения заказа в историю
  static Future<void> _addToHistory(OrderModel order, String historyKey) async {
    try {
      final historyJson = _storage.read(historyKey);
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
      await _storage.write(historyKey, jsonEncode(history));
      
      final role = historyKey == _sellerHistoryKey ? 'продавца' : 'техника';
      print('✅ Заказ #${order.id} добавлен в историю $role. Всего в истории: ${history.length}');
    } catch (e) {
      print('❌ Ошибка при добавлении заказа в историю: $e');
    }
  }

  /// Получение истории заказов продавца
  static List<OrderModel> getHistory() {
    return _getHistory(_sellerHistoryKey);
  }

  /// Получение истории заказов техника
  static List<OrderModel> getTechHistory() {
    return _getHistory(_techHistoryKey);
  }

  /// Внутренний метод для получения истории заказов
  static List<OrderModel> _getHistory(String historyKey) {
    try {
      final historyJson = _storage.read(historyKey);
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

  /// Очистка истории заказов продавца
  static Future<void> clearHistory() async {
    await _clearHistory(_sellerHistoryKey);
  }

  /// Очистка истории заказов техника
  static Future<void> clearTechHistory() async {
    await _clearHistory(_techHistoryKey);
  }

  /// Внутренний метод для очистки истории заказов
  static Future<void> _clearHistory(String historyKey) async {
    try {
      await _storage.remove(historyKey);
      final role = historyKey == _sellerHistoryKey ? 'продавца' : 'техника';
      print('✅ История заказов $role очищена');
    } catch (e) {
      print('❌ Ошибка при очистке истории заказов: $e');
    }
  }

  /// Удаление конкретного заказа из истории продавца
  static Future<void> removeFromHistory(int orderId) async {
    await _removeFromHistory(orderId, _sellerHistoryKey);
  }

  /// Удаление конкретного заказа из истории техника
  static Future<void> removeFromTechHistory(int orderId) async {
    await _removeFromHistory(orderId, _techHistoryKey);
  }

  /// Внутренний метод для удаления заказа из истории
  static Future<void> _removeFromHistory(int orderId, String historyKey) async {
    try {
      final historyJson = _storage.read(historyKey);
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
      
      await _storage.write(historyKey, jsonEncode(history));
      final role = historyKey == _sellerHistoryKey ? 'продавца' : 'техника';
      print('✅ Заказ #$orderId удален из истории $role');
    } catch (e) {
      print('❌ Ошибка при удалении заказа из истории: $e');
    }
  }
}




