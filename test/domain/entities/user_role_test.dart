import 'package:flutter_test/flutter_test.dart';
import 'package:kollibry/domain/entities/user_role.dart';

void main() {
  group('UserRole', () {
    test('разбирает роли из строк API и JWT', () {
      expect(UserRole.fromString('buyer'), UserRole.buyer);
      expect(UserRole.fromString('seller'), UserRole.seller);
      expect(UserRole.fromString('technician'), UserRole.technician);
      expect(UserRole.fromString('unknown'), isNull);
    });

    test('отдаёт строку для API', () {
      expect(UserRole.buyer.apiValue, 'buyer');
      expect(UserRole.seller.apiValue, 'seller');
      expect(UserRole.technician.apiValue, 'technician');
    });

    test('права техника и продавца', () {
      expect(UserRole.technician.canControlDroneHardware, isTrue);
      expect(UserRole.buyer.canControlDroneHardware, isFalse);
      expect(UserRole.seller.canManageCatalog, isTrue);
      expect(UserRole.buyer.canManageCatalog, isFalse);
    });
  });
}
