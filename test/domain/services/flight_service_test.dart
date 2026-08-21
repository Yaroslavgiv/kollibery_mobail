import 'package:flutter_test/flutter_test.dart';
import 'package:kollibry/domain/entities/geo_point.dart';
import 'package:kollibry/domain/entities/user_role.dart';
import 'package:kollibry/domain/repositories/flight_repository.dart';
import 'package:kollibry/domain/services/flight_service.dart';

class _FakeFlightRepository implements FlightRepository {
  Map<String, double>? lastBuyer;
  Map<String, double>? lastSeller;
  bool? lastBoxOpen;

  @override
  Future<bool> confirmSellerLocation({
    required int orderId,
    required GeoPoint point,
  }) async =>
      true;

  @override
  Future<bool> controlBoxBattery({
    required int batteryNumber,
    required bool isInstall,
  }) async =>
      true;

  @override
  Future<bool> controlBoxBatteryCharger({
    required int batteryNumber,
    required bool isCharging,
  }) async =>
      true;

  @override
  Future<bool> controlDroneBattery(bool isInstall) async => true;

  @override
  Future<bool> controlDroneBatteryCharger({required bool isCharging}) async =>
      true;

  @override
  Future<bool> controlDroneLock(bool isOpen) async => true;

  @override
  Future<bool> controlHatch(bool isOpen) async => true;

  @override
  Future<bool> controlPosition(bool isCenter) async => true;

  @override
  Future<bool> controlRoof(bool isOpen) async => true;

  @override
  Future<bool> controlTable(bool isUp) async => true;

  @override
  Future<bool> droneCancelFlight() async => true;

  @override
  Future<bool> droneLand() async => true;

  @override
  Future<bool> droneStartFlight() async => true;

  @override
  Future<bool> droneboxStop() async => true;

  @override
  Future<bool> emergencyStop() async => true;

  @override
  Future<bool> openDroneBox(bool isOpen) async {
    lastBoxOpen = isOpen;
    return true;
  }

  @override
  Future<bool> returnToHome() async => true;

  @override
  Future<bool> sendOrderLocation({
    Map<String, double>? sellerPoint,
    Map<String, double>? buyerPoint,
    Map<String, double>? startPoint,
    List<Map<String, double>>? waypoints,
    String? orderId,
  }) async {
    lastBuyer = buyerPoint;
    lastSeller = sellerPoint;
    return true;
  }

  @override
  Future<bool> testBacklight({required int colorNumber}) async => true;

  @override
  Future<bool> testSystemCheck({
    required bool isActive,
    required int distance,
  }) async =>
      true;
}

void main() {
  late _FakeFlightRepository repository;
  late FlightService service;

  setUp(() {
    repository = _FakeFlightRepository();
    service = FlightService(repository);
  });

  test('покупатель отправляет buyerPoint', () async {
    await service.sendLandingPoint(
      role: UserRole.buyer,
      point: const GeoPoint(latitude: 1, longitude: 2),
    );
    expect(repository.lastBuyer?['latitude'], 1);
    expect(repository.lastSeller, isNull);
  });

  test('продавец отправляет sellerPoint', () async {
    await service.sendLandingPoint(
      role: UserRole.seller,
      point: const GeoPoint(latitude: 3, longitude: 4),
    );
    expect(repository.lastSeller?['longitude'], 4);
    expect(repository.lastBuyer, isNull);
  });

  test('открытие и закрытие грузового бокса', () async {
    await service.openCargoBox();
    expect(repository.lastBoxOpen, isTrue);
    await service.closeCargoBox();
    expect(repository.lastBoxOpen, isFalse);
  });
}
