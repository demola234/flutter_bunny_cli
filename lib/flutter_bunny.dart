/// Flutter Bunny CLI 🐰
///
/// A command-line tool to help set up and manage Flutter projects
/// with best practices, common features, and various architectural patterns.
library;

import 'flutter_bunny.dart';

export 'src/commands/command_runner.dart';
export 'src/common/base.dart';
export 'src/common/cli_exception.dart';
export 'src/common/package_info.dart';

/// Main entry point for programmatic usage of Flutter Bunny.
///
/// This class provides static methods to run commands and access
/// utility functions for Flutter project generation.
class FlutterBunny {
  /// Runs the Flutter Bunny CLI with the provided arguments.
  ///
  /// Returns the exit code that should be used when the process terminates.
  static Future<int> run(List<String> args) async {
    final runner = FlutterBunnyRunner();
    return await runner.run(args);
  }

  /// Gets the current version of the Flutter Bunny CLI.
  static String get version => cliVersion;
}
