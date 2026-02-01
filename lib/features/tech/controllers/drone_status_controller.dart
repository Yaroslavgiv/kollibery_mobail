import 'package:get/get.dart';
import '../../../data/sources/api/device_status_websocket.dart';
import '../../../utils/constants/api_constants.dart';
import 'dart:async';

class DroneStatusController extends GetxController {
  late DeviceStatusWebSocket _webSocket;
  
  final Rx<DeviceStatus> status = DeviceStatus.disconnected.obs;
  final RxString deviceName = 'Дрон Колибри 001'.obs;
  final RxBool isConnected = false.obs;
  final RxMap<String, dynamic> additionalData = <String, dynamic>{}.obs;
  
  StreamSubscription<DeviceStatusData>? _statusSubscription;
  Timer? _statusUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
    _startPeriodicStatusUpdate();
  }

  void _initializeWebSocket() {
    _webSocket = DeviceStatusWebSocket(
      url: WS_DRONE_STATUS_URL,
      deviceType: 'drone',
    );

    _statusSubscription = _webSocket.statusStream.listen(
      (statusData) {
        status.value = statusData.status;
        deviceName.value = statusData.deviceName;
        isConnected.value = statusData.status == DeviceStatus.connected;
        
        if (statusData.additionalData != null) {
          additionalData.value = statusData.additionalData!;
        }
        
        // print('📊 Статус дрона обновлен: ${statusData.status}');
      },
      onError: (error) {
        // print('❌ Ошибка в потоке статуса дрона: $error');
        status.value = DeviceStatus.disconnected;
        isConnected.value = false;
      },
    );

    _webSocket.connect();
  }

  /// Запускает периодическое обновление статуса каждые 5 секунд
  void _startPeriodicStatusUpdate() {
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        // Запрашиваем статус через WebSocket
        _webSocket.requestStatus();
      },
    );
  }

  String getStatusText() {
    switch (status.value) {
      case DeviceStatus.connected:
        return 'НА СВЯЗИ';
      case DeviceStatus.disconnected:
        return 'НЕТ СВЯЗИ';
      case DeviceStatus.unknown:
        return 'НЕТ СВЯЗИ'; // Убрали "НЕИЗВЕСТНО", заменяем на "НЕТ СВЯЗИ"
    }
  }

  void reconnect() {
    _webSocket.disconnect().then((_) {
      _webSocket.connect();
    });
  }

  @override
  void onClose() {
    _statusUpdateTimer?.cancel();
    _statusSubscription?.cancel();
    _webSocket.dispose();
    super.onClose();
  }
}
