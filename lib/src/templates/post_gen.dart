import 'package:mason_logger/mason_logger.dart';
import 'package:universal_io/io.dart';

import '../cli/cli_runner.dart';

/// Runs `flutter pub get` in the [outputDir].
///
/// Completes with `true` if the execution was successful, `false` otherwise.
Future<bool> installFlutterPackages(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  try {
    final isFlutterInstalled = await PackageRunner.isFlutterInstalled(
      logger: logger,
      cliRunner: CliRunner(),
    );

    if (!isFlutterInstalled) {
      logger.err('Flutter installation check failed');
      return false;
    }

    final success = await PackageRunner.installDependencies(
      cwd: outputDir.path,
      cliRunner: CliRunner(),
      recursive: recursive,
      logger: logger,
    );

    final successBuilder = await PackageRunner.runBuildRunner(
      cwd: outputDir.path,
      cliRunner: CliRunner(),
      logger: logger,
    );

    if (!success) {
      logger.err('Package installation failed');
      return false;
    }

    if (!successBuilder) {
      logger.err('Unable to run package runner for the project');
      logger.info('flutter_bunny build');
      return false;
    }

    return true;
  } catch (e, stackTrace) {
    logger.err('Unexpected error during package installation');
    logger.detail('$e\n$stackTrace');
    return false;
  }
}

/// Runs `dart fix --apply` in the [outputDir].
Future<void> applyDartFixes(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  try {
    final isFlutterInstalled = await PackageRunner.isFlutterInstalled(
      logger: logger,
      cliRunner: CliRunner(),
    );

    if (!isFlutterInstalled) {
      logger.err('Flutter installation check failed - skipping Dart fixes');
      return;
    }

    final fixProgress = logger.progress('Applying Dart fixes...');

    try {
      await PackageRunner.applyFixes(
        cwd: outputDir.path,
        cliRunner: CliRunner(),
        recursive: recursive,
        logger: logger,
      );
      fixProgress.complete('Dart fixes applied successfully');
    } catch (e) {
      fixProgress.fail('Failed to apply Dart fixes');
      logger.detail('Error: $e');
    }
  } catch (e, stackTrace) {
    logger.err('Unexpected error while applying Dart fixes');
    logger.detail('$e\n$stackTrace');
  }
}

/// Utility function to run pub get specifically for a sub-directory
Future<bool> runPubGetInDir(
  Logger logger,
  String directory,
  CliRunner cliRunner,
) async {
  try {
    final result = await cliRunner.runCommand(
      'flutter',
      ['pub', 'get'],
      log: logger,
      shouldThrowOnError: false,
      dir: directory,
    );

    if (result.exitCode != 0) {
      logger.err('Failed to run pub get in $directory');
      return false;
    }

    return true;
  } catch (e) {
    logger.err('Error running pub get in $directory: $e');
    return false;
  }
}

/// Utility function to verify Flutter tooling existence and versions
Future<bool> verifyFlutterTooling(Logger logger) async {
  final progress = logger.progress('Verifying Flutter tooling...');

  try {
    final cliRunner = CliRunner();

    // Check Flutter version
    final flutterVersion = await cliRunner.runCommand(
      'flutter',
      ['--version'],
      log: logger,
      shouldThrowOnError: false,
    );

    if (flutterVersion.exitCode != 0) {
      progress.fail('Flutter not found or not properly installed');
      return false;
    }

    // Check Dart version
    final dartVersion = await cliRunner.runCommand(
      'dart',
      ['--version'],
      log: logger,
      shouldThrowOnError: false,
    );

    if (dartVersion.exitCode != 0) {
      progress.fail('Dart not found or not properly installed');
      return false;
    }

    progress.complete('Flutter tooling verified successfully');
    return true;
  } catch (e) {
    progress.fail('Error verifying Flutter tooling');
    logger.detail('Error: $e');
    return false;
  }
}
