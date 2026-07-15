import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('NicBuilder — modern format round trips', () {
    test('male, leap-year birthday round-trips through parse', () {
      final String built = NicBuilder(
        dateOfBirth: DateTime.utc(2000, 5, 29),
        gender: Gender.male,
        serial: 1234,
      ).build();
      expect(built, hasLength(12));

      final NicDetails d = Nic.parse(built);
      expect(d.format, NicFormat.modern);
      expect(d.birthYear, 2000);
      expect(d.gender, Gender.male);
      expect(d.birthday, DateTime.utc(2000, 5, 29));
      expect(d.serialNumber, '1234');
      expect(d.checkDigit, '0');
    });

    test('female, non-leap-year birthday after the ±1 trap round-trips', () {
      final String built = NicBuilder(
        dateOfBirth: DateTime.utc(1991, 4, 13),
        gender: Gender.female,
        serial: 42,
      ).build();

      final NicDetails d = Nic.parse(built);
      expect(d.gender, Gender.female);
      expect(d.birthday, DateTime.utc(1991, 4, 13));
      expect(d.serialNumber, '0042');
    });

    test('non-leap-year birthday before the trap (day < 60) round-trips', () {
      final String built = NicBuilder(
        dateOfBirth: DateTime.utc(1991, 2, 1),
        gender: Gender.male,
        serial: 1,
      ).build();

      final NicDetails d = Nic.parse(built);
      expect(d.birthday, DateTime.utc(1991, 2, 1));
    });

    test('non-leap-year Mar 1 round-trips (the day exactly at the trap)', () {
      final String built = NicBuilder(
        dateOfBirth: DateTime.utc(1991, 3, 1),
        gender: Gender.male,
        serial: 1,
      ).build();

      final NicDetails d = Nic.parse(built);
      expect(d.birthday, DateTime.utc(1991, 3, 1));
    });

    test('leap-year Feb 29 round-trips', () {
      final String built = NicBuilder(
        dateOfBirth: DateTime.utc(2000, 2, 29),
        gender: Gender.male,
        serial: 1,
      ).build();

      final NicDetails d = Nic.parse(built);
      expect(d.birthday, DateTime.utc(2000, 2, 29));
    });

    test('rejects a serial above 9999', () {
      expect(
        () => NicBuilder(
          dateOfBirth: DateTime.utc(2000, 1, 1),
          gender: Gender.male,
          serial: 10000,
        ).build(),
        throwsArgumentError,
      );
    });

    test('rejects a serial below 1', () {
      expect(
        () => NicBuilder(
          dateOfBirth: DateTime.utc(2000, 1, 1),
          gender: Gender.male,
          serial: 0,
        ).build(),
        throwsArgumentError,
      );
    });
  });

  group('NicBuilder — old format round trips', () {
    test('male round-trips with default voting eligibility', () {
      final String built = NicBuilder(
        dateOfBirth: DateTime.utc(1988, 2, 1),
        gender: Gender.male,
        serial: 456,
        format: NicFormat.old,
      ).build();
      expect(built, hasLength(10));
      expect(built, endsWith('V'));

      final NicDetails d = Nic.parse(built);
      expect(d.format, NicFormat.old);
      expect(d.birthYear, 1988);
      expect(d.gender, Gender.male);
      expect(d.birthday, DateTime.utc(1988, 2, 1));
      expect(d.serialNumber, '456');
      expect(d.votingEligibility, VotingEligibility.eligible);
    });

    test('female with notEligible voting produces an X suffix', () {
      final String built = NicBuilder(
        dateOfBirth: DateTime.utc(1988, 2, 1),
        gender: Gender.female,
        serial: 456,
        format: NicFormat.old,
        voting: VotingEligibility.notEligible,
      ).build();
      expect(built, endsWith('X'));

      final NicDetails d = Nic.parse(built);
      expect(d.gender, Gender.female);
      expect(d.votingEligibility, VotingEligibility.notEligible);
    });

    test('rejects VotingEligibility.unknown for the old format', () {
      expect(
        () => NicBuilder(
          dateOfBirth: DateTime.utc(1988, 2, 1),
          gender: Gender.male,
          serial: 456,
          format: NicFormat.old,
          voting: VotingEligibility.unknown,
        ).build(),
        throwsArgumentError,
      );
    });

    test('rejects a birth year outside 1900-1999', () {
      expect(
        () => NicBuilder(
          dateOfBirth: DateTime.utc(2000, 1, 1),
          gender: Gender.male,
          serial: 1,
          format: NicFormat.old,
        ).build(),
        throwsArgumentError,
      );
    });

    test('rejects a serial above 999', () {
      expect(
        () => NicBuilder(
          dateOfBirth: DateTime.utc(1988, 1, 1),
          gender: Gender.male,
          serial: 1000,
          format: NicFormat.old,
        ).build(),
        throwsArgumentError,
      );
    });
  });
}
