import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/constants/api_constants.dart';

class FlightApi {
  static Future<http.Response> sendOrderLocation({
    Map<String, double>? sellerPoint,
    Map<String, double>? buyerPoint,
  }) async {
    final Map<String, dynamic> body = {};
    if (sellerPoint != null) {
      body['sellerPoint'] = sellerPoint;
    }
    if (buyerPoint != null) {
      body['buyerPoint'] = buyerPoint;
    }
    return await http.post(
      Uri.parse(ORDER_LOCATION_URL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  // Функция для открытия/закрытия бокса дрона
  static Future<http.Response> openDroneBox(bool isActive) async {
    return await http.post(
      Uri.parse('${API_BASE_URL}/flight/openbox?isActive=$isActive'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Функция для проверки работоспособности системы
  static Future<http.Response> systemCheck() async {
    return await http.post(
      Uri.parse('${API_BASE_URL}/flight/systemcheck'),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
