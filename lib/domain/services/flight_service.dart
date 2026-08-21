import '../entities/geo_point.dart';
import '../entities/user_role.dart';
import '../repositories/flight_repository.dart';

/// Бизнес-сценарии полёта: точка посадки, люк, дронбокс.
class FlightService {
  FlightService(this._repository);

  final FlightRepository _repository;

  /// Отправка точки посадки. Для покупателя — buyerPoint, для продавца — sellerPoint.
  Future<bool> sendLandingPoint({
    required UserRole role,
    required GeoPoint point,
    GeoPoint? startPoint,
    List<GeoPoint>? waypoints,
    String? orderId,
  }) {
    final map = point.toMap();
    return _repository.sendOrderLocation(
      buyerPoint: role == UserRole.buyer || role == UserRole.technician
          ? map
          : null,
      sellerPoint: role == UserRole.seller ? map : null,
      startPoint: startPoint?.toMap(),
      waypoints: waypoints?.map((e) => e.toMap()).toList(),
      orderId: orderId,
    );
  }

  Future<bool> confirmSellerLocation({
    required int orderId,
    required GeoPoint point,
  }) {
    return _repository.confirmSellerLocation(orderId: orderId, point: point);
  }

  Future<bool> openCargoBox() => _repository.openDroneBox(true);

  Future<bool> closeCargoBox() => _repository.openDroneBox(false);

  Future<bool> setCargoBox(bool isOpen) => _repository.openDroneBox(isOpen);

  Future<bool> openLock() => _repository.controlDroneLock(true);

  Future<bool> closeLock() => _repository.controlDroneLock(false);

  Future<bool> setBacklight(int colorNumber) =>
      _repository.testBacklight(colorNumber: colorNumber);

  Future<bool> testSystemCheck({
    required bool isActive,
    required int distance,
  }) {
    return _repository.testSystemCheck(
      isActive: isActive,
      distance: distance,
    );
  }

  Future<bool> startFlight() => _repository.droneStartFlight();

  Future<bool> cancelFlight() => _repository.droneCancelFlight();

  Future<bool> land() => _repository.droneLand();

  Future<bool> returnToHome() => _repository.returnToHome();

  Future<bool> emergencyStop() => _repository.emergencyStop();

  Future<bool> openRoof() => _repository.controlRoof(true);

  Future<bool> closeRoof() => _repository.controlRoof(false);

  Future<bool> moveToCenter() => _repository.controlPosition(true);

  Future<bool> moveToEdge() => _repository.controlPosition(false);

  Future<bool> raiseTable() => _repository.controlTable(true);

  Future<bool> lowerTable() => _repository.controlTable(false);

  Future<bool> openHatch() => _repository.controlHatch(true);

  Future<bool> closeHatch() => _repository.controlHatch(false);

  Future<bool> installDroneBattery() => _repository.controlDroneBattery(true);

  Future<bool> removeDroneBattery() => _repository.controlDroneBattery(false);

  Future<bool> installBoxBattery(int number) =>
      _repository.controlBoxBattery(batteryNumber: number, isInstall: true);

  Future<bool> removeBoxBattery(int number) =>
      _repository.controlBoxBattery(batteryNumber: number, isInstall: false);

  Future<bool> setDroneBatteryCharging(bool isCharging) =>
      _repository.controlDroneBatteryCharger(isCharging: isCharging);

  Future<bool> setBoxBatteryCharging(int number, bool isCharging) =>
      _repository.controlBoxBatteryCharger(
        batteryNumber: number,
        isCharging: isCharging,
      );

  Future<bool> stopDronebox() => _repository.droneboxStop();
}
