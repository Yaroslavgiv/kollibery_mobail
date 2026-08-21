import 'package:get/get.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/services/flight_service.dart';

/// Manager команд дрона и дронбокса.
/// View вызывает только этот слой, без API и репозиториев.
class DeviceCommandManager extends GetxController {
  DeviceCommandManager({FlightService? flightService})
      : _flightService = flightService ?? Get.find<FlightService>();

  final FlightService _flightService;

  Future<bool> openLock() => _flightService.openLock();

  Future<bool> closeLock() => _flightService.closeLock();

  /// Совместимые имена с бывшим FlightApi — View больше не знает про HTTP.
  Future<bool> controlDroneLock(bool isOpen) =>
      isOpen ? openLock() : closeLock();

  Future<bool> openDroneBox(bool isOpen) => _flightService.setCargoBox(isOpen);

  Future<bool> testBacklight({required int colorNumber}) =>
      setBacklight(colorNumber);

  Future<bool> controlRoof(bool isOpen) =>
      isOpen ? openRoof() : closeRoof();

  Future<bool> controlPosition(bool isCenter) =>
      isCenter ? moveToCenter() : moveToEdge();

  Future<bool> controlTable(bool isUp) => isUp ? raiseTable() : lowerTable();

  Future<bool> controlHatch(bool isOpen) =>
      isOpen ? openHatch() : closeHatch();

  Future<bool> controlDroneBattery(bool isInstall) =>
      isInstall ? installDroneBattery() : removeDroneBattery();

  Future<bool> controlBoxBattery({
    required int batteryNumber,
    required bool isInstall,
  }) {
    return isInstall
        ? installBoxBattery(batteryNumber)
        : removeBoxBattery(batteryNumber);
  }

  Future<bool> controlDroneBatteryCharger({required bool isCharging}) =>
      setDroneBatteryCharging(isCharging);

  Future<bool> controlBoxBatteryCharger({
    required int batteryNumber,
    required bool isCharging,
  }) {
    return setBoxBatteryCharging(batteryNumber, isCharging);
  }

  Future<bool> droneboxStop() => stopDronebox();

  Future<bool> droneStartFlight() => startFlight();

  Future<bool> droneCancelFlight() => cancelFlight();

  Future<bool> droneLand() => land();

  Future<bool> confirmNeoLocation({
    required int orderId,
    required double latitude,
    required double longitude,
  }) {
    return confirmSellerLocation(
      orderId: orderId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<bool> openCargoBox() => _flightService.openCargoBox();

  Future<bool> closeCargoBox() => _flightService.closeCargoBox();

  Future<bool> setCargoBox(bool isOpen) => _flightService.setCargoBox(isOpen);

  Future<bool> setBacklight(int colorNumber) =>
      _flightService.setBacklight(colorNumber);

  Future<bool> testSystemCheck({
    required bool isActive,
    required int distance,
  }) {
    return _flightService.testSystemCheck(
      isActive: isActive,
      distance: distance,
    );
  }

  Future<bool> startFlight() => _flightService.startFlight();

  Future<bool> cancelFlight() => _flightService.cancelFlight();

  Future<bool> land() => _flightService.land();

  Future<bool> returnToHome() => _flightService.returnToHome();

  Future<bool> emergencyStop() => _flightService.emergencyStop();

  Future<bool> openRoof() => _flightService.openRoof();

  Future<bool> closeRoof() => _flightService.closeRoof();

  Future<bool> moveToCenter() => _flightService.moveToCenter();

  Future<bool> moveToEdge() => _flightService.moveToEdge();

  Future<bool> raiseTable() => _flightService.raiseTable();

  Future<bool> lowerTable() => _flightService.lowerTable();

  Future<bool> openHatch() => _flightService.openHatch();

  Future<bool> closeHatch() => _flightService.closeHatch();

  Future<bool> installDroneBattery() => _flightService.installDroneBattery();

  Future<bool> removeDroneBattery() => _flightService.removeDroneBattery();

  Future<bool> installBoxBattery(int number) =>
      _flightService.installBoxBattery(number);

  Future<bool> removeBoxBattery(int number) =>
      _flightService.removeBoxBattery(number);

  Future<bool> setDroneBatteryCharging(bool isCharging) =>
      _flightService.setDroneBatteryCharging(isCharging);

  Future<bool> setBoxBatteryCharging(int number, bool isCharging) =>
      _flightService.setBoxBatteryCharging(number, isCharging);

  Future<bool> stopDronebox() => _flightService.stopDronebox();

  Future<bool> confirmSellerLocation({
    required int orderId,
    required double latitude,
    required double longitude,
  }) {
    return _flightService.confirmSellerLocation(
      orderId: orderId,
      point: GeoPoint(latitude: latitude, longitude: longitude),
    );
  }
}
