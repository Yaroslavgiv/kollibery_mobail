import 'package:get/get.dart';
import '../../../data/sources/api/device_status_websocket.dart';
import '../../../utils/constants/api_constants.dart';
import 'dart:async';

class DroneStatusController extends GetxController {
  late DeviceStatusWebSocket _webSocket;
  
  final Rx<DeviceStatus> status = DeviceStatus.unknown.obs;
  final RxString deviceName = 'Дрон Колибри 001'.obs;
  final RxBool isConnected = false.obs;
  final RxMap<String, dynamic> additionalData = <String, dynamic>{}.obs;
  
  StreamSubscription<DeviceStatusData>? _statusSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
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

  String getStatusText() {
    switch (status.value) {
      case DeviceStatus.connected:
        return 'НА СВЯЗИ';
      case DeviceStatus.disconnected:
        return 'НЕТ СВЯЗИ';
      case DeviceStatus.unknown:
        return 'НЕИЗВЕСТНО';
    }
  }

  void reconnect() {
    _webSocket.disconnect().then((_) {
      _webSocket.connect();
    });
  }

  @override
  void onClose() {
    _statusSubscription?.cancel();
    _webSocket.dispose();
    super.onClose();
  }
}
