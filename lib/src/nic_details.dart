import 'enums.dart';
import 'exceptions.dart';

/// The fully decoded contents of a Sri Lankan NIC number.
///
/// Every field here is derived from structural decoding only — nothing in
/// this class verifies the NIC's check digit, since the Department for
/// Registration of Persons has never published that algorithm.
final class NicDetails {
  /// Creates a fully-decoded [NicDetails].
  ///
  /// This constructor is not meant to be called directly by library users —
  /// obtain instances via [Nic.parse] or [Nic.tryParse].
  const NicDetails({
    required this.raw,
    required this.format,
    required this.birthYear,
    required this.birthday,
    required this.dayOfYear,
    required this.rawDayOfYearField,
    required this.gender,
    required this.serialNumber,
    required this.checkDigit,
    required this.votingEligibility,
  });

  /// The normalized NIC string this was decoded from.
  final String raw;

  /// Which of the two NIC formats [raw] is in.
  final NicFormat format;

  /// The 4-digit birth year (e.g. `1991`).
  final int birthYear;

  /// The decoded date of birth, as a UTC date at midnight.
  ///
  /// See [rawDayOfYearField] and the leap-year correction documented on
  /// `decodeBirthday` in `decode.dart` for how this is derived.
  final DateTime birthday;

  /// The day-of-year (1..366) with the gender `+500` offset already removed.
  final int dayOfYear;

  /// The raw `DDD` field exactly as it appeared in [raw], before the gender
  /// offset was removed. Exposed for auditing/debugging the decode — most
  /// callers want [dayOfYear] instead.
  final int rawDayOfYearField;

  /// The gender encoded in the day-of-year field.
  final Gender gender;

  /// The serial number, preserved as a string so leading zeros aren't lost.
  final String serialNumber;

  /// The check digit exactly as it appeared in [raw].
  ///
  /// This is exposed for completeness only — it is **never verified**. The
  /// DRP has not published the check-digit algorithm, so any "verification"
  /// would be a fabricated checksum that risks rejecting real, issued NICs.
  final String checkDigit;

  /// Voter eligibility as recorded on old-format NICs, or [VotingEligibility.unknown]
  /// for modern-format NICs (which don't encode this).
  final VotingEligibility votingEligibility;

  /// Computes whole-years age as of [asOf] (defaults to [DateTime.now]).
  ///
  /// Accounts for whether the birthday has occurred yet in [asOf]'s year.
  int ageInYears({DateTime? asOf}) {
    final DateTime now = asOf ?? DateTime.now();
    int age = now.year - birthday.year;
    final bool hadBirthdayThisYear = (now.month > birthday.month) ||
        (now.month == birthday.month && now.day >= birthday.day);
    if (!hadBirthdayThisYear) age--;
    return age;
  }

  /// Converts to the modern 12-digit format.
  ///
  /// Identity if [format] is already [NicFormat.modern]. For an old-format
  /// NIC this prepends the `19` century, widens the 3-digit serial to 4
  /// digits by inserting a leading `0`, and carries the check digit
  /// verbatim (it cannot be recomputed). The voter-eligibility letter is
  /// dropped, since the modern format doesn't encode it.
  String toModernFormat() {
    if (format == NicFormat.modern) return raw;
    final String yy = (birthYear - 1900).toString().padLeft(2, '0');
    final String ddd = rawDayOfYearField.toString().padLeft(3, '0');
    return '19$yy$ddd' '0$serialNumber$checkDigit';
  }

  /// Converts to the old 10-character format.
  ///
  /// Identity if [format] is already [NicFormat.old]. This conversion is
  /// **lossy** and only possible when [birthYear] is in the 20th century
  /// (`1900..1999`) and [serialNumber]'s leading digit is `0` (so it fits
  /// in the old format's 3-digit serial). Otherwise throws
  /// [NicFormatException].
  ///
  /// The voter-eligibility letter cannot be recovered from a modern-format
  /// NIC (that field was dropped in 2016) — this always defaults to `V`
  /// (voter-eligible). Callers who need an accurate letter must look it up
  /// independently and build the string themselves.
  String toOldFormat() {
    if (format == NicFormat.old) return raw;
    if (birthYear < 1900 || birthYear > 1999) {
      throw NicFormatException(
        raw,
        'Cannot convert "$raw" to old format: birth year $birthYear is not '
        'in the 20th century (1900-1999), which the old format cannot '
        'represent.',
      );
    }
    if (!serialNumber.startsWith('0')) {
      throw NicFormatException(
        raw,
        'Cannot convert "$raw" to old format: serial "$serialNumber" has no '
        'leading zero, so it does not fit the old format\'s 3-digit serial.',
      );
    }
    final String yy = (birthYear - 1900).toString().padLeft(2, '0');
    final String ddd = rawDayOfYearField.toString().padLeft(3, '0');
    final String sss = serialNumber.substring(1);
    return '$yy$ddd$sss${checkDigit}V';
  }

  @override
  String toString() =>
      'NicDetails(raw: $raw, format: $format, birthYear: $birthYear, '
      'birthday: ${birthday.toIso8601String().split('T').first}, '
      'gender: $gender, serialNumber: $serialNumber, '
      'votingEligibility: $votingEligibility)';

  @override
  bool operator ==(Object other) =>
      other is NicDetails &&
      other.raw == raw &&
      other.format == format &&
      other.birthYear == birthYear &&
      other.birthday == birthday &&
      other.dayOfYear == dayOfYear &&
      other.rawDayOfYearField == rawDayOfYearField &&
      other.gender == gender &&
      other.serialNumber == serialNumber &&
      other.checkDigit == checkDigit &&
      other.votingEligibility == votingEligibility;

  @override
  int get hashCode => Object.hash(
        raw,
        format,
        birthYear,
        birthday,
        dayOfYear,
        rawDayOfYearField,
        gender,
        serialNumber,
        checkDigit,
        votingEligibility,
      );
}
