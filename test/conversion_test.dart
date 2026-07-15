import 'package:sri_lanka_nic/sri_lanka_nic.dart';
import 'package:test/test.dart';

void main() {
  group('toModernFormat', () {
    test('911042754V converts to 199110402754 (design-doc round trip)', () {
      final NicDetails d = Nic.parse('911042754V');
      expect(d.toModernFormat(), '199110402754');
    });

    test('is the identity for an already-modern NIC', () {
      final NicDetails d = Nic.parse('200015012345');
      expect(d.toModernFormat(), '200015012345');
    });

    test('widens a 3-digit serial to 4 digits with a leading zero', () {
      final NicDetails d = Nic.parse('880324567V');
      expect(d.toModernFormat(), '198803204567');
    });

    test('drops the voter letter and preserves the check digit verbatim', () {
      final NicDetails d = Nic.parse('880324567X');
      final String modern = d.toModernFormat();
      expect(modern, hasLength(12));
      expect(modern, endsWith('7'));
    });
  });

  group('toOldFormat', () {
    test('is the identity for an already-old NIC', () {
      final NicDetails d = Nic.parse('880324567V');
      expect(d.toOldFormat(), '880324567V');
    });

    test('round-trips a modern NIC converted from an old one', () {
      final NicDetails old = Nic.parse('911042754V');
      final String modern = old.toModernFormat();
      final NicDetails backToOld = Nic.parse(modern);
      expect(backToOld.toOldFormat(), '911042754V');
    });

    test(
        'throws NicFormatException when the birth year is not in the 20th century',
        () {
      final NicDetails d = Nic.parse('200015012345'); // birthYear 2000
      expect(() => d.toOldFormat(), throwsA(isA<NicFormatException>()));
    });

    test('throws NicFormatException when the serial has no leading zero', () {
      // birthYear 1991, serial "1275" (no leading zero) -> cannot fit in
      // the old format's 3-digit serial.
      final NicDetails d = Nic.parse('199110412754');
      expect(d.serialNumber, '1275');
      expect(() => d.toOldFormat(), throwsA(isA<NicFormatException>()));
    });

    test('defaults the voter letter to V', () {
      final NicDetails d = Nic.parse('199110402754');
      expect(d.toOldFormat(), endsWith('V'));
    });
  });
}
