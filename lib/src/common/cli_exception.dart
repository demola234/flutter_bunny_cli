class CliException implements Exception {
  CliException(this.message, [this.cause]);
  final String message;
  final dynamic cause;
  StackTrace? _stackTrace;

  /// Get the stack trace
  StackTrace? get stackTrace => _stackTrace;

  /// Set the stack trace
  void setStackTrace(StackTrace trace) {
    _stackTrace = trace;
  }

  @override
  String toString() {
    final buffer = StringBuffer('CliException: $message');
    if (cause != null) {
      buffer.write('\nCause: $cause');
    }
    if (_stackTrace != null) {
      buffer.write('\nStack trace:\n$_stackTrace');
    }
    return buffer.toString();
  }
}

extension CliExceptionUtils on CliException {
  static CliException withTrace(
    String message,
    dynamic cause,
    StackTrace stackTrace,
  ) {
    final exception = CliException(message, cause);
    exception.setStackTrace(stackTrace);
    return exception;
  }
}

class CommandException extends CliException {
  CommandException(super.message, [super.cause]);

  static CommandException withTrace(
    String message,
    dynamic cause,
    StackTrace stackTrace,
  ) {
    final exception = CommandException(message, cause);
    exception.setStackTrace(stackTrace);
    return exception;
  }
}
