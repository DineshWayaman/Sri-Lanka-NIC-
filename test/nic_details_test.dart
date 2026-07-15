import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('NicDetails.ageInYears without asOf', () {
    test('uses DateTime.now() as the default reference point', () {
      final NicDetails d = Nic.parse('880324567V'); // 1988-02-01
      final int expected = DateTime.now().year - 1988;
      final int actual = d.ageInYears();
      // Allow either value depending on whether today's date has passed
      // Feb 1 this year, to avoid a test that's flaky across the year.
      expect(actual, anyOf(expected, expected - 1));
    });
  });

  group('NicDetails.toString', () {
    test('includes the key identifying fields', () {
      final NicDetails d = Nic.parse('880324567V');
      final String s = d.toString();
      expect(s, contains('880324567V'));
      expect(s, contains('1988'));
      expect(s, contains('1988-02-01'));
      expect(s, contains('Gender.male'));
      expect(s, contains('456'));
    });
  });

  group('NicDetails equality', () {
    test('two parses of the same NIC are equal and share a hash code', () {
      final NicDetails a = Nic.parse('880324567V');
      final NicDetails b = Nic.parse('880324567V');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('is not equal to a NicDetails for a different NIC', () {
      final NicDetails a = Nic.parse('880324567V');
      final NicDetails b = Nic.parse('885324567V');
      expect(a, isNot(equals(b)));
    });

    test('is not equal to a non-NicDetails object', () {
      final NicDetails a = Nic.parse('880324567V');
      // ignore: unrelated_type_equality_checks
      expect(a == 'not a NicDetails', isFalse);
    });
  });
}
