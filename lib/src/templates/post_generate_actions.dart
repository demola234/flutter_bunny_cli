import 'package:flutter_bunny/src/cli/cli_runner.dart';
import 'package:mason/mason.dart';
import 'package:universal_io/io.dart';

/// Runs `flutter pub get` in the [outputDir].
///
/// Completes with `true` is the execution was successful, `false` otherwise.
Future<bool> installFlutterPackages(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  final isFlutterInstalled = await PackageRunner.isFlutterInstalled(logger: logger);
  if (isFlutterInstalled) {
    return PackageRunner.installDependencies(
      cwd: outputDir.path,
      recursive: recursive,
      logger: logger,
    );
  }
  return false;
}

/// Runs `dart fix --apply` in the [outputDir].
Future<void> applyDartFixes(
  Logger logger,
  Directory outputDir, {
  bool recursive = false,
}) async {
  final isFlutterInstalled = await PackageRunner.isFlutterInstalled(logger: logger);
  if (isFlutterInstalled) {
    final applyFixesProgress = logger.progress(
      'Running "dart fix --apply" in ${outputDir.path}',
    );
    await PackageRunner.applyFixes(
      cwd: outputDir.path,
      recursive: recursive,
      logger: logger,
    );
    applyFixesProgress.complete();
  }
}
