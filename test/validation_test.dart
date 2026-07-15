import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('Nic.isValid — day-of-year range', () {
    test('rejects raw day-of-year 499 (gap before female offset)', () {
      expect(Nic.isValid('884994567V'), isFalse);
    });

    test('rejects raw day-of-year 000', () {
      expect(Nic.isValid('880004567V'), isFalse);
    });

    test('rejects raw day-of-year beyond 866', () {
      expect(Nic.isValid('888674567V'), isFalse);
    });

    test('accepts the maximum male day-of-year 366', () {
      expect(Nic.isValid('883664567V'), isTrue);
    });

    test('accepts the minimum female day-of-year 501', () {
      expect(Nic.isValid('885014567V'), isTrue);
    });
  });

  group('Nic.isValid — birth year range', () {
    test(
        'rejects a birth year before 1900 (old format YY overflow N/A, '
        'modern format directly encodes year)', () {
      expect(Nic.isValid('189915012345'), isFalse);
    });

    test('rejects a birth year in the future', () {
      final int futureYear = DateTime.now().year + 1;
      expect(Nic.isValid('$futureYear' '15012345'), isFalse);
    });

    test('accepts the current year as a birth year', () {
      final int currentYear = DateTime.now().year;
      expect(Nic.isValid('$currentYear' '15012345'), isTrue);
    });
  });
}
