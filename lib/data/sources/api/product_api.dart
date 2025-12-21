import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../features/home/models/product_model.dart';

class ProductApi {
  static final GetStorage _storage = GetStorage();

  static Future<List<ProductModel>> fetchProducts() async {
    final token = _storage.read('token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse(PRODUCTS_URL),
      headers: headers,
    );
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

  /// Получить userId из хранилища
  static String? _getUserId() {
    final userId = _storage.read('userId');
    print('🔍 Проверка userId в хранилище: $userId (тип: ${userId.runtimeType})');
    
    if (userId != null) {
      final userIdString = userId.toString();
      print('✅ userId найден: $userIdString');
      return userIdString;
    }
    
    print('❌ userId не найден в хранилище');
    print('📋 Содержимое хранилища:');
    print('   - loggedIn: ${_storage.read('loggedIn')}');
    print('   - token: ${_storage.read('token') != null ? "есть" : "нет"}');
    print('   - email: ${_storage.read('email')}');
    print('   - role: ${_storage.read('role')}');
    
    return null;
  }

  /// Добавление товара через /order/creatproduct
  static Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) async {
    try {
      final token = _storage.read('token');
      final loggedIn = _storage.read('loggedIn') ?? false;
      var userId = _getUserId();
      
      // Проверяем авторизацию
      print('🔐 Проверка авторизации:');
      print('   - loggedIn: $loggedIn');
      print('   - token: ${token != null ? "есть" : "нет"}');
      print('   - userId: $userId');
      
      if (!loggedIn || token == null) {
        print('❌ Пользователь не авторизован');
        throw Exception('Пользователь не авторизован. Пожалуйста, войдите в систему.');
      }
      
      if (userId == null) {
        print('❌ userId не найден, но пользователь авторизован');
        print('💡 Попытка получить userId из токена...');
        
        // Пробуем получить userId из токена (если это JWT)
        try {
          print('🔑 Анализ токена:');
          print('   - Длина токена: ${token.length}');
          print('   - Первые 50 символов: ${token.substring(0, token.length > 50 ? 50 : token.length)}...');
          
          final parts = token.split('.');
          print('   - Количество частей после split(.): ${parts.length}');
          
          if (parts.length == 3) {
            print('   - Это JWT токен, декодируем payload...');
            // Это JWT токен, пробуем декодировать payload
            final payload = parts[1];
            print('   - Payload (первые 50 символов): ${payload.substring(0, payload.length > 50 ? 50 : payload.length)}...');
            
            // Добавляем padding если нужно
            String normalizedPayload = payload;
            switch (payload.length % 4) {
              case 1:
                normalizedPayload += '===';
                break;
              case 2:
                normalizedPayload += '==';
                break;
              case 3:
                normalizedPayload += '=';
                break;
            }
            
            try {
              final decoded = utf8.decode(base64Url.decode(normalizedPayload));
              print('   - Payload декодирован успешно');
              print('   - Декодированный payload: $decoded');
              
              final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
              print('   - Ключи в payload: ${payloadMap.keys.toList()}');
              
              if (payloadMap['userId'] != null) {
                userId = payloadMap['userId'].toString();
                print('✅ userId получен из токена: $userId');
                // Сохраняем для будущего использования
                _storage.write('userId', userId);
              } else if (payloadMap['sub'] != null) {
                userId = payloadMap['sub'].toString();
                print('✅ userId получен из токена (sub): $userId');
                _storage.write('userId', userId);
              } else if (payloadMap['id'] != null) {
                userId = payloadMap['id'].toString();
                print('✅ userId получен из токена (id): $userId');
                _storage.write('userId', userId);
              } else if (payloadMap['nameid'] != null) {
                // Используем nameid (email) как идентификатор
                userId = payloadMap['nameid'].toString();
                print('✅ Используем nameid (email) из токена как userId: $userId');
                _storage.write('userId', userId);
              } else if (payloadMap['unique_name'] != null) {
                // Используем unique_name (email) как идентификатор
                userId = payloadMap['unique_name'].toString();
                print('✅ Используем unique_name (email) из токена как userId: $userId');
                _storage.write('userId', userId);
              } else {
                print('⚠️ userId, sub, id, nameid и unique_name не найдены в payload токена');
              }
            } catch (decodeError) {
              print('❌ Ошибка декодирования base64: $decodeError');
            }
          } else {
            print('⚠️ Токен не является JWT (не 3 части, а ${parts.length})');
          }
        } catch (e) {
          print('❌ Не удалось декодировать токен: $e');
          print('   Stack trace: ${StackTrace.current}');
        }
        
        // Если userId все еще не найден, используем email как идентификатор
        if (userId == null) {
          print('💡 userId не найден, используем email как идентификатор...');
          final email = _storage.read('email');
          if (email != null) {
            userId = email;
            print('✅ Используем email как userId: $userId');
            // Сохраняем email как userId для будущего использования
            _storage.write('userId', userId);
          } else {
            throw Exception('Не удалось определить пользователя. Пожалуйста, перезайдите в систему.');
          }
        }
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Формируем тело запроса согласно формату API
      // Сервер может определить userId из токена, поэтому пробуем без userId
      // Если не сработает, попробуем с userId
      final requestBody = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        'quantityInStock': quantityInStock,
        'category': category,
        'image': image,
      };
      
      // Если userId является UUID (не email), добавляем его
      // UUID имеет формат: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      final uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
      if (userId != null && uuidPattern.hasMatch(userId)) {
        requestBody['userId'] = userId;
        print('✅ userId (UUID) добавлен в запрос: $userId');
      } else {
        print('⚠️ userId не является UUID, сервер должен определить его из токена');
        print('   - userId: $userId');
      }

      print('=== ДОБАВЛЕНИЕ ТОВАРА ===');
      print('URL: $CREATE_PRODUCT_URL');
      print('Headers: $headers');
      print('Body: $requestBody');
      print('userId (тип: ${userId.runtimeType}): $userId');

      final response = await http.post(
        Uri.parse(CREATE_PRODUCT_URL),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('=== ОТВЕТ СЕРВЕРА ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('=== КОНЕЦ ОТВЕТА СЕРВЕРА ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Товар успешно добавлен');
        return true;
      } else {
        print('❌ Ошибка добавления товара: ${response.statusCode}');
        print('📋 Детали ошибки:');
        print('   - Request URL: $CREATE_PRODUCT_URL');
        print('   - Request Body: ${jsonEncode(requestBody)}');
        print('   - Response: ${response.body}');
        
        // Пробуем распарсить ответ как JSON для более детальной информации
        try {
          final errorData = jsonDecode(response.body);
          print('   - Parsed Error: $errorData');
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception('Ошибка добавления товара: ${errorData['message']}');
          } else if (errorData is Map && errorData.containsKey('error')) {
            throw Exception('Ошибка добавления товара: ${errorData['error']}');
          }
        } catch (e) {
          // Если не удалось распарсить, используем стандартное сообщение
        }
        
        throw Exception('Ошибка добавления товара: ${response.statusCode}. Ответ сервера: ${response.body}');
      }
    } catch (e) {
      print('❌ Исключение при добавлении товара: $e');
      throw Exception('Ошибка добавления товара: $e');
    }
  }

