import 'decode.dart';
import 'enums.dart';
import 'exceptions.dart';
import 'nic_details.dart';

/// Regex matching one or more internal whitespace/hyphen separators that
/// [Nic.normalize] strips (e.g. `"88 032 4567 V"`, `"88-032-4567-V"`).
final RegExp _separators = RegExp(r'[\s-]+');

/// The structural fields sliced out of a normalized NIC string, before
/// birthday decoding (layered on top by [Nic.parse] via [decodeBirthday]).
typedef _SlicedFields = ({
  NicFormat format,
  int birthYear,
  int rawDayOfYearField,
  Gender gender,
  int dayOfYear,
  String serialNumber,
  String checkDigit,
  VotingEligibility votingEligibility,
});

/// Entry point for parsing and validating Sri Lankan NIC numbers.
///
/// All methods are static; this class is never instantiated.
abstract final class Nic {
  const Nic._();

  /// Normalizes [input] for parsing: trims leading/trailing whitespace,
  /// strips internal spaces and hyphens, and uppercases a trailing letter
  /// (old-format `v`/`x` suffix).
  ///
  /// This does not validate the result — a normalized string can still be
  /// structurally invalid.
  static String normalize(String input) {
    final String stripped = input.trim().replaceAll(_separators, '');
    if (stripped.isEmpty) return stripped;
    final String last = stripped[stripped.length - 1];
    final String upperLast = last.toUpperCase();
    if (last == upperLast) return stripped;
    return '${stripped.substring(0, stripped.length - 1)}$upperLast';
  }

  /// Returns whether [input] is a structurally valid NIC.
  ///
  /// This never checks the check digit (unpublished algorithm) — it only
  /// confirms length, character set, and field ranges.
  static bool isValid(String input) => tryParse(input) != null;

  /// Parses and fully decodes [input].
  ///
  /// Throws a specific [NicException] subtype on any structural failure.
  /// Never verifies the check digit.
  static NicDetails parse(String input) {
    final String normalized = normalize(input);
    final _SlicedFields fields = _sliceAndValidate(input, normalized);
    final DateTime birthday = decodeBirthday(
      birthYear: fields.birthYear,
      dayOfYear: fields.dayOfYear,
    );
    return NicDetails(
      raw: normalized,
      format: fields.format,
      birthYear: fields.birthYear,
      birthday: birthday,
      dayOfYear: fields.dayOfYear,
      rawDayOfYearField: fields.rawDayOfYearField,
      gender: fields.gender,
      serialNumber: fields.serialNumber,
      checkDigit: fields.checkDigit,
      votingEligibility: fields.votingEligibility,
    );
  }

  /// Non-throwing variant of [parse]. Returns `null` on any failure.
  static NicDetails? tryParse(String input) {
    try {
      return parse(input);
    } on NicException {
      return null;
    }
  }

  static bool _isAllDigits(String s) {
    for (int i = 0; i < s.length; i++) {
      final int unit = s.codeUnitAt(i);
      if (unit < 0x30 || unit > 0x39) return false;
    }
    return true;
  }

  /// Detects the NIC format of an already-[normalize]d string and confirms
  /// its length and character set, without decoding any fields.
  static NicFormat _detectFormat(String original, String normalized) {
    if (normalized.length == 10) {
      final String digits = normalized.substring(0, 9);
      final String suffix = normalized[9];
      if (!_isAllDigits(digits)) {
        throw NicCharacterException(
          original,
          'old-format NIC must have 9 digits before the suffix letter, '
          'got "$digits".',
        );
      }
      if (suffix != 'V' && suffix != 'X') {
        throw NicCharacterException(
          original,
          'old-format suffix must be "V" or "X" (case-insensitive), '
          'got "$suffix".',
        );
      }
      return NicFormat.old;
    }
    if (normalized.length == 12) {
      if (!_isAllDigits(normalized)) {
        throw NicCharacterException(
          original,
          'modern-format NIC must be 12 digits, got "$normalized".',
        );
      }
      return NicFormat.modern;
    }
    throw NicLengthException(original, normalized.length);
  }

  /// Slices every structural field out of [normalized], validating
  /// character set, day-of-year range, and birth-year plausibility.
  ///
  /// Does not decode the birthday itself — that's layered on top once
  /// [decodeBirthday] is wired in.
  static _SlicedFields _sliceAndValidate(String original, String normalized) {
    final NicFormat format = _detectFormat(original, normalized);

    final int birthYear;
    final int rawDayOfYearField;
    final String serialNumber;
    final String checkDigit;
    final VotingEligibility votingEligibility;

    if (format == NicFormat.old) {
      birthYear = 1900 + int.parse(normalized.substring(0, 2));
      rawDayOfYearField = int.parse(normalized.substring(2, 5));
      serialNumber = normalized.substring(5, 8);
      checkDigit = normalized.substring(8, 9);
      votingEligibility = normalized[9] == 'V'
          ? VotingEligibility.eligible
          : VotingEligibility.notEligible;
    } else {
      birthYear = int.parse(normalized.substring(0, 4));
      rawDayOfYearField = int.parse(normalized.substring(4, 7));
      serialNumber = normalized.substring(7, 11);
      checkDigit = normalized.substring(11, 12);
      votingEligibility = VotingEligibility.unknown;
    }

    final ({Gender gender, int dayOfYear}) decoded;
    try {
      decoded = decodeGenderAndDayOfYear(rawDayOfYearField);
    } on FormatException {
      throw NicDayOfYearException(original, rawDayOfYearField);
    }

    final int currentYear = DateTime.now().year;
    if (birthYear < 1900 || birthYear > currentYear) {
      throw NicYearException(original, birthYear);
    }

    return (
      format: format,
      birthYear: birthYear,
      rawDayOfYearField: rawDayOfYearField,
      gender: decoded.gender,
      dayOfYear: decoded.dayOfYear,
      serialNumber: serialNumber,
      checkDigit: checkDigit,
      votingEligibility: votingEligibility,
    );
  }
}
