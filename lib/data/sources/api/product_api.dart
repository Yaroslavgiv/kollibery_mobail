import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/constants/api_constants.dart';
import '../../../features/home/models/product_model.dart';

class ProductApi {
  static Future<List<ProductModel>> fetchProducts() async {
    final response = await http.get(Uri.parse(PRODUCTS_URL));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка загрузки товаров');
    }
  }

  static Future<bool> placeOrder({
    required String userId,
    required int productId,
    required int qentity,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    final response = await http.post(
      Uri.parse(PLACE_ORDER_URL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'qentity': qentity,
        'deliveryLatitude': deliveryLatitude,
        'deliveryLongitude': deliveryLongitude,
      }),
    );
    return response.statusCode == 200;
  }
}
