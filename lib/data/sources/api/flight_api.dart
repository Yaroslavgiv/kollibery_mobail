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
  // API: POST /flight/openbox
  // Body: boolean (true - открыть, false - закрыть)
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

    final uri = Uri.parse('${API_BASE_URL}/flight/openbox');
    final body = jsonEncode(isActive);

    print('=== ОТКРЫТИЕ/ЗАКРЫТИЕ БОКСА ДРОНА ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Response Headers: ${response.headers}');

    return response;
  }

  // Функция для проверки работоспособности системы
  static Future<http.Response> systemCheck() async {
    return await http.post(
      Uri.parse('${API_BASE_URL}/flight/systemcheck'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Новая функция для тестового взлёта/посадки на заданную высоту
  // Отправляет только один запрос без повторных попыток
  static Future<http.Response> testSystemCheck({
    required bool isActive,
    required int distance,
  }) async {
    final token = box.read('token');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse(
        '${API_BASE_URL}/test/systemcheck?isActive=$isActive&distance=$distance');
    
    print('=== ВЗЛЁТ/ПОСАДКА ===');
    print('POST $uri');
    print('Headers: $headers');
    print('isActive: $isActive, distance: $distance');
    
    final response = await http.post(uri, headers: headers);
    
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    return response;
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

  // ========== ДРОНБОКС API МЕТОДЫ ==========

  // Управление крышей дронбокса
  // API: POST /api/dron-box/roof
  // Body: boolean (true - открыть, false - закрыть)
  static Future<http.Response> controlRoof(bool isOpen) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/roof');
    final body = jsonEncode(isOpen);
    print('=== УПРАВЛЕНИЕ КРЫШЕЙ ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление позицией дронбокса (центр/край)
  // API: POST /api/dron-box/position
  // Body: boolean (true - в центр, false - в край)
  static Future<http.Response> controlPosition(bool isCenter) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/position');
    final body = jsonEncode(isCenter);
    print('=== УПРАВЛЕНИЕ ПОЗИЦИЕЙ ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление столом дронбокса (вверх/вниз)
  // API: POST /api/dron-box/table
  // Body: boolean (true - вверх, false - вниз)
  static Future<http.Response> controlTable(bool isUp) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/table');
    final body = jsonEncode(isUp);
    print('=== УПРАВЛЕНИЕ СТОЛОМ ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление люком дронбокса
  // API: POST /api/dron-box/hatch (или /dronebox/hatch)
  // Body: boolean (true - открыть, false - закрыть)
  static Future<http.Response> controlHatch(bool isOpen) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/hatch');
    final body = jsonEncode(isOpen);
    print('=== УПРАВЛЕНИЕ ЛЮКОМ ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление батареей дрона в дронбоксе
  // API: POST /api/dron-box/dronebattery (или /dronebox/dronebattery)
  // Body: boolean (true - установить, false - снять)
  static Future<http.Response> controlDroneBattery(bool isInstall) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/dronebattery');
    final body = jsonEncode(isInstall);
    print('=== УПРАВЛЕНИЕ БАТАРЕЕЙ ДРОНА ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление батареей дронбокса (1-3) - установка/снятие
  // API: POST /api/dron-box/battery{batteryNumber}
  // Body: boolean (true - установить, false - снять)
  static Future<http.Response> controlBoxBattery({
    required int batteryNumber, // 1, 2, или 3
    required bool isInstall, // true - установить, false - снять
  }) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/battery$batteryNumber');
    final body = jsonEncode(isInstall);
    print('=== УПРАВЛЕНИЕ БАТАРЕЕЙ $batteryNumber (установка/снятие) ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление зарядкой батареи дрона в дронбоксе
  // API: POST /api/dron-box/dronebattery_charger
  // Body: boolean (true - включить заряд, false - выключить заряд)
  static Future<http.Response> controlDroneBatteryCharger({
    required bool isCharging, // true - включить заряд, false - выключить заряд
  }) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/dronebattery_charger');
    final body = jsonEncode(isCharging);
    print('=== УПРАВЛЕНИЕ ЗАРЯДКОЙ БАТАРЕИ ДРОНА ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление зарядкой батареи дронбокса (1-3)
  // API: POST /api/dron-box/battery{batteryNumber}_charger
  // Body: boolean (true - включить заряд, false - выключить заряд)
  static Future<http.Response> controlBoxBatteryCharger({
    required int batteryNumber, // 1, 2, или 3
    required bool isCharging, // true - включить заряд, false - выключить заряд
  }) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/battery${batteryNumber}_charger');
    final body = jsonEncode(isCharging);
    print('=== УПРАВЛЕНИЕ ЗАРЯДКОЙ БАТАРЕИ $batteryNumber ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Стоп для дронбокса
  // API: POST /api/dron-box/stop
  // Body: boolean (true - остановить)
  static Future<http.Response> droneboxStop() async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/api/dron-box/stop');
    final body = jsonEncode(true); // API требует true в body
    print('=== СТОП ДРОНБОКСА ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    final response = await http.post(uri, headers: headers, body: body);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Управление замком дрона
  static Future<http.Response> controlDroneLock(bool isOpen) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/drone/lock?isOpen=$isOpen');
    print('=== УПРАВЛЕНИЕ ЗАМКОМ ДРОНА ===');
    print('POST $uri');
    print('Headers: $headers');
    final response = await http.post(uri, headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Посадка дрона
  static Future<http.Response> droneLand() async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/drone/land');
    print('=== ПОСАДКА ДРОНА ===');
    print('POST $uri');
    print('Headers: $headers');
    final response = await http.post(uri, headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Старт полета дрона
  static Future<http.Response> droneStartFlight() async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/drone/start');
    print('=== СТАРТ ПОЛЕТА ===');
    print('POST $uri');
    print('Headers: $headers');
    final response = await http.post(uri, headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Отмена полета дрона
  static Future<http.Response> droneCancelFlight() async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('${API_BASE_URL}/drone/cancel');
    print('=== ОТМЕНА ПОЛЕТА ===');
    print('POST $uri');
    print('Headers: $headers');
    final response = await http.post(uri, headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    return response;
  }

  // Подтверждение геолокации продавца при вызове дрона
  // API: POST /flight/confirmneolocation?orderId={orderId}
  // Body: {"latitude": double, "longitude": double, "altitude": 0}
  static Future<http.Response> confirmNeoLocation({
    required int orderId,
    required double latitude,
    required double longitude,
  }) async {
    final token = box.read('token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse('${API_BASE_URL}/flight/confirmneolocation?orderId=$orderId');
    final body = jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
      'altitude': 0, // Всегда 0 согласно документации
    });

    print('=== ПОДТВЕРЖДЕНИЕ ГЕОЛОКАЦИИ ПРОДАВЦА ===');
    print('POST $uri');
    print('Headers: $headers');
    print('Body: $body');
    print('OrderId: $orderId');
    print('Latitude: $latitude, Longitude: $longitude');

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    return response;
  }
}
