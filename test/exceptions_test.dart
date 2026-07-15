import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('NicLengthException', () {
    test('is thrown for a 9-character input with the original input preserved',
        () {
      try {
        Nic.parse('123456789');
        fail('expected NicLengthException');
      } on NicLengthException catch (e) {
        expect(e.input, '123456789');
        expect(e.message, contains('length 9'));
        expect(e.message, contains('10 characters'));
        expect(e.message, contains('12 digits'));
      }
    });

    test('is thrown for a 13-character input', () {
      expect(
        () => Nic.parse('1234567890123'),
        throwsA(isA<NicLengthException>()),
      );
    });

    test('toString includes the message and the input', () {
      final NicLengthException e = NicLengthException('abc', 3);
      expect(e.toString(), contains(e.message));
      expect(e.toString(), contains('abc'));
    });
  });

  group('NicCharacterException', () {
    test('is thrown for a non-digit body in an old-format NIC', () {
      try {
        Nic.parse('88032456AV');
        fail('expected NicCharacterException');
      } on NicCharacterException catch (e) {
        expect(e.input, '88032456AV');
        expect(e.message, contains('invalid character'));
      }
    });

    test('is thrown for an invalid suffix letter', () {
      try {
        Nic.parse('880324567A');
        fail('expected NicCharacterException');
      } on NicCharacterException catch (e) {
        expect(e.message, contains('V'));
        expect(e.message, contains('X'));
      }
    });

    test('is thrown for a non-digit character in a modern-format NIC', () {
      expect(
        () => Nic.parse('20001501234A'),
        throwsA(isA<NicCharacterException>()),
      );
    });
  });

  group('NicDayOfYearException', () {
    test('is thrown for raw day-of-year 499 with a specific message', () {
      try {
        Nic.parse('884994567V');
        fail('expected NicDayOfYearException');
      } on NicDayOfYearException catch (e) {
        expect(e.input, '884994567V');
        expect(e.message, contains('499'));
        expect(e.message, contains('1-366'));
        expect(e.message, contains('501-866'));
      }
    });

    test('is thrown for raw day-of-year 000', () {
      expect(
        () => Nic.parse('880004567V'),
        throwsA(isA<NicDayOfYearException>()),
      );
    });

    test('is thrown for raw day-of-year beyond 866', () {
      expect(
        () => Nic.parse('888674567V'),
        throwsA(isA<NicDayOfYearException>()),
      );
    });
  });

  group('NicYearException', () {
    test('is thrown for a birth year before 1900', () {
      try {
        Nic.parse('189915012345');
        fail('expected NicYearException');
      } on NicYearException catch (e) {
        expect(e.input, '189915012345');
        expect(e.message, contains('1899'));
        expect(e.message, contains('1900'));
      }
    });

    test('is thrown for a birth year in the future', () {
      final int futureYear = DateTime.now().year + 1;
      expect(
        () => Nic.parse('$futureYear' '15012345'),
        throwsA(isA<NicYearException>()),
      );
    });
  });

  group('NicFormatException', () {
    test('carries a caller-supplied detail message', () {
      final NicFormatException e =
          NicFormatException('199110402754', 'test detail');
      expect(e.input, '199110402754');
      expect(e.message, 'test detail');
    });
  });

  group('sealed hierarchy', () {
    test('every NicException thrown by parse is one of the five subtypes', () {
      const List<String> invalidInputs = [
        '123456789', // length
        '88032456AV', // character
        '884994567V', // day-of-year
        '189915012345', // year
      ];
      for (final String input in invalidInputs) {
        try {
          Nic.parse(input);
          fail('expected a NicException for "$input"');
        } on NicException catch (e) {
          final String description = switch (e) {
            NicLengthException() => 'length',
            NicCharacterException() => 'character',
            NicDayOfYearException() => 'dayOfYear',
            NicYearException() => 'year',
            NicFormatException() => 'format',
          };
          expect(description, isNotEmpty);
        }
      }
    });
  });
}
