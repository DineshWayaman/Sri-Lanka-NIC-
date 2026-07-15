/// Parse, validate, decode, and convert Sri Lankan National Identity Card
/// (NIC) numbers.
///
/// This library never verifies the NIC check digit — the Department for
/// Registration of Persons has never published that algorithm, so any
/// "verification" would be a fabricated checksum that risks rejecting real,
/// issued NICs. All validation here is structural only.
library;

export 'src/builder.dart';
export 'src/enums.dart';
export 'src/exceptions.dart';
export 'src/extensions.dart';
export 'src/nic.dart';
export 'src/nic_details.dart';
