import '../sources/api/flight_api.dart';
import 'package:http/http.dart' as http;

class FlightRepository {
  Future<http.Response> sendOrderLocation({
    Map<String, double>? sellerPoint,
    Map<String, double>? buyerPoint,
    Map<String, double>? startPoint,
    List<Map<String, double>>? waypoints,
    String? orderId,
  }) async {
    return await FlightApi.sendOrderLocation(
      sellerPoint: sellerPoint,
      buyerPoint: buyerPoint,
      startPoint: startPoint,
      waypoints: waypoints,
      orderId: orderId,
    );
  }
}