  /// Редактирование товара через /order/placeorder (PUT запрос)
  static Future<bool> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int quantityInStock,
    required String category,
    required String image,
  }) async {
    try {
      final token = _storage.read('token');
      final loggedIn = _storage.read('loggedIn') ?? false;
      var userId = _getUserId();
      
      // Проверяем авторизацию
      if (!loggedIn || token == null) {
        throw Exception('Пользователь не авторизован. Пожалуйста, войдите в систему.');
      }
      
      // Если userId не найден, пробуем получить из токена или использовать email
      if (userId == null) {
        // Пробуем получить userId из токена (аналогично addProduct)
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            String normalizedPayload = payload;
            switch (payload.length % 4) {
              case 1: normalizedPayload += '==='; break;
              case 2: normalizedPayload += '=='; break;
              case 3: normalizedPayload += '='; break;
            }
            final decoded = utf8.decode(base64Url.decode(normalizedPayload));
            final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
            
            if (payloadMap['nameid'] != null) {
              userId = payloadMap['nameid'].toString();
              _storage.write('userId', userId);
            } else if (payloadMap['unique_name'] != null) {
              userId = payloadMap['unique_name'].toString();
              _storage.write('userId', userId);
            }
          }
        } catch (e) {
          // Игнорируем ошибки декодирования
        }
        
        // Если все еще null, используем email
        if (userId == null) {
          final email = _storage.read('email');
          if (email != null) {
            userId = email;
            _storage.write('userId', userId);
          } else {
            throw Exception('Не удалось определить пользователя. Пожалуйста, перезайдите в систему.');
          }
        }
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final requestBody = {
        'productId': productId,
        'userId': userId,
        'name': name,
        'description': description,
        'price': price,
        'quantityInStock': quantityInStock,
        'category': category,
        'image': image,
      };

      print('=== РЕДАКТИРОВАНИЕ ТОВАРА ===');
      print('URL: $PLACE_ORDER_URL');
      print('Product ID: $productId');
      print('Name: $name');
      print('Image присутствует: ${image.isNotEmpty}');
      if (image.isNotEmpty) {
        final imageLength = image.length;
        final imagePreview = image.length > 100 
            ? '${image.substring(0, 100)}...' 
            : image;
        print('   - Длина image: $imageLength символов');
        print('   - Первые 100 символов: $imagePreview');
      } else {
        print('   ⚠️ ВНИМАНИЕ: image пустое!');
      }
      print('Body (без image): ${{
        'productId': productId,
        'userId': userId,
        'name': name,
        'description': description,
        'price': price,
        'quantityInStock': quantityInStock,
        'category': category,
      }}');

      // Пробуем PUT запрос
      var response = await http.put(
        Uri.parse(PLACE_ORDER_URL),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Если PUT не работает, пробуем POST
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('PUT не сработал, пробуем POST...');
        response = await http.post(
          Uri.parse(PLACE_ORDER_URL),
          headers: headers,
          body: jsonEncode(requestBody),
        );
      }

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Товар успешно обновлен');
        return true;
      } else {
        print('❌ Ошибка обновления товара: ${response.statusCode}');
        throw Exception('Ошибка обновления товара: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Исключение при обновлении товара: $e');
      throw Exception('Ошибка обновления товара: $e');
    }
  }

  /// Удаление товара через /order/deleteproduct/{productId}
  static Future<bool> deleteProduct(int productId) async {
    try {
      final token = _storage.read('token');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url = '$DELETE_PRODUCT_URL/$productId';

      print('=== УДАЛЕНИЕ ТОВАРА ===');
      print('URL: $url');
      print('Product ID: $productId');

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Товар успешно удален');
        return true;
      } else {
        print('❌ Ошибка удаления товара: ${response.statusCode}');
        throw Exception('Ошибка удаления товара: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Исключение при удалении товара: $e');
      throw Exception('Ошибка удаления товара: $e');
    }
  }
}
