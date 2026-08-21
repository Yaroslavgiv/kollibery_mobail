import 'package:http/http.dart' as http;

import '../../core/logging/app_logger.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/flight_repository.dart';
import '../sources/api/flight_api.dart';
import '../sources/api/http_result.dart';

/// Реализация репозитория полётов. Прячет http.Response от верхних слоёв.
class FlightRepositoryImpl implements FlightRepository {
  @override
  Future<bool> sendOrderLocation({
    Map<String, double>? sellerPoint,
    Map<String, double>? buyerPoint,
    Map<String, double>? startPoint,
    List<Map<String, double>>? waypoints,
    String? orderId,
  }) async {
    try {
      final response = await FlightApi.sendOrderLocation(
        sellerPoint: sellerPoint,
        buyerPoint: buyerPoint,
        startPoint: startPoint,
        waypoints: waypoints,
        orderId: orderId,
      );
      return isSuccessfulResponse(response);
    } catch (e) {
      AppLogger.error('Ошибка отправки точки маршрута', e);
      return false;
    }
  }

  @override
  Future<bool> confirmSellerLocation({
    required int orderId,
    required GeoPoint point,
  }) async {
    try {
      final response = await FlightApi.confirmNeoLocation(
        orderId: orderId,
        latitude: point.latitude,
        longitude: point.longitude,
      );
      return isSuccessfulResponse(response);
    } catch (e) {
      AppLogger.error('Ошибка подтверждения геолокации продавца', e);
      return false;
    }
  }

  @override
  Future<bool> openDroneBox(bool isOpen) async {
    try {
      final response = await FlightApi.openDroneBox(isOpen);
      return isSuccessfulResponse(response);
    } catch (e) {
      AppLogger.error('Ошибка управления грузовым боксом', e);
      return false;
    }
  }

  @override
  Future<bool> controlDroneLock(bool isOpen) =>
      _run(() => FlightApi.controlDroneLock(isOpen), 'замок дрона');

  @override
  Future<bool> testBacklight({required int colorNumber}) =>
      _run(
        () => FlightApi.testBacklight(colorNumber: colorNumber),
        'подсветка',
      );

  @override
  Future<bool> testSystemCheck({
    required bool isActive,
    required int distance,
  }) =>
      _run(
        () => FlightApi.testSystemCheck(isActive: isActive, distance: distance),
        'взлёт/посадка',
      );

  @override
  Future<bool> droneStartFlight() =>
      _run(FlightApi.droneStartFlight, 'старт полёта');

  @override
  Future<bool> droneCancelFlight() =>
      _run(FlightApi.droneCancelFlight, 'отмена полёта');

  @override
  Future<bool> droneLand() => _run(FlightApi.droneLand, 'посадка');

  @override
  Future<bool> returnToHome() =>
      _run(FlightApi.returnToHome, 'возврат на базу');

  @override
  Future<bool> emergencyStop() =>
      _run(FlightApi.emergencyStop, 'экстренная остановка');

  @override
  Future<bool> controlRoof(bool isOpen) =>
      _run(() => FlightApi.controlRoof(isOpen), 'крыша дронбокса');

  @override
  Future<bool> controlPosition(bool isCenter) =>
      _run(() => FlightApi.controlPosition(isCenter), 'позиция дронбокса');

  @override
  Future<bool> controlTable(bool isUp) =>
      _run(() => FlightApi.controlTable(isUp), 'платформа дронбокса');

  @override
  Future<bool> controlHatch(bool isOpen) =>
      _run(() => FlightApi.controlHatch(isOpen), 'люк дронбокса');

  @override
  Future<bool> controlDroneBattery(bool isInstall) =>
      _run(() => FlightApi.controlDroneBattery(isInstall), 'батарея дрона');

  @override
  Future<bool> controlBoxBattery({
    required int batteryNumber,
    required bool isInstall,
  }) =>
      _run(
        () => FlightApi.controlBoxBattery(
          batteryNumber: batteryNumber,
          isInstall: isInstall,
        ),
        'батарея дронбокса $batteryNumber',
      );

  @override
  Future<bool> controlDroneBatteryCharger({required bool isCharging}) =>
      _run(
        () => FlightApi.controlDroneBatteryCharger(isCharging: isCharging),
        'заряд батареи дрона',
      );

  @override
  Future<bool> controlBoxBatteryCharger({
    required int batteryNumber,
    required bool isCharging,
  }) =>
      _run(
        () => FlightApi.controlBoxBatteryCharger(
          batteryNumber: batteryNumber,
          isCharging: isCharging,
        ),
        'заряд батареи $batteryNumber',
      );

  @override
  Future<bool> droneboxStop() =>
      _run(FlightApi.droneboxStop, 'стоп дронбокса');

  Future<bool> _run(
    Future<http.Response> Function() action,
    String label,
  ) async {
    try {
      final response = await action();
      return isSuccessfulResponse(response);
    } catch (e) {
      AppLogger.error('Ошибка команды: $label', e);
      return false;
    }
  }
}
