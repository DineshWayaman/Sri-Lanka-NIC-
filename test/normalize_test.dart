import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('Nic.normalize', () {
    test('trims leading and trailing whitespace', () {
      expect(Nic.normalize('  880324567V  '), '880324567V');
    });

    test('strips internal spaces', () {
      expect(Nic.normalize('88 032 4567 V'), '880324567V');
    });

    test('strips internal hyphens', () {
      expect(Nic.normalize('88-0324567-V'), '880324567V');
    });

    test('uppercases a lowercase trailing suffix letter', () {
      expect(Nic.normalize('880324567v'), '880324567V');
    });

    test('leaves an already-modern 12-digit NIC untouched', () {
      expect(Nic.normalize('200015012345'), '200015012345');
    });

    test('handles an empty string without throwing', () {
      expect(Nic.normalize(''), '');
    });

    test('handles a whitespace-only string without throwing', () {
      expect(Nic.normalize('   '), '');
    });
  });

  group('Nic.isValid — length', () {
    test('rejects a 9-character string', () {
      expect(Nic.isValid('123456789'), isFalse);
    });

    test('rejects an 11-digit string', () {
      expect(Nic.isValid('12345678901'), isFalse);
    });

    test('rejects a 13-digit string', () {
      expect(Nic.isValid('1234567890123'), isFalse);
    });

    test('accepts a well-formed 10-character old NIC', () {
      expect(Nic.isValid('880324567V'), isTrue);
    });

    test('accepts a well-formed 12-digit modern NIC', () {
      expect(Nic.isValid('200015012345'), isTrue);
    });
  });

  group('Nic.isValid — characters', () {
    test('rejects an old-format NIC with a non-digit body', () {
      expect(Nic.isValid('88032456AV'), isFalse);
    });

    test('rejects an old-format NIC with an invalid suffix letter', () {
      expect(Nic.isValid('880324567A'), isFalse);
    });

    test('accepts a lowercase v suffix (normalized first)', () {
      expect(Nic.isValid('880324567v'), isTrue);
    });

    test('accepts X suffix (not voter-eligible)', () {
      expect(Nic.isValid('880324567X'), isTrue);
    });

    test('rejects a modern-format NIC with a non-digit character', () {
      expect(Nic.isValid('20001501234A'), isFalse);
    });
  });
}
