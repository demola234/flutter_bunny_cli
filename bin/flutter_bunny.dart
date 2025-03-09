import 'dart:io';

import 'package:flutter_bunny/src/commands/command_runner.dart';
import 'package:flutter_bunny/src/common/cli_exception.dart';
import 'package:mason_logger/mason_logger.dart';

// The main entry point for the Flutter Bunny CLI tool.
/// This function is the entry point for the Flutter Bunny CLI tool.
/// It creates an instance of [FlutterBunnyCommandRunner] and runs it with
/// the provided arguments.
/// [args] is a list of command-line arguments passed to the tool.
/// The function returns a Future that completes when the runner has finished running.
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
