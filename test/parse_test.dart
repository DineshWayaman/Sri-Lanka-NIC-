import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('Nic.parse — locked vectors', () {
    test('880324567V: old format, male, 1988-02-01', () {
      final NicDetails d = Nic.parse('880324567V');
      expect(d.format, NicFormat.old);
      expect(d.birthYear, 1988);
      expect(d.gender, Gender.male);
      expect(d.dayOfYear, 32);
      expect(d.birthday, DateTime.utc(1988, 2, 1));
      expect(d.serialNumber, '456');
      expect(d.checkDigit, '7');
      expect(d.votingEligibility, VotingEligibility.eligible);
    });

    test('885324567V: old format, female, 1988-02-01', () {
      final NicDetails d = Nic.parse('885324567V');
      expect(d.format, NicFormat.old);
      expect(d.birthYear, 1988);
      expect(d.gender, Gender.female);
      expect(d.dayOfYear, 32);
      expect(d.birthday, DateTime.utc(1988, 2, 1));
      expect(d.serialNumber, '456');
      expect(d.checkDigit, '7');
      expect(d.votingEligibility, VotingEligibility.eligible);
    });

    test('200015012345: modern format, male, 2000-05-29 (leap year)', () {
      final NicDetails d = Nic.parse('200015012345');
      expect(d.format, NicFormat.modern);
      expect(d.birthYear, 2000);
      expect(d.gender, Gender.male);
      expect(d.dayOfYear, 150);
      expect(d.birthday, DateTime.utc(2000, 5, 29));
      expect(d.serialNumber, '1234');
      expect(d.checkDigit, '5');
      expect(d.votingEligibility, VotingEligibility.unknown);
    });
  });

  group('Nic.parse — convention-dependent vector', () {
    test('911042754V: birthYear/gender/dayOfYear locked, birthday not asserted',
        () {
      final NicDetails d = Nic.parse('911042754V');
      expect(d.format, NicFormat.old);
      expect(d.birthYear, 1991);
      expect(d.gender, Gender.male);
      expect(d.dayOfYear, 104);
      // Birthday IS computed (leap-corrected per our documented convention)
      // but its exact value isn't asserted here since the convention hasn't
      // been confirmed against real-world data yet.
      expect(d.birthday, isA<DateTime>());
    });
  });

  group('Nic.parse — invalid vectors throw', () {
    test('123456789: wrong length', () {
      expect(() => Nic.parse('123456789'), throwsA(isA<NicLengthException>()));
    });

    test('884994567V: invalid day-of-year', () {
      expect(
        () => Nic.parse('884994567V'),
        throwsA(isA<NicDayOfYearException>()),
      );
    });
  });

  group('Nic.tryParse', () {
    test('returns NicDetails for a valid input', () {
      expect(Nic.tryParse('880324567V'), isNotNull);
    });

    test('returns null for an invalid input', () {
      expect(Nic.tryParse('123456789'), isNull);
      expect(Nic.tryParse('884994567V'), isNull);
    });
  });

  group('NicDetails.ageInYears', () {
    test('computes whole years elapsed as of a fixed date', () {
      final NicDetails d = Nic.parse('880324567V'); // 1988-02-01
      expect(d.ageInYears(asOf: DateTime.utc(2026, 2, 1)), 38);
      expect(d.ageInYears(asOf: DateTime.utc(2026, 1, 31)), 37);
      expect(d.ageInYears(asOf: DateTime.utc(2026, 2, 2)), 38);
    });
  });
}
