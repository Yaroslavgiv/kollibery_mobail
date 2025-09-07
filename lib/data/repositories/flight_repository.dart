import '../sources/api/flight_api.dart';
import 'package:http/http.dart' as http;

class FlightRepository {
  Future<http.Response> sendOrderLocation({
    Map<String, double>? sellerPoint,
    Map<String, double>? buyerPoint,
  }) async {
    return await FlightApi.sendOrderLocation(
      sellerPoint: sellerPoint,
      buyerPoint: buyerPoint,
    );
  }
}
