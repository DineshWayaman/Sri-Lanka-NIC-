import 'nic.dart';
import 'nic_details.dart';

/// Convenience extensions for parsing/validating NIC numbers directly off
/// a [String].
extension NicStringExtensions on String {
  /// Shorthand for `Nic.tryParse(this)`.
  NicDetails? toNicOrNull() => Nic.tryParse(this);

  /// Shorthand for `Nic.isValid(this)`.
  bool isValidNic() => Nic.isValid(this);
}
