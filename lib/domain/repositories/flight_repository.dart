import '../entities/geo_point.dart';

/// Контракт репозитория полётов, дрона и дронбокса.
/// Возвращает успех операции — HTTP-детали не покидают data-слой.
abstract class FlightRepository {
  Future<bool> sendOrderLocation({
    Map<String, double>? sellerPoint,
    Map<String, double>? buyerPoint,
    Map<String, double>? startPoint,
    List<Map<String, double>>? waypoints,
    String? orderId,
  });

  Future<bool> confirmSellerLocation({
    required int orderId,
    required GeoPoint point,
  });

  Future<bool> openDroneBox(bool isOpen);

  Future<bool> controlDroneLock(bool isOpen);

  Future<bool> testBacklight({required int colorNumber});

  Future<bool> testSystemCheck({
    required bool isActive,
    required int distance,
  });

  Future<bool> droneStartFlight();

  Future<bool> droneCancelFlight();

  Future<bool> droneLand();

  Future<bool> returnToHome();

  Future<bool> emergencyStop();

  Future<bool> controlRoof(bool isOpen);

  Future<bool> controlPosition(bool isCenter);

  Future<bool> controlTable(bool isUp);

  Future<bool> controlHatch(bool isOpen);

  Future<bool> controlDroneBattery(bool isInstall);

  Future<bool> controlBoxBattery({
    required int batteryNumber,
    required bool isInstall,
  });

  Future<bool> controlDroneBatteryCharger({required bool isCharging});

  Future<bool> controlBoxBatteryCharger({
    required int batteryNumber,
    required bool isCharging,
  });

  Future<bool> droneboxStop();
}
