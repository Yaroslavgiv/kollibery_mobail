import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../../utils/constants/api_constants.dart';

class FlightApi {
  static final box = GetStorage();

  static Future<http.Response> sendOrderLocation({
    Map<String, double>? sellerPoint,
    Map<String, double>? buyerPoint,
    Map<String, double>? startPoint,
    List<Map<String, double>>? waypoints, // Промежуточные точки маршрута
    String? orderId, // ID заказа (опционально)
  }) async {
    // Получаем токен из локального хранилища
    final token = box.read('token');
    
    // Формируем заголовки с авторизацией
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    final Map<String, dynamic> body = {};
    
    // Если переданы все точки маршрута (старт + промежуточные + финиш),
    // отправляем их в массиве waypoints (используем тот же формат, что и testAutopilotWithWaypoints)
    if (startPoint != null && buyerPoint != null) {
      final List<Map<String, double>> allPoints = [];
      
      // Добавляем точку старта (используем Map<String, double> как в рабочем методе)
      final startLat = startPoint['latitude']?.toDouble() ?? 0.0;
      final startLon = startPoint['longitude']?.toDouble() ?? 0.0;
      allPoints.add({
        'latitude': startLat,
        'longitude': startLon,
      });
      
      // Добавляем промежуточные точки
      if (waypoints != null && waypoints.isNotEmpty) {
        for (var point in waypoints) {
          final lat = point['latitude']?.toDouble() ?? 0.0;
          final lon = point['longitude']?.toDouble() ?? 0.0;
          allPoints.add({
            'latitude': lat,
            'longitude': lon,
          });
        }
      }
      
      // Добавляем точку финиша
      final endLat = buyerPoint['latitude']?.toDouble() ?? 0.0;
      final endLon = buyerPoint['longitude']?.toDouble() ?? 0.0;
      allPoints.add({
        'latitude': endLat,
        'longitude': endLon,
      });
      
      // Проверяем, что массив не пустой
      if (allPoints.isEmpty) {
        throw Exception('Массив точек маршрута не может быть пустым');
      }
      
      // Отправляем все точки в массиве (точно такой же формат, как в testAutopilotWithWaypoints)
      // Используем только waypoints, без дополнительных полей, чтобы формат совпадал с рабочим методом
      body['waypoints'] = allPoints;
    } else {
      // Старый формат для обратной совместимости
      if (startPoint != null) {
        body['startPoint'] = startPoint;
      }
      if (sellerPoint != null) {
        body['sellerPoint'] = sellerPoint;
      }
      if (waypoints != null && waypoints.isNotEmpty) {
        body['waypoints'] = waypoints;
      }
      if (buyerPoint != null) {
        body['buyerPoint'] = buyerPoint;
      }
    }
    
    // Валидация данных перед отправкой
    if (body.isEmpty) {
      throw Exception('Тело запроса не может быть пустым');
    }
    
    if (body.containsKey('waypoints')) {
      final waypointsList = body['waypoints'] as List;
      if (waypointsList.isEmpty) {
        throw Exception('Массив waypoints не может быть пустым');
      }
      print('Количество точек в маршруте: ${waypointsList.length}');
      for (int i = 0; i < waypointsList.length; i++) {
        final point = waypointsList[i] as Map;
        print('Точка $i: lat=${point['latitude']}, lng=${point['longitude']}');
      }
    }
    
    final bodyJson = jsonEncode(body);
    final endpointUrl = '${API_BASE_URL}/test/testautopilot';
    print('=== Отправка точек маршрута в /test/testautopilot ===');
    print('URL: $endpointUrl');
    print('Headers: $headers');
    print('Body: $bodyJson');
    print('Body length: ${bodyJson.length} bytes');
    print('Token present: ${token != null}');
    
    try {
      final uri = Uri.parse(endpointUrl);
      print('Parsed URI: $uri');
      
      final response = await http.post(
        uri,
        headers: headers,
        body: bodyJson,
      );
      
      print('=== Ответ сервера ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('Response Body length: ${response.body.length} bytes');
      
      // Если получили ошибку, выводим дополнительную информацию
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('=== ОШИБКА ОТВЕТА ===');
        print('Возможно, данные не дошли до сервера или формат неверный');
        print('Проверьте логи на сервере');
      }
      
      return response;
    } catch (e, stackTrace) {
      print('=== Ошибка при отправке запроса ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Функция для открытия/закрытия бокса дрона
  static Future<http.Response> openDroneBox(bool isActive) async {
    // Получаем токен из локального хранилища
    final token = box.read('token');

    // Формируем заголовки с авторизацией
    final headers = {
      'Content-Type': 'application/json',
    };

    // Добавляем токен, если он есть
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    print('Отправляем запрос с заголовками: $headers');
    print('URL: ${API_BASE_URL}/flight/openbox?isActive=$isActive');

    return await http.post(
      Uri.parse('${API_BASE_URL}/flight/openbox?isActive=$isActive'),
      headers: headers,
    );
  }

  // Функция для проверки работоспособности системы
  static Future<http.Response> systemCheck() async {
    return await http.post(
      Uri.parse('${API_BASE_URL}/flight/systemcheck'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Новая функция для тестового взлёта/посадки на заданную высоту
  static Future<http.Response> testSystemCheck({
    required bool isActive,
    required int distance,
  }) async {
    final token = box.read('token');

    final Map<String, String> headersAuth = {};
    if (token != null) {
      headersAuth['Authorization'] = 'Bearer $token';
    }
    final Map<String, String> headersNoAuth = {};

    final uriTest = Uri.parse(
        '${API_BASE_URL}/test/systemcheck?isActive=$isActive&distance=$distance');
    http.Response resp;

    // Attempt 1: POST with Authorization (если есть)
    print('POST $uriTest');
    print('Headers: $headersAuth');
    resp = await http.post(uriTest, headers: headersAuth);
    print('Attempt#1 status: ${resp.statusCode}');

    bool shouldRetry = resp.statusCode < 200 || resp.statusCode >= 300;
    if (shouldRetry) {
      // Attempt 2: POST без Authorization
      print('Retry Attempt#2: POST (no auth) $uriTest');
      resp = await http.post(uriTest, headers: headersNoAuth);
      print('Attempt#2 status: ${resp.statusCode}');
    }

    shouldRetry = resp.statusCode < 200 || resp.statusCode >= 300;
    if (shouldRetry) {
      // Attempt 3: GET на тот же эндпоинт
      print('Retry Attempt#3: GET $uriTest');
      resp = await http.get(uriTest, headers: headersAuth);
      print('Attempt#3 status: ${resp.statusCode}');
    }

    shouldRetry = resp.statusCode < 200 || resp.statusCode >= 300;
    if (shouldRetry) {
      // Attempt 4: запасной маршрут /flight/systemcheck
      final uriFlight = Uri.parse(
          '${API_BASE_URL}/flight/systemcheck?isActive=$isActive&distance=$distance');
      print('Retry Attempt#4: POST $uriFlight');
      resp = await http.post(uriFlight, headers: headersAuth);
      print('Attempt#4 status: ${resp.statusCode}');
    }

    shouldRetry = resp.statusCode < 200 || resp.statusCode >= 300;
    if (shouldRetry) {
      // Attempt 5: POST form-urlencoded body на /test/systemcheck
      final uriForm = Uri.parse('${API_BASE_URL}/test/systemcheck');
      final Map<String, String> headersForm = {
        ...headersAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      final bodyForm = {
        'isActive': isActive.toString(),
        'distance': distance.toString(),
      };
      print('Retry Attempt#5: POST form $uriForm');
      resp = await http.post(uriForm, headers: headersForm, body: bodyForm);
      print('Attempt#5 status: ${resp.statusCode}');
    }

    shouldRetry = resp.statusCode < 200 || resp.statusCode >= 300;
    if (shouldRetry) {
      // Attempt 6: POST JSON body на /test/systemcheck
      final uriJson = Uri.parse('${API_BASE_URL}/test/systemcheck');
      final Map<String, String> headersJson = {
        ...headersAuth,
        'Content-Type': 'application/json',
      };
      final bodyJson = jsonEncode({
        'isActive': isActive,
        'distance': distance,
      });
      print('Retry Attempt#6: POST json $uriJson');
      resp = await http.post(uriJson, headers: headersJson, body: bodyJson);
      print('Attempt#6 status: ${resp.statusCode}');
    }

    shouldRetry = resp.statusCode < 200 || resp.statusCode >= 300;
    if (shouldRetry) {
      // Attempt 7: POST с косой чертой
      final uriSlash = Uri.parse(
          '${API_BASE_URL}/test/systemcheck/?isActive=$isActive&distance=$distance');
      print('Retry Attempt#7: POST (trailing slash) $uriSlash');
      resp = await http.post(uriSlash, headers: headersAuth);
      print('Attempt#7 status: ${resp.statusCode}');
    }

    return resp;
  }

  // Тестирование подсветки дрона: colorNumber (0-выкл, 1-зелёный, 2-красный)
  static Future<http.Response> testBacklight({
    required int colorNumber,
  }) async {
    final token = box.read('token');
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse(
        '${API_BASE_URL}/test/backlighttesting?colorNumber=$colorNumber');
    print('POST $uri');
    print('Headers: $headers');
    return await http.post(uri, headers: headers);
  }

  // Тестирование автопилота по координатам
  static Future<http.Response> testAutopilot({
    required double latitude,
    required double longitude,
  }) async {
    final token = box.read('token');
    final Map<String, String> headers = {};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse(
        '${API_BASE_URL}/test/testautopilot?latitude=$latitude&longitude=$longitude');
    print('POST $uri');
    print('Headers: $headers');
    return await http.post(uri, headers: headers);
  }

  // Тестирование автопилота с промежуточными точками (waypoints)
  // Если API не поддерживает массив точек, отправляет их последовательно
  static Future<http.Response> testAutopilotWithWaypoints({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
    List<Map<String, double>>?
        waypoints, // Промежуточные точки: [{"latitude": 0.0, "longitude": 0.0}]
  }) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Формируем тело запроса с массивом точек
    final List<Map<String, double>> allPoints = [];

    // Добавляем точку старта
    allPoints.add({
      'latitude': startLatitude,
      'longitude': startLongitude,
    });

    // Добавляем промежуточные точки
    if (waypoints != null && waypoints.isNotEmpty) {
      allPoints.addAll(waypoints);
    }

    // Добавляем точку назначения
    allPoints.add({
      'latitude': endLatitude,
      'longitude': endLongitude,
    });

    final body = jsonEncode({
      'waypoints': allPoints,
    });

    // Пробуем отправить массивом через JSON body
    final uri = Uri.parse('${API_BASE_URL}/test/testautopilot');
    print('POST $uri (with waypoints)');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    // Если не поддерживается массивом, отправляем последовательно
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('Массив точек не поддерживается, отправляем последовательно...');
      // Отправляем точки последовательно, начиная с точки назначения
      return await testAutopilot(
        latitude: endLatitude,
        longitude: endLongitude,
      );
    }

    return response;
  }

  // Экстренная остановка дрона
  static Future<http.Response> emergencyStop() async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/flight/emergency');
    print('=== ЭКСТРЕННАЯ ОСТАНОВКА ===');
    print('POST $uri');
    print('Headers: $headers');
    final response = await http.post(uri, headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Возвращение дрона на базу
  static Future<http.Response> returnToHome() async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/test/home');
    print('=== ВОЗВРАЩЕНИЕ НА БАЗУ ===');
    print('POST $uri');
    print('Headers: $headers');
    final response = await http.post(uri, headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }
}
