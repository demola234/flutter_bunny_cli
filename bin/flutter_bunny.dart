/// Flutter Bunny CLI - A command-line tool to help set up and manage Flutter projects.
///
/// This tool provides commands for creating new Flutter projects with best practices,
/// generating components like screens, widgets, and models, and maintaining projects
/// over time. The CLI offers options for different architectures and state management
/// approaches to suit various development preferences.
///
/// Usage:
/// ```
/// # Create a new Flutter application interactively
/// flutter_bunny create app
///
/// # Generate a screen
/// flutter_bunny generate screen --name HomeScreen
///
/// # Update the CLI to the latest version
/// flutter_bunny update
/// ```
library flutter_bunny;

import 'dart:io';

import 'package:flutter_bunny/src/commands/command_runner.dart';
import 'package:flutter_bunny/src/common/cli_exception.dart';
import 'package:mason_logger/mason_logger.dart';

/// The main entry point for the Flutter Bunny CLI tool.
///
/// This function initializes the CLI, processes command-line arguments,
/// and handles top-level error handling. It delegates command execution
/// to the appropriate handlers in the Flutter Bunny library.
///
/// [args] are the command-line arguments passed to the program.
///
/// Example:
/// ```dart
/// void main(List<String> arguments) async {
///   await flutter_bunny.main(arguments);
/// }
/// ```
Future<void> main(List<String> args) async {
  // Create a logger for output
  final logger = Logger();

  try {
    // Create and run the command runner
    final exitCode = await FlutterBunnyRunner().run(args);
    await _flushThenExit(exitCode);
  } catch (e, stackTrace) {
    // Handle exception gracefully
    _handleError(logger, e, stackTrace);
    exit(ExitCode.software.code);
  }
}

/// Flushes stdout and stderr before exiting the application.
///
/// This ensures all output is properly written before the program terminates.
/// Prevents logs from being cut off when the program exits quickly.
///
/// [status] is the exit code that will be used when terminating the process.
Future<void> _flushThenExit(int status) async {
  await Future.wait([
    stdout.close(),
    stderr.close(),
  ]);
  exit(status);
}

/// Handles errors in a user-friendly manner.
///
/// Provides different error output formatting based on the error type.
/// CLI exceptions get special formatting while other exceptions show a stack trace.
///
/// [logger] is the logger instance used for output.
/// [error] is the caught exception.
/// [stackTrace] is the stack trace associated with the exception.
void _handleError(Logger logger, Object error, StackTrace stackTrace) {
  if (error is CliException) {
    stderr.writeln(error.toString());
    logger.detail('${error.stackTrace ?? stackTrace}');
  } else {
    stderr.writeln('Fatal error: $error');
    logger.detail('$stackTrace');
  }
}
