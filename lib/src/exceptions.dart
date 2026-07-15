/// Base type for every error [Nic] parsing/validation can raise.
///
/// All subtypes are structural — none of them ever verify the NIC check
/// digit, since the Department for Registration of Persons has never
/// published that algorithm.
sealed class NicException implements Exception {
  /// Creates a [NicException] for the given [input] with a human-readable
  /// [message].
  const NicException(this.message, this.input);

  /// Human-readable explanation of what was wrong with [input].
  final String message;

  /// The original (pre-normalization) string that failed to parse.
  final String input;

  @override
  String toString() => 'NicException: $message (input: "$input")';
}

/// Thrown when the normalized input is neither 10 characters (old format)
/// nor 12 characters (modern format).
final class NicLengthException extends NicException {
  /// Creates a [NicLengthException] for [input] whose normalized length was
  /// [actualLength].
  NicLengthException(String input, int actualLength)
      : super(
          'NIC "$input" has length $actualLength after normalization; '
          'expected 10 characters (old format: 9 digits + V/X) or '
          '12 digits (modern format).',
          input,
        );
}

/// Thrown when the input contains characters that cannot appear in the
/// detected (or any) NIC format, e.g. a non-digit in a digit position, or a
/// suffix letter that isn't `V`/`X`.
final class NicCharacterException extends NicException {
  /// Creates a [NicCharacterException] for [input] describing the offending
  /// [detail].
  NicCharacterException(String input, String detail)
      : super('NIC "$input" contains an invalid character: $detail', input);
}

/// Thrown when the decoded day-of-year field falls outside the valid
/// ranges (`1..366` for male, `501..866` for female).
final class NicDayOfYearException extends NicException {
  /// Creates a [NicDayOfYearException] for [input] whose raw day-of-year
  /// field was [rawValue].
  NicDayOfYearException(String input, int rawValue)
      : super(
          'Day-of-year $rawValue is invalid: must be 1-366 (male) or '
          '501-866 (female).',
          input,
        );
}

/// Thrown when the decoded birth year is implausible (outside
/// `1900..currentYear`).
final class NicYearException extends NicException {
  /// Creates a [NicYearException] for [input] whose decoded birth year was
  /// [year].
  NicYearException(String input, int year)
      : super(
          'Birth year $year is out of the plausible range 1900-$_currentYear.',
          input,
        );

  static int get _currentYear => DateTime.now().year;
}

/// Thrown for format-level failures that don't fit the other categories,
/// such as a lossy old&lt;-&gt;new conversion that cannot be represented.
final class NicFormatException extends NicException {
  /// Creates a [NicFormatException] for [input] describing the failure in
  /// [detail].
  NicFormatException(String input, String detail) : super(detail, input);
}
