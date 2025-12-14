import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../utils/constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class OrderApi {
  static final GetStorage _storage = GetStorage();

  /// Внутренний метод: получить все товары и построить карту по id
  static Future<Map<int, Map<String, dynamic>>> _fetchAllProductsMap() async {
    final token = _storage.read('token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('=== ЗАГРУЗКА ВСЕХ ТОВАРОВ ДЛЯ ОБОГАЩЕНИЯ ЗАКАЗОВ ===');
    final response = await http.get(
      Uri.parse(PRODUCTS_URL),
      headers: headers,
    );

    if (response.statusCode != 200) {
      print('❌ Не удалось загрузить список товаров: ${response.statusCode}');
      return {};
    }

    final body = jsonDecode(response.body);
    if (body is! List) {
      print('❌ Неверный формат ответа товаров (ожидался List)');
      return {};
    }

    final Map<int, Map<String, dynamic>> map = {};
    for (final item in body) {
      if (item is Map<String, dynamic>) {
        final id = item['id'];
        if (id is int) {
          map[id] = item;
        }
      }
    }
    print('✅ Загрузили товаров: ${map.length}');
    return map;
  }

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

      print('=== ПОЛУЧЕНИЕ ЗАКАЗОВ С ИНФОРМАЦИЕЙ О ТОВАРАХ ===');

      final response = await http.get(
        Uri.parse(ORDERS_URL),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List ordersData = jsonDecode(response.body);
        final List<Map<String, dynamic>> enrichedOrders = [];

        // Загружаем все товары один раз и строим карту по id
        final productsMap = await _fetchAllProductsMap();

        // Для каждого заказа берём информацию о товаре из карты
        for (final orderData in ordersData) {
          final order = orderData as Map<String, dynamic>;
          final productId = order['productId'];

          if (productId != null && productsMap.containsKey(productId)) {
            final productInfo = productsMap[productId]!;
            final enrichedOrder = {
              ...order,
              'productName': productInfo['name'] ??
                  productInfo['title'] ??
                  productInfo['productName'] ??
                  'Товар #$productId',
              'productImage': productInfo['image'] ??
                  productInfo['imageUrl'] ??
                  productInfo['productImage'] ??
                  '',
              'productDescription': productInfo['description'] ??
                  productInfo['productDescription'] ??
                  '',
              'productPrice':
                  productInfo['price'] ?? productInfo['productPrice'] ?? 0.0,
              'productCategory': productInfo['category'] ??
                  productInfo['productCategory'] ??
                  '',
            };
            enrichedOrders.add(enrichedOrder);
          } else {
            enrichedOrders.add(order);
          }
        }

        print(
            '✅ Получено ${enrichedOrders.length} заказов с информацией о товарах');
        return enrichedOrders;
      } else {
        throw Exception('Ошибка загрузки заказов: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Исключение при получении заказов с информацией о товарах: $e');
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
        'quantity': quantity,
        'deliveryLatitude': deliveryLatitude,
        'deliveryLongitude': deliveryLongitude,
      };

      print('=== ОТПРАВКА ЗАКАЗА НА СЕРВЕР ===');
      print('URL: $PLACE_ORDER_URL');
      print('Headers: $headers');
      print('Request Body: $requestBody');
      print(
          '⚠️ ВНИМАНИЕ: sellerId не передается! Бэкенд должен определить продавца по productId');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Пытаемся распарсить ответ, чтобы получить ID созданного заказа
        try {
          final responseBody = response.body;
          if (responseBody.isNotEmpty) {
            final responseData = jsonDecode(responseBody);
            print('📦 Ответ сервера содержит данные: $responseData');
            if (responseData is Map) {
              final orderId = responseData['id'] ?? responseData['orderId'];
              if (orderId != null) {
                print('✅ Заказ успешно размещен! ID заказа: $orderId');
              } else {
                print('✅ Заказ успешно размещен! (ID не указан в ответе)');
              }
            } else {
              print('✅ Заказ успешно размещен!');
            }
          } else {
            print('✅ Заказ успешно размещен! (пустой ответ)');
          }
        } catch (e) {
          print('✅ Заказ успешно размещен! (не удалось распарсить ответ: $e)');
        }
        return true;
      } else {
        print('❌ Ошибка размещения заказа: ${response.statusCode}');
        print('Ответ сервера: ${response.body}');
        print(
            '⚠️ Проверьте, что бэкенд правильно обрабатывает запрос и связывает заказ с продавцом по productId');
        return false;
      }
    } catch (e) {
      print('❌ Исключение при размещении заказа: $e');
      print('Тип ошибки: ${e.runtimeType}');
      return false;
    }
  }

  /// Получение заказов по роли пользователя с полной информацией о товарах
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

      print('=== ПОЛУЧЕНИЕ ЗАКАЗОВ ПО РОЛИ: $role ===');
      print('URL: $ORDERS_URL?role=$role');
      print('Headers: $headers');

      final response = await http.get(
        Uri.parse('$ORDERS_URL?role=$role'),
        headers: headers,
      );

      print('=== ОТВЕТ СЕРВЕРА ДЛЯ РОЛИ $role ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== КОНЕЦ ОТВЕТА СЕРВЕРА ===');

      if (response.statusCode == 200) {
        final List ordersData = jsonDecode(response.body);
        print('📦 Получено ${ordersData.length} заказов для роли $role');
        final List<Map<String, dynamic>> enrichedOrders = [];

        // Загружаем все товары один раз и строим карту по id
        final productsMap = await _fetchAllProductsMap();

        // Для каждого заказа берём информацию о товаре из карты
        for (final orderData in ordersData) {
          final order = orderData as Map<String, dynamic>;
          final productId = order['productId'];
          final orderId = order['id'];
          final createdAt = order['createdAt'];
          final updatedAt = order['updatedAt'];

          print('📋 Обработка заказа ID: $orderId, productId: $productId');
          print('   📅 createdAt: $createdAt (тип: ${createdAt.runtimeType})');
          print('   📅 updatedAt: $updatedAt (тип: ${updatedAt.runtimeType})');

          if (productId != null && productsMap.containsKey(productId)) {
            final productInfo = productsMap[productId]!;
            final productSellerId = productInfo['userId'];
            print('  ✅ Товар найден. sellerId (из продукта): $productSellerId');

            final enrichedOrder = {
              ...order,
              'productName': productInfo['name'] ??
                  productInfo['title'] ??
                  productInfo['productName'] ??
                  'Товар #$productId',
              'productImage': productInfo['image'] ??
                  productInfo['imageUrl'] ??
                  productInfo['productImage'] ??
                  '',
              'productDescription': productInfo['description'] ??
                  productInfo['productDescription'] ??
                  '',
              'productPrice':
                  productInfo['price'] ?? productInfo['productPrice'] ?? 0.0,
              'productCategory': productInfo['category'] ??
                  productInfo['productCategory'] ??
                  '',
              // Добавляем sellerId из продукта, если его нет в заказе
              'sellerId': order['sellerId'] ?? productSellerId,
            };
            enrichedOrders.add(enrichedOrder);
          } else {
            print(
                '  ⚠️ Товар не найден в карте продуктов для productId: $productId');
            enrichedOrders.add(order);
          }
        }

        print(
            '✅ Получено ${enrichedOrders.length} заказов для роли $role с информацией о товарах');
        return enrichedOrders;
      } else {
        throw Exception('Ошибка загрузки заказов: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Исключение при получении заказов для роли $role: $e');
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

      print('=== ОБНОВЛЕНИЕ СТАТУСА ЗАКАЗА ===');
      print('Order ID: $orderId');
      print('Status: $status');

      // Пробуем несколько вариантов endpoint'ов
      final urlsToTry = [
        '$ORDERS_URL/$orderId/status', // Вариант 1: стандартный REST
        '$UPDATE_ORDER_STATUS_URL', // Вариант 2: отдельный endpoint
        '$ORDERS_URL/$orderId', // Вариант 3: обновление всего заказа
      ];

      http.Response? response;
      Exception? lastException;

      for (final url in urlsToTry) {
        try {
          print('Пробуем URL: $url');
          print('Headers: $headers');
          print('Body: ${jsonEncode({'orderId': orderId, 'status': status})}');

          // Пробуем PUT запрос
          response = await http.put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({
              'orderId': int.tryParse(orderId) ?? orderId,
              'status': status
            }),
          );

          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 204) {
            print('✅ Статус заказа успешно обновлен через URL: $url');
            break;
          }

          // Если не 200/204, пробуем POST
          print('PUT не сработал, пробуем POST...');
          response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({
              'orderId': int.tryParse(orderId) ?? orderId,
              'status': status
            }),
          );

          print('POST Status Code: ${response.statusCode}');
          print('POST Response Body: ${response.body}');

          if (response.statusCode == 200 ||
              response.statusCode == 204 ||
              response.statusCode == 201) {
            print('✅ Статус заказа успешно обновлен через POST на URL: $url');
            break;
          }
        } catch (e) {
          print('❌ Ошибка при попытке $url: $e');
          lastException = e is Exception ? e : Exception(e.toString());
          continue;
        }
      }

      if (response == null) {
        throw lastException ??
            Exception(
                'Не удалось выполнить запрос ни к одному из endpoint\'ов');
      }

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Статус заказа успешно обновлен');
        return true;
      } else {
        print(
            '❌ Ошибка обновления статуса: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Ошибка обновления статуса: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Исключение при обновлении статуса: $e');
      throw Exception('Ошибка обновления статуса: $e');
    }
  }

  /// Удаление заказа
  static Future<bool> deleteOrder(String orderId) async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('=== УДАЛЕНИЕ ЗАКАЗА ===');
      print('Order ID: $orderId');
      print('URL: $ORDERS_URL/$orderId');

      final response = await http.delete(
        Uri.parse('$ORDERS_URL/$orderId'),
        headers: headers,
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Заказ успешно удален');
        return true;
      } else {
        print('❌ Ошибка удаления заказа: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Исключение при удалении заказа: $e');
      throw Exception('Ошибка удаления заказа: $e');
    }
  }

  /// Получение информации о товаре по ID
  static Future<Map<String, dynamic>?> getProductById(int productId) async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('=== ПОЛУЧЕНИЕ ТОВАРА ПО ID ===');
      print('Product ID: $productId');
      print('Headers: $headers');

      final response = await http.get(
        Uri.parse('${API_BASE_URL}/products/$productId'),
        headers: headers,
      );

      print('=== ОТВЕТ СЕРВЕРА ДЛЯ ТОВАРА ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== КОНЕЦ ОТВЕТА ДЛЯ ТОВАРА ===');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      } else {
        print('❌ Ошибка получения товара: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Исключение при получении товара: $e');
      return null;
    }
  }
}
