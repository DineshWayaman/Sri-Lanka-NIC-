import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('String.toNicOrNull', () {
    test('returns NicDetails for a valid NIC', () {
      final NicDetails? d = '880324567V'.toNicOrNull();
      expect(d, isNotNull);
      expect(d!.birthYear, 1988);
    });

    test('returns null for an invalid NIC', () {
      expect('123456789'.toNicOrNull(), isNull);
    });
  });

  group('String.isValidNic', () {
    test('returns true for a valid NIC', () {
      expect('200015012345'.isValidNic(), isTrue);
    });

    test('returns false for an invalid NIC', () {
      expect('123456789'.isValidNic(), isFalse);
    });
  });
}
