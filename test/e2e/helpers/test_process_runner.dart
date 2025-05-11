import 'dart:io';

import 'package:grinder/grinder.dart';

/// Result of running a command in a subprocess.
class CommandResult {
  CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });
  final int exitCode;
  final String stdout;
  final String stderr;

  @override
  String toString() => '''
Command result:
  Exit code: $exitCode
  stdout: $stdout
  stderr: $stderr
''';
}

/// Runs the Flutter Bunny CLI with the given arguments.
///
/// [args] are the command-line arguments to pass to the CLI.
/// [workingDirectory] is the directory to run the command in.
/// Returns a [CommandResult] containing the exit code, stdout, and stderr.
Future<CommandResult> runCommand(
  List<String> args, {
  String? workingDirectory,
}) async {
  // Determine the path to the Flutter Bunny CLI executable
  final isWindows = Platform.isWindows;
  final cliPath = _getCliExecutablePath(isWindows);

  // Run the command
  log('Running: $cliPath ${args.join(' ')}');

  final process = await Process.start(
    isWindows ? 'dart' : 'dart',
    [cliPath, ...args],
    workingDirectory: workingDirectory,
    // Inherit the environment for FLUTTER_ROOT to work correctly
    environment: Platform.environment,
  );

  // Capture stdout and stderr
  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();

  process.stdout.transform(const SystemEncoding().decoder).listen((data) {
    stdoutBuffer.write(data);
    log(data); // Echo to test output for debugging
  });

  process.stderr.transform(const SystemEncoding().decoder).listen((data) {
    stderrBuffer.write(data);
    log('STDERR: $data'); // Echo to test output for debugging
  });

  // Wait for the process to complete
  final exitCode = await process.exitCode;

  return CommandResult(
    exitCode: exitCode,
    stdout: stdoutBuffer.toString(),
    stderr: stderrBuffer.toString(),
  );
}

/// Gets the path to the CLI executable.
String _getCliExecutablePath(bool isWindows) {
  // In a development environment, we use the bin script directly
  final binScript =
      isWindows ? 'bin\\flutter_bunny.dart' : 'bin/flutter_bunny.dart';

  // Check if we're running in the package directory (development mode)
  if (FileSystemEntity.isFileSync(binScript)) {
    return binScript;
  }

  // Otherwise, assume we're running in the test directory
  final relativeScript =
      isWindows ? '..\\bin\\flutter_bunny.dart' : '../bin/flutter_bunny.dart';

  if (FileSystemEntity.isFileSync(relativeScript)) {
    return relativeScript;
  }

  // If all else fails, rely on the pub cache
  return isWindows ? 'bin\\flutter_bunny.dart' : 'bin/flutter_bunny.dart';
}
