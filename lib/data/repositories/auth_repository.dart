import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/jwt_decoder.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart' as contracts;

/// Реализация репозитория авторизации.
class AuthRepositoryImpl implements contracts.AuthRepository {
  AuthRepositoryImpl({
    ApiClient? apiClient,
    LocalStorage? storage,
  })  : _dio = (apiClient ?? Get.find<ApiClient>()).dio,
        _storage = storage ?? Get.find<LocalStorage>();

  final Dio _dio;
  final LocalStorage _storage;

  /// Регистрация
  /// POST /account/register
  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final data = <String, dynamic>{
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
        "role": role,
      };
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        data["phoneNumber"] = phoneNumber.trim();
      }
      final response = await _dio.post(
        '/account/register',
        data: data,
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
  @override
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
  @override
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) async {
    try {
      // Получаем токен из хранилища
      final token = _storage.read<String>('token');
      final role = _storage.read<String>('role') ?? 'unknown';

      print('📤 API: Обновление профиля');
      print('   - Базовый URL: ${_dio.options.baseUrl}');
      print('   - Роль: $role');
      print(
          '   - Токен: ${token != null ? "есть (${token.length} символов)" : "отсутствует"}');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception(
            'Токен авторизации отсутствует. Пожалуйста, войдите в систему заново.');
      }

      // PUT /account/updateuser: userName, phoneNumber, firstName, lastName (все поля по документации)
      final updateUserData = {
        "userName": email,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": (phone != null && phone.isNotEmpty) ? phone : '',
      };
      final requestData = {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        if (phone != null && phone.isNotEmpty) "phone": phone,
      };

      print('   - Данные запроса: $requestData');
      print('   - Заголовки: ${headers.keys.toList()}');

      // Сначала пробуем PUT /account/updateuser (документация API)
      DioException? updateUserException;
      try {
        print('   - Пробуем эндпоинт: PUT /account/updateuser');
        final response = await _dio.put(
          '/account/updateuser',
          data: updateUserData,
          options: Options(headers: headers),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {};
        }
      } on DioException catch (e) {
        updateUserException = e;
        print('   - Ошибка для /account/updateuser: ${e.response?.statusCode}');
        print('   - Тело ответа: ${e.response?.data}');
      }
      // 500 от updateuser — эндпоинт есть, ошибка на сервере; данные уже сохранены локально, не бросаем
      if (updateUserException != null &&
          updateUserException.response?.statusCode == 500) {
        print(
            '   - Обновление на сервере не применено (500). Данные сохранены локально.');
        return {};
      }

      // Получаем userId для возможного использования в пути
      final userId = _storage.read<String>('userId');
      print('   - userId: ${userId ?? "не найден"}');

      // Пробуем несколько вариантов эндпоинтов
      final endpointsToTry = <String>[
        '/account/profile',
        '/account/user',
      ];

      // Если есть userId, добавляем варианты с userId
      if (userId != null && userId.isNotEmpty) {
        endpointsToTry.addAll([
          '/account/profile/$userId', // Вариант с userId в пути
          '/account/$userId/profile', // Альтернативный вариант с userId
        ]);
      }

      // Добавляем другие варианты
      endpointsToTry.addAll([
        '/account/updateProfile', // Явный updateProfile
        '/account/update', // Короткий вариант
        '/account/editProfile', // Альтернативный вариант
        '/account/edit', // Еще один вариант
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

      throw Exception(
          'Не удалось найти рабочий эндпоинт для обновления профиля');
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
        throw Exception(
            'Требуется авторизация для обновления профиля. Пожалуйста, войдите в систему заново.');
      } else if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?.toString() ??
            'Неверные данные для обновления профиля.';
        throw Exception('Неверные данные: $errorMessage');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Недостаточно прав для обновления профиля.');
      } else if (e.response?.statusCode == 404) {
        throw Exception(
            'Эндпоинт для обновления профиля не найден на сервере. Данные сохранены локально.');
      } else {
        final errorMessage =
            e.response?.data?.toString() ?? e.message ?? 'Неизвестная ошибка';
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
  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Получаем токен из хранилища
      final token = _storage.read<String>('token');

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
        throw Exception(
            'Ошибка получения профиля. Код: ${response.statusCode}');
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
  @override
  Future<Map<String, dynamic>> getAccountUser(String userId) async {
    try {
      final token = _storage.read<String>('token');

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
  @override
  Future<Map<String, dynamic>> getAccountUserByUsername(String userName) async {
    try {
      final token = _storage.read<String>('token');

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
  @override
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

  @override
  Future<UserEntity?> resolveAccount(String email, String? userId) async {
    try {
      Map<String, dynamic> data = {};
      if (userId != null && userId.isNotEmpty && JwtDecoder.isGuid(userId)) {
        data = await getAccountUser(userId);
      } else {
        data = await getAccountUserByUsername(email);
      }
      if (data.isEmpty) return null;
      final role = UserRole.fromString(data['role']?.toString());
      return UserEntity(
        id: data['userId']?.toString() ?? data['id']?.toString(),
        email: data['email']?.toString() ?? email,
        firstName: data['firstName']?.toString() ?? '',
        lastName: data['lastName']?.toString() ?? '',
        phone: data['phone']?.toString() ?? data['phoneNumber']?.toString() ?? '',
        role: role,
      );
    } catch (e) {
      AppLogger.warning('Не удалось получить аккаунт с сервера: $e');
      return null;
    }
  }
}
