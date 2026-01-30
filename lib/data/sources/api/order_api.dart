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

  /// Получение последних 5 заказов (история) с обогащением товарами
  static Future<List<Map<String, dynamic>>> fetchLastFiveOrders() async {
    try {
      final token = _storage.read('token');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('=== ПОЛУЧЕНИЕ ПОСЛЕДНИХ 5 ЗАКАЗОВ ===');

      final response = await http.get(
        Uri.parse(LAST_FIVE_ORDERS_URL),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is! List) {
          print('❌ Неверный формат ответа истории (ожидался List)');
          return [];
        }

        final List<Map<String, dynamic>> enrichedOrders = [];

        // Загружаем все товары один раз и строим карту по id
        final productsMap = await _fetchAllProductsMap();

        for (final orderData in body) {
          if (orderData is! Map<String, dynamic>) {
            continue;
          }
          final productId = orderData['productId'];

          if (productId != null && productsMap.containsKey(productId)) {
            final productInfo = productsMap[productId]!;
            final enrichedOrder = {
              ...orderData,
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
            enrichedOrders.add(orderData);
          }
        }

        print('✅ Получено ${enrichedOrders.length} заказов истории');
        return enrichedOrders;
      } else {
        throw Exception(
            'Ошибка загрузки истории заказов: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Исключение при получении истории заказов: $e');
      return [];
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

      // Получаем информацию о товаре для проверки
      final productsMap = await _fetchAllProductsMap();
      final productInfo = productsMap[productId];
      final productSellerId = productInfo?['userId'];
      final productName = productInfo?['name'] ?? 'Неизвестный товар';

      print('=== ОТПРАВКА ЗАКАЗА НА СЕРВЕР ===');
      print('URL: $PLACE_ORDER_URL');
      print('Headers: $headers');
      print('Request Body: $requestBody');
      print('📦 Информация о товаре:');
      print('   - productId: $productId');
      print('   - Название товара: $productName');
      if (productSellerId != null) {
        print('   - sellerId (из продукта): $productSellerId');
        print('   ✅ Товар найден в базе, продавец: $productSellerId');
      } else {
        print('   ⚠️ ВНИМАНИЕ: Товар не найден в базе продуктов!');
        print('   ⚠️ Бэкенд не сможет определить продавца по productId');
      }
      print('⚠️ ВНИМАНИЕ: sellerId не передается в запросе!');
      print(
          '   Бэкенд должен определить продавца по productId и сохранить связь заказа с продавцом');
      print('   Ожидаемое поведение бэкенда:');
      print('   1. Найти товар по productId=$productId');
      if (productSellerId != null) {
        print('   2. Определить sellerId=$productSellerId из product.userId');
      } else {
        print(
            '   2. Определить sellerId из product.userId (товар не найден в локальной карте)');
      }
      print('   3. Сохранить заказ с связью к продавцу в БД');
      print(
          '   4. При запросе GET /order/getorders?role=seller вернуть заказ для этого продавца');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Заказ успешно создан на сервере!');
        if (productSellerId != null) {
          print('💡 Важно: Проверьте, что бэкенд:');
          print(
              '   1. Определил sellerId=$productSellerId по productId=$productId');
          print('   2. Сохранил связь заказа с продавцом в БД');
          print(
              '   3. При запросе /order/getorders?role=seller вернет этот заказ для продавца $productSellerId');
        } else {
          print('⚠️ ВНИМАНИЕ: Не удалось определить sellerId из продукта!');
          print(
              '   Бэкенд должен сам определить продавца по productId=$productId');
        }
      } else {
        print('❌ Ошибка создания заказа!');
        print('   Status Code: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
      print('=== КОНЕЦ ОТВЕТА СЕРВЕРА ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Пытаемся распарсить ответ, чтобы получить ID созданного заказа и проверить sellerId
        try {
          final responseBody = response.body;
          if (responseBody.isNotEmpty) {
            final responseData = jsonDecode(responseBody);
            print('📦 Ответ сервера содержит данные: $responseData');
            if (responseData is Map) {
              final orderId = responseData['id'] ?? responseData['orderId'];
              final responseSellerId =
                  responseData['sellerId'] ?? responseData['seller_id'];

              if (orderId != null) {
                print('✅ Заказ успешно размещен! ID заказа: $orderId');
              } else {
                print('✅ Заказ успешно размещен! (ID не указан в ответе)');
              }

              // Проверяем, вернул ли бэкенд sellerId в ответе
              if (responseSellerId != null) {
                print('✅ Бэкенд вернул sellerId в ответе: $responseSellerId');
                if (productSellerId != null) {
                  if (responseSellerId.toString() ==
                      productSellerId.toString()) {
                    print(
                        '✅ sellerId из ответа совпадает с sellerId из продукта');
                  } else {
                    print(
                        '⚠️ ВНИМАНИЕ: sellerId из ответа ($responseSellerId) не совпадает с sellerId из продукта ($productSellerId)');
                  }
                }
              } else {
                print('⚠️ Бэкенд НЕ вернул sellerId в ответе');
                print(
                    '💡 Проверьте, что бэкенд определяет sellerId по productId и сохраняет связь');
              }
            } else {
              print('✅ Заказ успешно размещен! (ответ не является объектом)');
            }
          } else {
            print('✅ Заказ успешно размещен! (пустой ответ)');
            print('⚠️ Бэкенд не вернул данные о созданном заказе');
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

      // Для продавца логируем информацию о текущем пользователе
      if (role == 'seller') {
        final currentUserId = _storage.read('userId');
        final currentRole = _storage.read('role');
        print('🔍 Информация о текущем пользователе:');
        print('   - userId: $currentUserId');
        print('   - role: $currentRole');
        print('   - token присутствует: ${token != null}');
        if (token != null) {
          print('   - token длина: ${token.length} символов');
        }
        print('💡 Бэкенд должен определить текущего пользователя из токена');
        print(
            '💡 И вернуть только заказы, где товар принадлежит этому продавцу');
      }

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

        // Для продавца проверяем, что заказы действительно пришли
        if (role == 'seller') {
          print('🔍 ДИАГНОСТИКА ЗАКАЗОВ ПРОДАВЦА:');
          print('   - Количество заказов с сервера: ${ordersData.length}');
          if (ordersData.isEmpty) {
            print('   ⚠️ ВНИМАНИЕ: Бэкенд вернул пустой список заказов!');
            print('   💡 Возможные причины:');
            print('      1. Покупатель еще не создал заказ');
            print(
                '      2. Бэкенд не связывает заказ с продавцом при создании');
            print('      3. Фильтрация по роли "seller" работает неправильно');
            print(
                '      4. Токен не содержит правильную информацию о продавце');
          } else {
            print('   📋 Список заказов с сервера:');
            for (var i = 0; i < ordersData.length; i++) {
              final order = ordersData[i] as Map<String, dynamic>;
              print(
                  '      ${i + 1}. Заказ ID: ${order['id']}, productId: ${order['productId']}');
            }
          }
        }

        final List<Map<String, dynamic>> enrichedOrders = [];

        // Загружаем все товары один раз и строим карту по id
        final productsMap = await _fetchAllProductsMap();
        print(
            '📦 Загружено ${productsMap.length} товаров для обогащения заказов');

        // Для каждого заказа берём информацию о товаре из карты
        for (final orderData in ordersData) {
          final order = orderData as Map<String, dynamic>;
          final productId = order['productId'];
          final orderId = order['id'];
          final createdAt = order['createdAt'];
          final updatedAt = order['updatedAt'];

          print('📋 Обработка заказа ID: $orderId, productId: $productId');
          print(
              '   🔍 id и productId пришли с сервера: id=${orderId.runtimeType}=$orderId, productId=${productId.runtimeType}=$productId');
          print('   📅 createdAt: $createdAt (тип: ${createdAt.runtimeType})');
          print('   📅 updatedAt: $updatedAt (тип: ${updatedAt.runtimeType})');

          if (productId != null && productsMap.containsKey(productId)) {
            final productInfo = productsMap[productId]!;
            final productSellerId = productInfo['userId'];
            print('  ✅ Товар найден. sellerId (из продукта): $productSellerId');

            // Для продавца логируем информацию о принадлежности товара (только для диагностики)
            if (role == 'seller') {
              final currentUserId = _storage.read('userId');
              print('  🔍 Диагностика принадлежности товара продавцу:');
              print('     - sellerId из продукта: $productSellerId');
              print('     - userId текущего пользователя: $currentUserId');
              if (productSellerId != null && currentUserId != null) {
                final currentUserIdStr = currentUserId.toString().trim();
                final productSellerIdStr = productSellerId.toString().trim();
                if (currentUserIdStr == productSellerIdStr) {
                  print('     ✅ Товар принадлежит текущему продавцу');
                } else {
                  print(
                      '     ⚠️ ВНИМАНИЕ: Товар принадлежит другому продавцу!');
                  print('        - Текущий продавец: "$currentUserIdStr"');
                  print('        - Продавец товара: "$productSellerIdStr"');
                  print(
                      '     💡 ВАЖНО: Бэкенд должен фильтровать заказы, включаем заказ для проверки');
                }
              } else {
                print('     ⚠️ Не удалось проверить принадлежность товара');
                print('        - currentUserId: $currentUserId');
                print('        - productSellerId: $productSellerId');
              }
            }

            // ВАЖНО: НЕ фильтруем заказы на клиенте - полагаемся на фильтрацию бэкенда
            // Бэкенд должен возвращать только заказы текущего продавца при role=seller
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
            // Включаем заказ даже если товар не найден в локальной карте
            // Бэкенд должен фильтровать заказы по продавцу
            if (role == 'seller') {
              print(
                  '     ⚠️ Товар не найден в локальной базе, но включаем заказ');
              print('     💡 Бэкенд должен фильтровать заказы по продавцу');
              print(
                  '     💡 Если заказ отображается, значит бэкенд вернул его для текущего продавца');
            }
            enrichedOrders.add(order);
          }
        }

        print(
            '✅ Получено ${enrichedOrders.length} заказов для роли $role с информацией о товарах');

        // Для продавца выводим итоговую статистику
        if (role == 'seller') {
          print('📊 ИТОГОВАЯ СТАТИСТИКА ДЛЯ ПРОДАВЦА:');
          print('   - Заказов получено с сервера: ${ordersData.length}');
          print(
              '   - Заказов после обогащения данными: ${enrichedOrders.length}');
          if (enrichedOrders.isEmpty && ordersData.isNotEmpty) {
            print(
                '   ⚠️ ВНИМАНИЕ: Заказы получены с сервера, но не обогащены данными!');
            print('   💡 Проверьте логи выше для деталей');
          } else if (enrichedOrders.isEmpty && ordersData.isEmpty) {
            print('   💡 Нет заказов с сервера - возможно:');
            print('      1. Покупатель еще не создал заказ');
            print(
                '      2. Бэкенд не связывает заказ с продавцом при создании');
            print('      3. Бэкенд не фильтрует заказы по текущему продавцу');
            print(
                '      4. Токен не содержит правильную информацию о продавце');
          } else {
            print(
                '   ✅ Получено ${enrichedOrders.length} заказов для отображения');
            print('   💡 ВАЖНО: Бэкенд должен фильтровать заказы по продавцу');
            print('   💡 Если отображаются чужие заказы - проблема на бэкенде');
          }
        }

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

      // Используем новый эндпоинт /order/deleteorder/{orderId}
      final url = '$DELETE_ORDER_URL/$orderId';

      print('=== УДАЛЕНИЕ ЗАКАЗА ===');
      print('Order ID: $orderId');
      print('URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Заказ успешно удален (сервер ответил ${response.statusCode})');
        print(
            '🔍 ДИАГНОСТИКА: Если заказ всё ещё виден в списке — бэкенд GET /order/getorders отдаёт удалённые заказы (проблема на сервере).');
        return true;
      } else {
        final msg =
            'Сервер вернул ${response.statusCode}. Тело: ${response.body.isNotEmpty ? response.body : "пусто"}';
        print('❌ Ошибка удаления заказа: $msg');
        print(
            '🔍 ДИАГНОСТИКА: Ошибка на сервере — эндпоинт DELETE /order/deleteorder/{orderId} не сработал.');
        throw Exception('Ошибка удаления заказа: $msg');
      }
    } catch (e) {
      print('❌ Исключение при удалении заказа: $e');
      rethrow;
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
