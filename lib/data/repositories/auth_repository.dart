import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/constants/api_constants.dart';
import '../../features/home/models/product_model.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: API_BASE_URL,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  ));

  /// Регистрация
  /// POST /account/register
  /// Тело: { "firstName": "...", "lastName": "...", "email": "...", "password": "...", "confirmPassword": "...", "role": "..." }
  Future<void> register(String firstName, String lastName, String email,
      String password, String confirmPassword, String role) async {
    try {
      final response = await _dio.post(
        '/account/register',
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "confirmPassword": confirmPassword,
          "role": role,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Ошибка регистрации. Код: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Неверные данные для регистрации.');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Пользователь с таким email уже существует.');
      } else {
        throw Exception('Ошибка при регистрации: ${e.message}');
      }
    }
  }

  /// Логин
  /// POST /account/login
  /// Тело: { "email": "...", "password": "..." }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/account/login',
        data: {
          "email": email,
          "password": password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Ошибка логина. Код: ${response.statusCode}');
      }

      // Отладочная информация по ответу сервера
      print('📥 API /account/login:');
      print('   - statusCode: ${response.statusCode}');
      print('   - data: ${response.data}');

      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Неверный email или пароль.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Пользователь не найден.');
      } else {
        throw Exception('Ошибка при логине: ${e.message}');
      }
    }
  }

  /// Обновление профиля пользователя
  /// PUT /account/updateProfile или POST /account/updateProfile
  /// Тело: { "firstName": "...", "lastName": "...", "email": "...", "phone": "..." }
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) async {
    try {
      // Получаем токен из хранилища
      final box = GetStorage();
      final token = box.read<String>('token');
      final role = box.read<String>('role') ?? 'unknown';
      
      print('📤 API: Обновление профиля');
      print('   - Базовый URL: ${_dio.options.baseUrl}');
      print('   - Роль: $role');
      print('   - Токен: ${token != null ? "есть (${token.length} символов)" : "отсутствует"}');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('Токен авторизации отсутствует. Пожалуйста, войдите в систему заново.');
      }

      final requestData = {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        if (phone != null && phone.isNotEmpty) "phone": phone,
      };
      
      print('   - Данные запроса: $requestData');
      print('   - Заголовки: ${headers.keys.toList()}');

      // Получаем userId для возможного использования в пути
      final userId = box.read<String>('userId');
      print('   - userId: ${userId ?? "не найден"}');
      
      // Пробуем несколько вариантов эндпоинтов
      // Основной вариант - PUT /account/profile (стандартный REST)
      final endpointsToTry = <String>[
        '/account/profile',        // Вариант 1: стандартный REST (PUT /account/profile) - основной
        '/account/user',           // Вариант 2: если сервер использует /account/user
      ];
      
      // Если есть userId, добавляем варианты с userId
      if (userId != null && userId.isNotEmpty) {
        endpointsToTry.addAll([
          '/account/profile/$userId',  // Вариант с userId в пути
          '/account/$userId/profile',  // Альтернативный вариант с userId
        ]);
      }
      
      // Добавляем другие варианты
      endpointsToTry.addAll([
        '/account/updateProfile',  // Явный updateProfile
        '/account/update',         // Короткий вариант
        '/account/editProfile',    // Альтернативный вариант
        '/account/edit',           // Еще один вариант
      ]);

      DioException? lastException;
      
      for (final endpoint in endpointsToTry) {
        try {
          print('   - Пробуем эндпоинт: PUT $endpoint');
          
          final response = await _dio.put(
            endpoint,
            data: requestData,
            options: Options(headers: headers),
          );

          print('   - Статус ответа: ${response.statusCode}');
          print('   - Данные ответа: ${response.data}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            return response.data ?? {};
          }
        } on DioException catch (e) {
          print('   - Ошибка для $endpoint: ${e.response?.statusCode}');
          lastException = e;
          // Продолжаем пробовать другие эндпоинты, если это 404
          if (e.response?.statusCode != 404) {
            // Если это не 404, пробрасываем ошибку дальше
            break;
          }
        }
      }

      // Если все варианты не сработали, пробуем POST метод
      print('   - Пробуем метод POST для /account/profile');
      try {
        final response = await _dio.post(
          '/account/profile',
          data: requestData,
          options: Options(headers: headers),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.data ?? {};
        }
      } on DioException catch (e) {
        print('   - POST также не сработал: ${e.response?.statusCode}');
        lastException = e;
      }

      // Если ничего не сработало, используем последнюю ошибку
      if (lastException != null) {
        // Пробрасываем последнюю ошибку для обработки ниже
        throw lastException;
      }

      throw Exception('Не удалось найти рабочий эндпоинт для обновления профиля');
    } on DioException catch (e) {
      print('❌ Ошибка DioException при обновлении профиля:');
      print('   - Тип ошибки: ${e.type}');
      print('   - Сообщение: ${e.message}');
      print('   - Код ответа: ${e.response?.statusCode}');
      print('   - Данные ответа: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Требуется авторизация для обновления профиля. Пожалуйста, войдите в систему заново.');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?.toString() ?? 'Неверные данные для обновления профиля.';
        throw Exception('Неверные данные: $errorMessage');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Недостаточно прав для обновления профиля.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Эндпоинт для обновления профиля не найден на сервере. Данные сохранены локально.');
      } else {
        final errorMessage = e.response?.data?.toString() ?? e.message ?? 'Неизвестная ошибка';
        throw Exception('Ошибка при обновлении профиля: $errorMessage');
      }
    } catch (e) {
      print('❌ Общая ошибка при обновлении профиля: $e');
      // Если это не DioException, пробрасываем как есть
      if (e is! DioException) {
        rethrow;
      }
      // Для DioException уже обработано выше
      throw Exception('Ошибка при обновлении профиля: ${e.toString()}');
    }
  }

  /// Получение данных профиля пользователя
  /// GET /account/profile или GET /account/getProfile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Получаем токен из хранилища
      final box = GetStorage();
      final token = box.read<String>('token');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get(
        '/account/profile',
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка получения профиля. Код: ${response.statusCode}');
      }

      return response.data ?? {};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Требуется авторизация для получения профиля.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Профиль не найден.');
      } else {
        throw Exception('Ошибка при получении профиля: ${e.message}');
      }
    }
  }

  /// Получение данных пользователя
  /// GET /account/user?userId=...
  Future<Map<String, dynamic>> getAccountUser(String userId) async {
    try {
      final box = GetStorage();
      final token = box.read<String>('token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get(
        '/account/user',
        queryParameters: {
          'userId': userId,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Ошибка получения пользователя. Код: ${response.statusCode}');
      }

      // Отладочная информация по ответу сервера
      print('📥 API /account/user:');
      print('   - statusCode: ${response.statusCode}');
      print('   - data: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['error'] != null || data['message'] != null) {
          final errorText =
              data['error']?.toString() ?? data['message']?.toString();
          throw Exception(
              'Ошибка /account/user: ${errorText ?? 'неизвестная'}');
        }
        final nestedKeys = ['user', 'data', 'result', 'payload', 'profile'];
        for (final key in nestedKeys) {
          final nested = data[key];
          if (nested is Map<String, dynamic>) {
            return nested;
          }
        }
        return data;
      }

      return {};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Требуется авторизация для получения пользователя.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Эндпоинт /account/user не найден.');
      } else {
        throw Exception('Ошибка при получении пользователя: ${e.message}');
      }
    }
  }

  /// Получение данных пользователя по имени (username/email)
  /// POST /account/username
  Future<Map<String, dynamic>> getAccountUserByUsername(String userName) async {
    try {
      final box = GetStorage();
      final token = box.read<String>('token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        '/account/username',
        queryParameters: {
          'userName': userName,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Ошибка получения пользователя по username. Код: ${response.statusCode}');
      }

      // Отладочная информация по ответу сервера
      print('📥 API /account/username:');
      print('   - statusCode: ${response.statusCode}');
      print('   - data: ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['error'] != null || data['message'] != null) {
          final errorText =
              data['error']?.toString() ?? data['message']?.toString();
          throw Exception(
              'Ошибка /account/username: ${errorText ?? 'неизвестная'}');
        }
        final nestedKeys = ['user', 'data', 'result', 'payload', 'profile'];
        for (final key in nestedKeys) {
          final nested = data[key];
          if (nested is Map<String, dynamic>) {
            return nested;
          }
        }
        return data;
      }

      return {};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else if (e.response?.statusCode == 401) {
        throw Exception(
            'Требуется авторизация для получения пользователя по username.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Эндпоинт /account/username не найден.');
      } else {
        throw Exception(
            'Ошибка при получении пользователя по username: ${e.message}');
      }
    }
  }

  /// Сброс пароля (если поддерживается)
  /// POST /account/forgotPassword
  /// Тело: { "email": "..." } — или что требует ваш сервер
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/account/forgotPassword',
        data: {"email": email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Сервер вернул код ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else {
        throw Exception('Ошибка при запросе сброса пароля: ${e.message}');
      }
    }
  }

  /// Тестовый метод для проверки API товаров
  Future<void> testProductsAPI(String token) async {
    try {
      print('Тестирование API товаров с токеном: $token');
      final response = await _dio.get(
        '/order/getproducts',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Тест API товаров успешен: ${response.statusCode}');
      print('Данные: ${response.data}');
    } on DioException catch (e) {
      print('Тест API товаров провален: ${e.message}');
      print('Код ошибки: ${e.response?.statusCode}');
    }
  }

  /// Простой тест API товаров без авторизации
  Future<void> testSimpleProductsAPI() async {
    try {
      print('🔍 Тестирование простого запроса к API товаров');

      // Тест 1: Простой GET запрос
      final response1 = await _dio.get('/order/getproducts');
      print('✅ Простой GET запрос успешен: ${response1.statusCode}');
      print('Данные: ${response1.data}');
      return;
    } on DioException catch (e) {
      print('❌ Простой GET запрос провален: ${e.response?.statusCode}');
    }

    try {
      // Тест 2: С базовыми заголовками
      final response2 = await _dio.get(
        '/order/getproducts',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      print('✅ GET с Accept заголовком успешен: ${response2.statusCode}');
      print('Данные: ${response2.data}');
      return;
    } on DioException catch (e) {
      print('❌ GET с Accept заголовком провален: ${e.response?.statusCode}');
    }

    try {
      // Тест 3: С Content-Type заголовком
      final response3 = await _dio.get(
        '/order/getproducts',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print('✅ GET с Content-Type заголовком успешен: ${response3.statusCode}');
      print('Данные: ${response3.data}');
      return;
    } on DioException catch (e) {
      print(
          '❌ GET с Content-Type заголовком провален: ${e.response?.statusCode}');
    }

    print('❌ Все простые тесты провалились');
  }

  /// Тест API товаров без авторизации
  Future<void> testProductsAPIWithoutAuth() async {
    try {
      print('Тестирование API товаров БЕЗ авторизации');
      final response = await _dio.get(
        '/order/getproducts',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print('Тест API товаров БЕЗ авторизации успешен: ${response.statusCode}');
      print('Данные: ${response.data}');
    } on DioException catch (e) {
      print('Тест API товаров БЕЗ авторизации провален: ${e.message}');
      print('Код ошибки: ${e.response?.statusCode}');
    }
  }

  /// Тест API товаров с разными форматами авторизации
  Future<void> testProductsAPIWithDifferentAuth(String token) async {
    final authFormats = [
      {'Authorization': 'Bearer $token'},
      {'Authorization': 'Token $token'},
      {'X-Auth-Token': token},
      {'X-API-Key': token},
    ];

    for (final headers in authFormats) {
      try {
        print('Тестирование API товаров с заголовками: $headers');
        final response = await _dio.get(
          '/order/getproducts',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              ...headers,
            },
          ),
        );
        print('Успех с заголовками $headers: ${response.statusCode}');
        print('Данные: ${response.data}');
        return; // Если успешно, прекращаем тестирование
      } on DioException catch (e) {
        print('Провал с заголовками $headers: ${e.response?.statusCode}');
      }
    }
    print('Все форматы авторизации провалились');
  }

  /// Тест альтернативных путей API для товаров
  Future<void> testAlternativeProductPaths() async {
    final paths = [
      '/products',
      '/api/products',
      '/api/order/products',
      '/order/products',
      '/items',
      '/api/items',
    ];

    for (final path in paths) {
      try {
        print('Тестирование пути: $path');
        final response = await _dio.get(
          path,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );
        print('Успех с путем $path: ${response.statusCode}');
        print('Данные: ${response.data}');
        return; // Если успешно, прекращаем тестирование
      } on DioException catch (e) {
        print('Провал с путем $path: ${e.response?.statusCode}');
      }
    }
    print('Все альтернативные пути провалились');
  }
}

class ProductRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: API_BASE_URL,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  ));

  /// Получить список всех товаров
  Future<List<ProductModel>> getProducts() async {
    try {
      // Получаем токен из AuthController
      final authController = Get.find<AuthController>();
      final token = authController.getToken();

      // Добавляем заголовки для аутентификации
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Добавляем токен, если он есть
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get(
        '/order/getproducts',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          final products = (response.data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
          return products;
        } else {
          throw Exception('Неверный формат данных от сервера');
        }
      } else {
        throw Exception(
            'Ошибка получения списка товаров. Код: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else if (e.response?.statusCode == 401) {
        throw Exception(
            'Требуется авторизация для доступа к товарам. Пожалуйста, войдите в систему.');
      } else {
        throw Exception('Ошибка сети: ${e.message}');
      }
    } catch (e) {
      throw Exception('Неожиданная ошибка: $e');
    }
  }

  /// Получить товар по ID
  Future<ProductModel> getProductById(int productId) async {
    try {
      final response = await _dio.get(
        '/order/getproductid/$productId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Ошибка получения товара. Код: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            'Превышено время ожидания. Проверьте подключение к интернету.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Ошибка подключения к серверу. Проверьте интернет-соединение.');
      } else {
        throw Exception('Ошибка при получении товара: ${e.message}');
      }
    }
  }
}
