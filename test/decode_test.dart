import 'package:sri_lanka_nic/src/decode.dart';
import 'package:sri_lanka_nic/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('isLeapYear', () {
    test('years divisible by 4 but not 100 are leap', () {
      expect(isLeapYear(1988), isTrue);
      expect(isLeapYear(1996), isTrue);
      expect(isLeapYear(2004), isTrue);
    });

    test('years divisible by 100 but not 400 are not leap', () {
      expect(isLeapYear(1900), isFalse);
      expect(isLeapYear(2100), isFalse);
    });

    test('years divisible by 400 are leap', () {
      expect(isLeapYear(2000), isTrue);
    });

    test('years not divisible by 4 are not leap', () {
      expect(isLeapYear(1991), isFalse);
      expect(isLeapYear(2001), isFalse);
    });
  });

  group('decodeGenderAndDayOfYear', () {
    test('raw < 500 decodes as male with the raw value as day-of-year', () {
      final result = decodeGenderAndDayOfYear(32);
      expect(result.gender, Gender.male);
      expect(result.dayOfYear, 32);
    });

    test('raw >= 500 decodes as female with the offset removed', () {
      final result = decodeGenderAndDayOfYear(532);
      expect(result.gender, Gender.female);
      expect(result.dayOfYear, 32);
    });

    test('raw == 1 is the minimum valid male day', () {
      final result = decodeGenderAndDayOfYear(1);
      expect(result.gender, Gender.male);
      expect(result.dayOfYear, 1);
    });

    test('raw == 366 is the maximum valid male day', () {
      final result = decodeGenderAndDayOfYear(366);
      expect(result.gender, Gender.male);
      expect(result.dayOfYear, 366);
    });

    test('raw == 501 is the minimum valid female day', () {
      final result = decodeGenderAndDayOfYear(501);
      expect(result.gender, Gender.female);
      expect(result.dayOfYear, 1);
    });

    test('raw == 866 is the maximum valid female day', () {
      final result = decodeGenderAndDayOfYear(866);
      expect(result.gender, Gender.female);
      expect(result.dayOfYear, 366);
    });

    test('raw == 0 throws FormatException', () {
      expect(() => decodeGenderAndDayOfYear(0), throwsFormatException);
    });

    test('raw == 367 throws FormatException (gap before female offset)', () {
      expect(() => decodeGenderAndDayOfYear(367), throwsFormatException);
    });

    test('raw == 499 throws FormatException', () {
      expect(() => decodeGenderAndDayOfYear(499), throwsFormatException);
    });

    test('raw == 500 throws FormatException (female day 0)', () {
      expect(() => decodeGenderAndDayOfYear(500), throwsFormatException);
    });

    test('raw == 867 throws FormatException (beyond max female day)', () {
      expect(() => decodeGenderAndDayOfYear(867), throwsFormatException);
    });
  });

  group('decodeBirthday — leap years (no correction needed)', () {
    test('day 32 in leap year 1988 is Feb 1', () {
      final DateTime result = decodeBirthday(birthYear: 1988, dayOfYear: 32);
      expect(result, DateTime.utc(1988, 2, 1));
    });

    test('day 150 in leap year 2000 is May 29', () {
      final DateTime result = decodeBirthday(birthYear: 2000, dayOfYear: 150);
      expect(result, DateTime.utc(2000, 5, 29));
    });

    test('day 366 in leap year 1996 is Dec 31', () {
      final DateTime result = decodeBirthday(birthYear: 1996, dayOfYear: 366);
      expect(result, DateTime.utc(1996, 12, 31));
    });

    test('day 60 in leap year 2000 is Feb 29 (the real Feb 29)', () {
      final DateTime result = decodeBirthday(birthYear: 2000, dayOfYear: 60);
      expect(result, DateTime.utc(2000, 2, 29));
    });
  });

  group('decodeBirthday — non-leap years, day < 60 (no correction needed)', () {
    test('day 32 in non-leap year 1991 is Feb 1', () {
      final DateTime result = decodeBirthday(birthYear: 1991, dayOfYear: 32);
      expect(result, DateTime.utc(1991, 2, 1));
    });

    test('day 59 in non-leap year 1991 is Feb 28 (last day before the trap)',
        () {
      final DateTime result = decodeBirthday(birthYear: 1991, dayOfYear: 59);
      expect(result, DateTime.utc(1991, 2, 28));
    });
  });

  group('decodeBirthday — non-leap years, day > 60 (the ±1 trap)', () {
    test('day 104 in non-leap year 1991 is Apr 13 (hand-verified)', () {
      final DateTime result = decodeBirthday(birthYear: 1991, dayOfYear: 104);
      expect(result, DateTime.utc(1991, 4, 13));
    });

    test('day 61 in non-leap year 1991 is Mar 1 (immediately after the trap)',
        () {
      final DateTime result = decodeBirthday(birthYear: 1991, dayOfYear: 61);
      expect(result, DateTime.utc(1991, 3, 1));
    });

    test('day 365 in non-leap year 1991 is Dec 30 (shifted back one)', () {
      final DateTime result = decodeBirthday(birthYear: 1991, dayOfYear: 365);
      expect(result, DateTime.utc(1991, 12, 30));
    });

    test(
        'day 366 in non-leap year 1991 is Dec 31 (soft-accepted edge, max valid day)',
        () {
      final DateTime result = decodeBirthday(birthYear: 1991, dayOfYear: 366);
      expect(result, DateTime.utc(1991, 12, 31));
    });
  });

  group('decodeBirthday — day 60 in a non-leap year (ambiguous edge)', () {
    test('resolves to Mar 1 without throwing', () {
      final DateTime result = decodeBirthday(birthYear: 1991, dayOfYear: 60);
      expect(result, DateTime.utc(1991, 3, 1));
    });
  });
}
