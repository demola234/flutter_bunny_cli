import 'dart:io';

/// Extension methods to handle compatibility issues with PubUpdater.
extension PubUpdaterResultExtension on Object {
  /// Safely converts the result of PubUpdater operations to a boolean.
  ///
  /// Handles both boolean returns and ProcessResult returns.
  bool toBool() {
    if (this is bool) {
      return this as bool;
    } else if (this is ProcessResult) {
      return (this as ProcessResult).exitCode == 0;
    }
    return false;
  }
}
