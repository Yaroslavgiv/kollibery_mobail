import 'package:http/http.dart' as http;

/// Успешный HTTP-ответ: 2xx или тело с признаком успеха.
bool isSuccessfulResponse(http.Response response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return true;
  }
  final body = response.body.toLowerCase();
  return body.contains('успех') ||
      body.contains('success') ||
      body.contains('"ok"');
}
