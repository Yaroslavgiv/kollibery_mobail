import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, WebSocket;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:get_storage/get_storage.dart';

enum DeviceStatus {
  connected,
  disconnected,
  unknown,
}

class DeviceStatusData {
  final String deviceName;
  final DeviceStatus status;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;

  DeviceStatusData({
    required this.deviceName,
    required this.status,
    this.additionalData,
    required this.timestamp,
  });

  factory DeviceStatusData.fromJson(Map<String, dynamic> json) {
    DeviceStatus status;
    final statusStr = json['status']?.toString().toLowerCase() ?? 'unknown';

    if (statusStr.contains('connected') || statusStr.contains('на связи')) {
      status = DeviceStatus.connected;
    } else if (statusStr.contains('disconnected') ||
        statusStr.contains('нет связи')) {
      status = DeviceStatus.disconnected;
    } else {
      status = DeviceStatus.unknown;
    }

    return DeviceStatusData(
      deviceName: json['deviceName'] ?? json['device'] ?? 'Unknown',
      status: status,
      additionalData: json['data'],
      timestamp: DateTime.now(),
    );
  }
}

class DeviceStatusWebSocket {
  WebSocketChannel? _channel;
  StreamController<DeviceStatusData>? _statusController;
  StreamSubscription? _subscription;
  final String url;
  final String deviceType; // 'drone' or 'dronebox'
  bool _isConnected = false;
  Timer? _reconnectTimer;
  final GetStorage _storage = GetStorage();

  DeviceStatusWebSocket({
    required this.url,
    required this.deviceType,
  }) {
    _statusController = StreamController<DeviceStatusData>.broadcast();
  }

  Stream<DeviceStatusData> get statusStream => _statusController!.stream;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected && _channel != null) {
      // print('⚠️ WebSocket уже подключен для $deviceType');
      return;
    }

    try {
      final token = _storage.read('token');

      // Очищаем базовый URL от фрагментов
      String baseUrl = url.split('#').first.trim();

      // Убеждаемся, что URL начинается с ws:// или wss://
      if (!baseUrl.startsWith('ws://') && !baseUrl.startsWith('wss://')) {
        if (baseUrl.startsWith('https://')) {
          baseUrl = baseUrl.replaceFirst('https://', 'wss://');
        } else if (baseUrl.startsWith('http://')) {
          baseUrl = baseUrl.replaceFirst('http://', 'ws://');
        }
      }

      // Парсим базовый URL для извлечения компонентов
      final baseUri = Uri.parse(baseUrl);

      // Определяем схему (ws или wss)
      final scheme = baseUri.scheme == 'wss' ? 'wss' : 'ws';

      // Определяем порт (не указываем стандартные порты явно)
      int? port;
      if (baseUri.hasPort) {
        port = baseUri.port;
        // Не указываем стандартные порты в URL (80 для ws, 443 для wss)
        if ((scheme == 'ws' && port == 80) ||
            (scheme == 'wss' && port == 443)) {
          port = null;
        }
      }

      // Формируем query параметры как Map для конструктора Uri
      final queryParamsMap = <String, String>{};
      if (baseUri.hasQuery) {
        queryParamsMap.addAll(baseUri.queryParameters);
      }
      if (token != null) {
        queryParamsMap['token'] = token;
      }

      // Создаем URI напрямую через конструктор (избегаем проблем с Uri.parse)
      final path = baseUri.path.isEmpty ? '/' : baseUri.path;
      final finalUri = Uri(
        scheme: scheme,
        host: baseUri.host,
        port: port, // null для стандартных портов
        path: path,
        queryParameters: queryParamsMap.isNotEmpty ? queryParamsMap : null,
      );

      // Формируем строку URL и убеждаемся, что нет фрагментов
      String wsUrlString = finalUri.toString();
      // Убираем фрагменты, если они появились
      wsUrlString = wsUrlString.split('#').first;

      // Убеждаемся, что схема правильная
      if (!wsUrlString.startsWith('ws://') &&
          !wsUrlString.startsWith('wss://')) {
        // print(
        //     '⚠️ Предупреждение: URL не начинается с ws:// или wss://, исправляю...');
        wsUrlString = wsUrlString
            .replaceFirst('http://', 'ws://')
            .replaceFirst('https://', 'wss://');
      }

      // print('🔌 Подключение к WebSocket: $wsUrlString');
      // print(
      //     '🔍 Схема: ${finalUri.scheme}, Хост: ${finalUri.host}, Порт: ${finalUri.port}');

      // Используем WebSocket.connect() напрямую для платформенных приложений
      // чтобы избежать проблем с преобразованием схемы
      if (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS) {
        // Используем WebSocket.connect() напрямую и оборачиваем в IOWebSocketChannel
        final ws = await WebSocket.connect(wsUrlString);
        _channel = IOWebSocketChannel(ws);
      } else {
        // Для веб-платформы используем WebSocketChannel
        _channel = WebSocketChannel.connect(Uri.parse(wsUrlString));
      }

      _subscription = _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          // print('❌ WebSocket ошибка для $deviceType: $error');
          _isConnected = false;
          _statusController?.add(DeviceStatusData(
            deviceName: deviceType == 'drone'
                ? 'Дрон Колибри 001'
                : 'Дронбокс Колибри 001',
            status: DeviceStatus.disconnected,
            timestamp: DateTime.now(),
          ));
          _scheduleReconnect();
        },
        onDone: () {
          // print('🔌 WebSocket соединение закрыто для $deviceType');
          _isConnected = false;
          _statusController?.add(DeviceStatusData(
            deviceName: deviceType == 'drone'
                ? 'Дрон Колибри 001'
                : 'Дронбокс Колибри 001',
            status: DeviceStatus.disconnected,
            timestamp: DateTime.now(),
          ));
          _scheduleReconnect();
        },
        cancelOnError: false,
      );

      _isConnected = true;
      // print('✅ WebSocket подключен для $deviceType');

      // Отправляем начальный запрос статуса
      _requestStatus();
    } catch (e) {
      // print('❌ Ошибка подключения WebSocket для $deviceType: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      String jsonString;
      if (data is String) {
        jsonString = data;
      } else {
        jsonString = utf8.decode(data);
      }

      // print('📥 Получено сообщение от $deviceType: $jsonString');

      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final statusData = DeviceStatusData.fromJson(json);
      _statusController?.add(statusData);
    } catch (e) {
      // print('❌ Ошибка обработки сообщения от $deviceType: $e');
      // print('   Данные: $data');
    }
  }

  void _requestStatus() {
    if (_channel != null && _isConnected) {
      try {
        final message = jsonEncode({'action': 'getStatus'});
        _channel!.sink.add(message);
        // print('📤 Запрос статуса отправлен для $deviceType');
      } catch (e) {
        // print('❌ Ошибка отправки запроса статуса: $e');
      }
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;

    _reconnectTimer = Timer(Duration(seconds: 5), () {
      _reconnectTimer = null;
      // print('🔄 Попытка переподключения WebSocket для $deviceType...');
      connect();
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;

    _isConnected = false;
    // print('🔌 WebSocket отключен для $deviceType');
  }

  void dispose() {
    disconnect();
    _statusController?.close();
    _statusController = null;
  }
}
