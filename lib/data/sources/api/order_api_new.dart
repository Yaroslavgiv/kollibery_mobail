import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class OrderApi {
  static final GetStorage _storage = GetStorage();

  /// олучение всех заказов
  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer ';
      }

      final response = await http.get(
        Uri.parse(ORDERS_URL),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('шибка загрузки заказов: ');
      }
    } catch (e) {
      throw Exception('шибка загрузки заказов: ');
    }
  }

  /// азмещение нового заказа
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
        headers['Authorization'] = 'Bearer ';
      }

      final requestBody = {
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
        'deliveryLatitude': deliveryLatitude,
        'deliveryLongitude': deliveryLongitude,
      };

      print('=== Щ  ===');
      print('URL: ');
      print('Headers: ');
      print('Body: ');

      final response = await http.post(
        Uri.parse(PLACE_ORDER_URL),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('=== ТТ С ===');
      print('Status Code: ');
      print('Response Body: ');
      print('Response Headers: ');

      if (response.statusCode == 200) {
        print('✅ аказ успешно размещен');
        return true;
      } else {
        print('❌ шибка размещения заказа: ');
        print('твет сервера: ');
        return false;
      }
    } catch (e) {
      print('❌ сключение при размещении заказа: ');
      return false;
    }
  }

  /// олучение заказов по роли пользователя
  static Future<List<Map<String, dynamic>>> fetchOrdersByRole(
      String role) async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer ';
      }

      final response = await http.get(
        Uri.parse('='),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('шибка загрузки заказов: ');
      }
    } catch (e) {
      throw Exception('шибка загрузки заказов: ');
    }
  }

  /// олучение заказов продавца
  static Future<List<Map<String, dynamic>>> fetchSellerOrders() async {
    return await fetchOrdersByRole('seller');
  }

  /// олучение заказов техника
  static Future<List<Map<String, dynamic>>> fetchTechOrders() async {
    return await fetchOrdersByRole('tech');
  }
}
