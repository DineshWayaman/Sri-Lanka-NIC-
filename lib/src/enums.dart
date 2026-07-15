/// The two Sri Lankan NIC number formats.
enum NicFormat {
  /// The pre-2016, 10-character format: 9 digits followed by a `V`/`X` suffix.
  old,

  /// The 2016-onwards, 12-digit numeric-only format.
  modern,
}

/// Gender encoded in the NIC's day-of-year field.
///
/// The DRP encodes gender by adding 500 to the day-of-year for female
/// holders; there is no third value in the source encoding.
enum Gender {
  /// Day-of-year field was in `1..366` (no `+500` offset).
  male,

  /// Day-of-year field was in `501..866` (`+500` offset present).
  female,
}

/// Voter eligibility as recorded on old-format NICs at time of issue.
enum VotingEligibility {
  /// Suffix letter `V`: eligible to vote at time of issue.
  eligible,

  /// Suffix letter `X`: not eligible to vote at time of issue.
  notEligible,

  /// Modern-format NICs do not encode voter status.
  unknown,
}
