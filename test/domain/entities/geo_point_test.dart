import 'package:flutter_test/flutter_test.dart';
import 'package:kollibry/domain/entities/geo_point.dart';

void main() {
  test('GeoPoint сериализуется в формат API', () {
    const point = GeoPoint(latitude: 55.75, longitude: 37.61);
    expect(point.toMap(), {'latitude': 55.75, 'longitude': 37.61});
    expect(point.toApiBody()['altitude'], 0);
  });
}
