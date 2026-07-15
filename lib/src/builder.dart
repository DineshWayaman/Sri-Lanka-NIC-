import 'decode.dart';
import 'enums.dart';

/// Builds structurally-valid NIC strings for **test fixtures and form
/// testing only**.
///
/// This cannot produce a real check digit — the DRP has never published
/// that algorithm — so [build] always fills it with `0`. The output is
/// structurally valid but is **not** a real, issued NIC.
final class NicBuilder {
  /// Creates a builder for a synthetic NIC matching [dateOfBirth], [gender],
  /// and [serial].
  ///
  /// [serial] must fit the target [format]'s width: `1..999` for
  /// [NicFormat.old], `1..9999` for [NicFormat.modern]. [voting] only
  /// applies to [NicFormat.old] (the modern format doesn't encode it) and
  /// must not be [VotingEligibility.unknown] when [format] is
  /// [NicFormat.old].
  NicBuilder({
    required this.dateOfBirth,
    required this.gender,
    required this.serial,
    this.format = NicFormat.modern,
    this.voting = VotingEligibility.eligible,
  });

  /// The date of birth to encode.
  final DateTime dateOfBirth;

  /// The gender to encode.
  final Gender gender;

  /// The serial number to encode (issuance order within the birth date).
  final int serial;

  /// Which NIC format to build.
  final NicFormat format;

  /// Voter eligibility to encode. Ignored for [NicFormat.modern].
  final VotingEligibility voting;

  /// Builds the structurally-valid NIC string.
  ///
  /// Throws [ArgumentError] if [serial] doesn't fit [format]'s width, if
  /// [format] is [NicFormat.old] and [dateOfBirth]'s year isn't in
  /// `1900..1999`, or if [format] is [NicFormat.old] and [voting] is
  /// [VotingEligibility.unknown].
  String build() {
    final int dayOfYearField = encodeDayOfYearField(
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
    final String dddStr = dayOfYearField.toString().padLeft(3, '0');

    if (format == NicFormat.old) {
      const int maxSerial = 999;
      if (serial < 1 || serial > maxSerial) {
        throw ArgumentError.value(
          serial,
          'serial',
          'must be between 1 and $maxSerial for the old format',
        );
      }
      final int yy = dateOfBirth.year - 1900;
      if (yy < 0 || yy > 99) {
        throw ArgumentError.value(
          dateOfBirth,
          'dateOfBirth',
          'the old format can only encode birth years 1900-1999',
        );
      }
      final String suffix = switch (voting) {
        VotingEligibility.eligible => 'V',
        VotingEligibility.notEligible => 'X',
        VotingEligibility.unknown => throw ArgumentError.value(
            voting,
            'voting',
            'must be eligible or notEligible for the old format',
          ),
      };
      final String yyStr = yy.toString().padLeft(2, '0');
      final String serialStr = serial.toString().padLeft(3, '0');
      return '$yyStr$dddStr${serialStr}0$suffix';
    }

    const int maxSerial = 9999;
    if (serial < 1 || serial > maxSerial) {
      throw ArgumentError.value(
        serial,
        'serial',
        'must be between 1 and $maxSerial for the modern format',
      );
    }
    final String yyyyStr = dateOfBirth.year.toString().padLeft(4, '0');
    final String serialStr = serial.toString().padLeft(4, '0');
    return '$yyyyStr$dddStr${serialStr}0';
  }
}
