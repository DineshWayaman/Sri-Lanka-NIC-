// Run with: dart run example/example.dart [nic]
//
// Defaults to a synthetic sample NIC if none is given on the command line.
import 'package:sri_lanka_nic/sri_lanka_nic.dart';

void main(List<String> arguments) {
  final String input = arguments.isNotEmpty ? arguments.first : '200015012345';

  print('Input: $input');

  final NicDetails? details = Nic.tryParse(input);
  if (details == null) {
    // Nic.parse throws a specific NicException subtype; tryParse just
    // reports failure. Use parse directly when you want the reason:
    try {
      Nic.parse(input);
    } on NicException catch (e) {
      print('Invalid NIC: ${e.message}');
    }
    return;
  }

  print('Format:            ${details.format}');
  print('Birth year:        ${details.birthYear}');
  print(
      'Birthday (UTC):    ${details.birthday.toIso8601String().split('T').first}');
  print('Gender:            ${details.gender}');
  print('Age (years):       ${details.ageInYears()}');
  print('Serial number:     ${details.serialNumber}');
  print(
      'Check digit:       ${details.checkDigit} (never verified — see README)');
  print('Voting eligibility ${details.votingEligibility}');

  if (details.format == NicFormat.old) {
    print('As modern format:  ${details.toModernFormat()}');
  } else {
    try {
      print('As old format:     ${details.toOldFormat()}');
    } on NicFormatException catch (e) {
      print('Cannot convert to old format: ${e.message}');
    }
  }

  // Structure-only builder, for test fixtures (not a real, issued NIC):
  final String synthetic = NicBuilder(
    dateOfBirth: DateTime.utc(1995, 6, 15),
    gender: Gender.female,
    serial: 42,
  ).build();
  print('\nSynthetic test NIC (NOT real): $synthetic');
}
