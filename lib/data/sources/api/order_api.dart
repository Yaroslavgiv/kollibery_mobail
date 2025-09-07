import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class OrderApi {
  static final GetStorage _storage = GetStorage();

  /// Получение всех заказов
  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(ORDERS_URL),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Ошибка загрузки заказов: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка загрузки заказов: $e');
    }
  }

  /// Размещение нового заказа
  static Future<bool> placeOrder({
    required String userId,
    required int productId,
    required int quantity,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final requestBody = {
        'userId': userId,
        'productId': productId,
        'quentity': quantity, // ИСПРАВЛЕНО: quantity -> quentity
        'deliveryLatitude': deliveryLatitude,
        'deliveryLongitude': deliveryLongitude,
      };

      print('=== ОТПРАВКА ЗАКАЗА НА СЕРВЕР ===');
      print('URL: $PLACE_ORDER_URL');
      print('Headers: $headers');
      print('Request Body: $requestBody');
      print('=== КОНЕЦ ОТПРАВКИ ЗАКАЗА ===');

      final response = await http.post(
        Uri.parse(PLACE_ORDER_URL),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('=== ОТВЕТ СЕРВЕРА ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('=== КОНЕЦ ОТВЕТА СЕРВЕРА ===');

      if (response.statusCode == 200) {
        print('✅ Заказ успешно размещен!');
        return true;
      } else {
        print('❌ Ошибка размещения заказа: ${response.statusCode}');
        print('Ответ сервера: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Исключение при размещении заказа: $e');
      print('Тип ошибки: ${e.runtimeType}');
      return false;
    }
  }

  /// Получение заказов по роли пользователя
  static Future<List<Map<String, dynamic>>> fetchOrdersByRole(
      String role) async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$ORDERS_URL?role=$role'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Ошибка загрузки заказов: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка загрузки заказов: $e');
    }
  }

  /// Получение заказов продавца
  static Future<List<Map<String, dynamic>>> fetchSellerOrders() async {
    return await fetchOrdersByRole('seller');
  }

  /// Получение заказов техника
  static Future<List<Map<String, dynamic>>> fetchTechOrders() async {
    return await fetchOrdersByRole('tech');
  }

  /// Обновление статуса заказа
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$ORDERS_URL/$orderId/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Ошибка обновления статуса: $e');
    }
  }
}
