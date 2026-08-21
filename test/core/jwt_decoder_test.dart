import 'package:flutter_test/flutter_test.dart';
import 'package:kollibry/core/utils/jwt_decoder.dart';

void main() {
  test('JwtDecoder разбирает payload и ищет claim', () {
    // header.payload.sig где payload = {"role":"buyer","sub":"abc"}
    const token =
        'eyJhbGciOiJub25lIn0.eyJyb2xlIjoiYnV5ZXIiLCJzdWIiOiJhYmMifQ.sig';
    final payload = JwtDecoder.decodePayload(token);
    expect(payload, isNotNull);
    expect(JwtDecoder.firstClaim(payload!, const ['role']), 'buyer');
    expect(JwtDecoder.firstClaim(payload, const ['sub']), 'abc');
  });

  test('JwtDecoder проверяет GUID', () {
    expect(
      JwtDecoder.isGuid('123e4567-e89b-12d3-a456-426614174000'),
      isTrue,
    );
    expect(JwtDecoder.isGuid('not-a-guid'), isFalse);
  });
}
