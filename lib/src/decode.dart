/// Portable NIC decode/encode core.
///
/// Every function here is a pure function of primitive types (`int`,
/// `DateTime`) with no dependency on NIC string formatting, normalization,
/// or the [NicException] hierarchy. This isolation is deliberate: a future
/// Kotlin/JVM port can translate this file's logic directly, and both ports
/// can be verified against the same shared test vectors.
///
/// Range errors are reported via [FormatException] (a generic, portable
/// "invalid argument" signal) — callers in `nic.dart` translate that into
/// the richer, input-aware [NicException] subtypes.
library;

import 'enums.dart';

/// Returns whether [year] is a leap year under the standard Gregorian rule
/// (divisible by 4, except centuries not divisible by 400).
bool isLeapYear(int year) {
  if (year % 4 != 0) return false;
  if (year % 100 != 0) return true;
  return year % 400 == 0;
}

/// Decodes the raw `DDD` (old format) / `DDD` (modern format) day-of-year
/// field into a [Gender] and a gender-offset-free day-of-year.
///
/// The DRP encodes gender by adding 500 to the day-of-year for female
/// holders. [raw] is that combined value (e.g. `532` decodes to female,
/// day 32).
///
/// Throws [FormatException] if the resulting day-of-year is not in
/// `1..366`.
({Gender gender, int dayOfYear}) decodeGenderAndDayOfYear(int raw) {
  final Gender gender = raw >= 500 ? Gender.female : Gender.male;
  final int dayOfYear = gender == Gender.female ? raw - 500 : raw;
  if (dayOfYear < 1 || dayOfYear > 366) {
    throw FormatException(
      'Day-of-year $raw is invalid: must be 1-366 (male) or '
      '501-866 (female).',
    );
  }
  return (gender: gender, dayOfYear: dayOfYear);
}

/// Decodes a gender-offset-free [dayOfYear] (1..366, as returned by
/// [decodeGenderAndDayOfYear]) for the given [birthYear] into a calendar
/// date, applying the DRP's leap-year day-of-year convention.
///
/// The DRP counts the day-of-year field **as if every year had 366 days**
/// (i.e. Feb 29 is always counted, even in non-leap years). So decoding a
/// real calendar date requires correcting for that phantom day when the
/// birth year is not actually a leap year:
///
/// - Leap year: the field maps directly (`effectiveDay = dayOfYear`).
/// - Non-leap year, `dayOfYear < 60` (before the phantom Feb 29): maps
///   directly too — nothing to correct yet.
/// - Non-leap year, `dayOfYear == 60`: an inherently ambiguous case (the
///   field claims a Feb 29 that doesn't exist that year). We resolve it to
///   Mar 1, matching the "roll forward past the phantom day" convention
///   used for every `dayOfYear > 60` case, without throwing — hard-rejecting
///   this would incorrectly invalidate real, issued NICs.
/// - Non-leap year, `dayOfYear > 60`: shift back one day to remove the
///   phantom Feb 29 from the count.
///
/// The result is a UTC `DateTime` at midnight.
DateTime decodeBirthday({required int birthYear, required int dayOfYear}) {
  final int effectiveDay;
  if (isLeapYear(birthYear) || dayOfYear < 60) {
    effectiveDay = dayOfYear;
  } else if (dayOfYear == 60) {
    effectiveDay = 60;
  } else {
    effectiveDay = dayOfYear - 1;
  }
  return DateTime.utc(birthYear, 1, 1).add(Duration(days: effectiveDay - 1));
}

/// The inverse of [decodeBirthday]: computes the raw `DDD` field (including
/// the gender `+500` offset) that a NIC would carry for [dateOfBirth] and
/// [gender].
///
/// Only the year/month/day components of [dateOfBirth] are used. This
/// re-derives the real astronomical day-of-year for [dateOfBirth], then
/// re-inserts the phantom Feb 29 that the DRP's counting convention assumes
/// exists in every year:
///
/// - Leap year: the field equals the real day-of-year directly.
/// - Non-leap year, real day-of-year `< 60` (before Feb 29 would fall):
///   equals the real day-of-year directly — nothing to correct yet.
/// - Non-leap year, real day-of-year `>= 60` (Mar 1 onward): add 1, to
///   account for the phantom Feb 29 the DRP's counting inserts.
///
/// This never produces the ambiguous `DDD == 60` case documented on
/// [decodeBirthday] — that value only arises when *decoding* a non-leap
/// year, never when *encoding* one, since a real Mar 1 in a non-leap year
/// always encodes to day 61.
int encodeDayOfYearField(
    {required DateTime dateOfBirth, required Gender gender}) {
  final DateTime date = DateTime.utc(
    dateOfBirth.year,
    dateOfBirth.month,
    dateOfBirth.day,
  );
  final int actualDayOfYear =
      date.difference(DateTime.utc(date.year, 1, 1)).inDays + 1;

  final int ddd;
  if (isLeapYear(date.year) || actualDayOfYear < 60) {
    ddd = actualDayOfYear;
  } else {
    ddd = actualDayOfYear + 1;
  }
  return gender == Gender.female ? ddd + 500 : ddd;
}
