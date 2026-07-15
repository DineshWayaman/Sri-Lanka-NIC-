# sri_lanka_nic

Parse, validate, decode, and convert Sri Lankan National Identity Card (NIC)
numbers — both the old 10-character format and the modern 12-digit format.

## Why this package

- **Pure Dart, no Flutter dependency.** Runs on any Dart platform (CLI,
  server, web, Flutter) — most alternatives assume Flutter. Zero runtime
  dependencies.
- **Full decode, not just validation.** Get the birth year, exact date of
  birth, gender, serial number, and (old format) voter eligibility — not
  just a `bool`. This is the gap in the only other pub.dev option,
  `nic_validator`, which returns a boolean and nothing else.
- **Typed errors.** Every failure throws a specific `NicException` subtype
  (`NicLengthException`, `NicCharacterException`, `NicDayOfYearException`,
  `NicYearException`, `NicFormatException`) with a human-readable message —
  not one generic exception for every problem.
- **Honest about the check digit.** The Department for Registration of
  Persons has never published the NIC check-digit algorithm. This package
  exposes the digit as a field but **never verifies it**. Any library that
  claims to "validate the checksum" is running a fabricated algorithm that
  risks rejecting real, issued NICs. All validation here is structural only.
- **Correct leap-year handling.** The day-of-year field is counted as if
  every year has 366 days (Feb 29 always "exists" in the counting), so
  decoding a real calendar date for anyone born on/after ~day 60 of a
  non-leap year requires a ±1 correction. This is a well-documented, tested
  edge case here — libraries that skip it are silently off by one day.

## Install

```yaml
dependencies:
  sri_lanka_nic: ^0.1.0
```

## Usage

```dart
import 'package:sri_lanka_nic/sri_lanka_nic.dart';

void main() {
  final NicDetails details = Nic.parse('911042754V');

  print(details.birthYear);          // 1991
  print(details.birthday);           // 1991-04-13 00:00:00.000Z
  print(details.gender);             // Gender.male
  print(details.ageInYears());       // whole years as of DateTime.now()
  print(details.votingEligibility);  // VotingEligibility.eligible

  // Non-throwing variant:
  final NicDetails? maybe = Nic.tryParse('not-a-nic'); // null

  // Structural validity only — never checks the check digit:
  print(Nic.isValid('911042754V')); // true

  // String extensions:
  print('911042754V'.isValidNic()); // true
  '911042754V'.toNicOrNull();       // NicDetails?

  // Old <-> new format conversion:
  print(details.toModernFormat());  // 199110402754

  // Typed errors:
  try {
    Nic.parse('884994567V'); // day-of-year 499 is out of range
  } on NicDayOfYearException catch (e) {
    print(e.message);
  }
}
```

### Generating test fixtures

`NicBuilder` produces structurally-valid NIC strings for tests — it cannot
produce a real check digit (fills `0`), so its output is **not** a real,
issued NIC:

```dart
final String fixture = NicBuilder(
  dateOfBirth: DateTime.utc(1995, 6, 15),
  gender: Gender.female,
  serial: 42,
).build();
```

## Formats

| | Old (pre-2016) | Modern (2016+) |
|---|---|---|
| Length | 10 characters | 12 digits |
| Pattern | `YY DDD SSS C L` | `YYYY DDD SSSS C` |
| Example | `911042754V` | `199110402754` |
| Birth year | last 2 digits (assumed 19xx) | full 4 digits |
| Day-of-year | 3 digits, `+500` if female | 3 digits, `+500` if female |
| Serial | 3 digits | 4 digits |
| Check digit | 1 digit, unpublished algorithm — exposed, not verified | same |
| Voter status | `V` eligible / `X` not eligible | not encoded (`VotingEligibility.unknown`) |

## What this package does not do

- **Check-digit verification.** Not possible without the unpublished DRP
  algorithm — see above.
- **Government database lookups.** Everything runs locally; no network
  access, no PII storage.

## License

BSD-3-Clause
