/// Геоточка посадки/взлёта дрона.
class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
    this.altitude = 0,
  });

  final double latitude;
  final double longitude;
  final double altitude;

  Map<String, double> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  Map<String, dynamic> toApiBody() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
      };
}
