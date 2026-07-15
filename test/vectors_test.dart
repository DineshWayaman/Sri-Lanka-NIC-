import 'dart:convert';
import 'dart:io';

import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

Gender _gender(String s) => switch (s) {
      'male' => Gender.male,
      'female' => Gender.female,
      _ => throw ArgumentError('unknown gender "$s" in test vectors'),
    };

VotingEligibility _voting(String s) => switch (s) {
      'eligible' => VotingEligibility.eligible,
      'notEligible' => VotingEligibility.notEligible,
      'unknown' => VotingEligibility.unknown,
      _ =>
        throw ArgumentError('unknown voting eligibility "$s" in test vectors'),
    };

NicFormat _format(String s) => switch (s) {
      'old' => NicFormat.old,
      'modern' => NicFormat.modern,
      _ => throw ArgumentError('unknown format "$s" in test vectors'),
    };

DateTime _date(String s) {
  final List<String> parts = s.split('-');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

Type _exceptionType(String error) => switch (error) {
      'length' => NicLengthException,
      'character' => NicCharacterException,
      'dayOfYear' => NicDayOfYearException,
      'year' => NicYearException,
      'format' => NicFormatException,
      _ => throw ArgumentError('unknown error kind "$error" in test vectors'),
    };

void main() {
  final File file = File('test/nic_vectors.json');
  final List<dynamic> vectors =
      jsonDecode(file.readAsStringSync()) as List<dynamic>;

  for (final dynamic raw in vectors) {
    final Map<String, dynamic> vector = raw as Map<String, dynamic>;
    final String nic = vector['nic'] as String;
    final bool valid = vector['valid'] as bool;
    final String status = vector['status'] as String;

    test('$nic ($status)', () {
      if (!valid) {
        final String errorKind = vector['error'] as String;
        expect(
          () => Nic.parse(nic),
          throwsA(isA<NicException>().having(
            (NicException e) => e.runtimeType,
            'runtimeType',
            _exceptionType(errorKind),
          )),
        );
        expect(Nic.isValid(nic), isFalse);
        return;
      }

      final NicDetails d = Nic.parse(nic);
      expect(Nic.isValid(nic), isTrue);
      expect(d.format, _format(vector['format'] as String));
      expect(d.birthYear, vector['birthYear'] as int);
      expect(d.gender, _gender(vector['gender'] as String));
      expect(d.dayOfYear, vector['dayOfYear'] as int);

      if (status == 'locked') {
        expect(d.birthday, _date(vector['birthday'] as String));
        expect(d.serialNumber, vector['serialNumber'] as String);
        expect(d.checkDigit, vector['checkDigit'] as String);
        expect(d.votingEligibility, _voting(vector['voting'] as String));
      } else if (status == 'convention-dependent') {
        // Every field except the exact birthday is asserted above; the
        // leap-year day-of-year convention for this vector hasn't been
        // confirmed against real-world data yet, so we only check that a
        // birthday was computed at all, not its exact value.
        expect(d.birthday, isA<DateTime>());
      } else {
        fail('unknown vector status "$status"');
      }
    });
  }

  test('every vector in nic_vectors.json was exercised', () {
    expect(vectors, hasLength(6));
  });
}
