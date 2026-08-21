import 'package:dio/dio.dart';

import '../../utils/constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../logging/app_logger.dart';
import '../storage/local_storage.dart';

/// Единый HTTP-клиент приложения.
/// Репозитории не создают собственный Dio.
class ApiClient {
  ApiClient(this._storage, {Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: API_BASE_URL,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    this.dio.interceptors.add(_AuthInterceptor(_storage));
  }

  final LocalStorage _storage;
  final Dio dio;
}

/// Добавляет Bearer-токен ко всем запросам, если сессия есть.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final LocalStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.read<String>(StorageKeys.token);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning(
      'HTTP ${err.requestOptions.method} ${err.requestOptions.uri} '
      '→ ${err.response?.statusCode ?? err.type}',
    );
    handler.next(err);
  }
}
