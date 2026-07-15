## 0.1.0

Initial release.

- Parse and fully decode both NIC formats (old 10-character, modern 12-digit):
  birth year, date of birth, gender, serial number, check digit (exposed,
  never verified), and voter eligibility.
- Typed, specific exceptions for every structural failure
  (`NicLengthException`, `NicCharacterException`, `NicDayOfYearException`,
  `NicYearException`, `NicFormatException`) instead of a single generic error.
- Documented, tested leap-year day-of-year decode, including the
  non-leap-year "phantom Feb 29" correction.
- Old &lt;-&gt; new format conversion (`toModernFormat`/`toOldFormat`).
- `NicBuilder` for generating structurally-valid synthetic NICs for test
  fixtures.
- `String` extensions: `toNicOrNull()`, `isValidNic()`.
- Pure Dart, zero runtime dependencies, no Flutter dependency.
