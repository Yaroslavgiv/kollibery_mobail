import 'package:dio/dio.dart';
import '../../features/home/models/product_model.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://80.90.191.66'));

  /// Регистрация
  /// POST /account/register
  /// Тело: { "firstName": "...", "lastName": "...", "email": "...", "password": "...", "confirmPassword": "..." }
  Future<void> register(String firstName, String lastName, String email,
      String password, String confirmPassword) async {
    try {
      final response = await _dio.post(
        '/account/register',
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "confirmPassword": confirmPassword,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Ошибка регистрации. Код: ${response.statusCode}');
      }
      print('Регистрация успешна: ${response.data}');
    } on DioException catch (e) {
      print('Ошибка при регистрации: ${e.message}');
      throw Exception('Ошибка при регистрации: ${e.message}');
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
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка логина. Код: ${response.statusCode}');
      }

      print('Логин успешен: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Ошибка при логине: ${e.message}');
      throw Exception('Ошибка при логине: ${e.message}');
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
      );
      if (response.statusCode != 200) {
        throw Exception('Сервер вернул код ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Ошибка при запросе /account/forgotPassword: ${e.message}');
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
    baseUrl: 'http://80.90.191.66',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    sendTimeout: Duration(seconds: 10),
  ));

  /// Получить список всех товаров
  Future<List<ProductModel>> getProducts() async {
    try {
      print('Запрос товаров с URL: http://80.90.191.66/order/getproducts');

      // Получаем токен из AuthController
      final authController = Get.find<AuthController>();
      final token = authController.getToken();

      print('Токен авторизации: ${token != null ? "есть" : "отсутствует"}');

      // Добавляем заголовки для аутентификации
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Добавляем токен, если он есть
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get(
        '/order/getproducts',
        options: Options(headers: headers),
      );

      print('Получен ответ: ${response.statusCode}');
      print('Данные ответа: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final products = (response.data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
          print('Успешно получено товаров: ${products.length}');
          return products;
        } else {
          print(
              'Ошибка: response.data не является списком: ${response.data.runtimeType}');
          throw Exception('Неверный формат данных от сервера');
        }
      } else {
        print('Ошибка HTTP: ${response.statusCode}');
        throw Exception(
            'Ошибка получения списка товаров. Код: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Ошибка DioException: ${e.message}');
      print('Тип ошибки: ${e.type}');
      print('Код ошибки: ${e.response?.statusCode}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('Таймаут соединения с сервером');
        case DioExceptionType.connectionError:
          throw Exception('Ошибка подключения к серверу');
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            throw Exception(
                'Требуется авторизация для доступа к товарам. Пожалуйста, войдите в систему.');
          }
          throw Exception('Ошибка сервера: ${e.response?.statusCode}');
        default:
          throw Exception('Ошибка сети: ${e.message}');
      }
    } catch (e) {
      print('Неожиданная ошибка: $e');
      throw Exception('Неожиданная ошибка: $e');
    }
  }

  /// Получить товар по ID
  Future<ProductModel> getProductById(int productId) async {
    try {
      print('Запрос товара с ID: $productId');

      final response = await _dio.get(
        '/order/getproductid/$productId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print('Получен ответ: ${response.statusCode}');
      print('Данные ответа: ${response.data}');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Ошибка получения товара. Код: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Ошибка DioException при получении товара: ${e.message}');
      throw Exception('Ошибка при получении товара: ${e.message}');
    }
  }
}
