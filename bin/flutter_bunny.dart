import 'dart:io';

import 'package:flutter_bunny/src/commands/command_runner.dart';
import 'package:flutter_bunny/src/common/cli_exception.dart';
import 'package:mason_logger/mason_logger.dart';

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

Future<void> main(List<String> args) async {
  final runner = FlutterBunnyRunner();

  try {
    final exitCode = await runner.run(args);
    await _flushThenExit(exitCode);
  } catch (e, stackTrace) {
    if (e is CliException) {
      stderr.writeln(e.toString());
      if (e.stackTrace != null) {
        stderr.writeln('Stack trace:\n${e.stackTrace}');
      }
    } else {
      stderr.writeln('Fatal error: $e');
      stderr.writeln('Stack trace:\n$stackTrace');
    }
    exit(ExitCode.software.code);
  }
}

// The _flushThenExit function is a utility function that flushes the standard
// output and standard error streams and then exits the application with
// the specified exit code.

Future<void> _flushThenExit(int status) {
  return Future.wait([
    stdout.close(),
    stderr.close(),
  ]).then((_) => exit(status));
}
