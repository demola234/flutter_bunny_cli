import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

import '../common/cli_exception.dart';
import '../common/package_info.dart';
import '../common/pub_updater_fix.dart';

/// Command to update the Flutter Bunny CLI.
///
/// This command checks for updates to the CLI and installs them if available.
class UpdateCommand extends Command<int> {
  /// Creates a new UpdateCommand.
  ///
  /// [logger] is used for console output.
  /// [pubUpdater] is used to check for updates.
  UpdateCommand(
    this.logger, {
    PubUpdater? pubUpdater,
  }) : _pubUpdater = pubUpdater ?? PubUpdater() {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Force update even if the CLI tool is up to date.',
      negatable: false,
    );
  }

  /// The pub updater used to check for and install updates.
  final PubUpdater _pubUpdater;
  final Logger logger;

  @override
  String get description => 'Update the CLI tool to the latest version';

  @override
  String get name => 'update';

  @override
  Future<int> run() async {
    final forceUpdate = argResults?['force'] as bool? ?? false;

    // Check if we're already up to date
    if (!forceUpdate) {
      final isUpToDate = await _pubUpdater.isUpToDate(
        packageName: packageName,
        currentVersion: cliVersion,
      );

      if (isUpToDate) {
        logger.info(
          'Flutter Bunny is already at the latest version: $cliVersion',
        );
        return ExitCode.success.code;
      }
    }

    // Get the latest version
    final latestVersion = await _pubUpdater.getLatestVersion(packageName);
    logger.info('Updating Flutter Bunny from $cliVersion to $latestVersion...');

    // Run the update
    final updateProgress = logger.progress('Updating Flutter Bunny...');
    try {
      final success = await _pubUpdater.update(
        packageName: packageName,
      );

      final isSuccess = success.toBool();
      if (isSuccess) {
        updateProgress.complete('Flutter Bunny updated to $latestVersion');

        logger.info('');
        logger.info('${lightGreen.wrap('✓')} Update successful!');
        logger.info('');
        logger.info('To verify the update, run:');
        logger.info('  flutter_bunny --version');

        return ExitCode.success.code;
      } else {
        updateProgress.fail('Update failed');
        throw CliException('Failed to update Flutter Bunny.');
      }
    } catch (e) {
      updateProgress.fail('Update failed');
      if (e is! CliException) {
        throw CliException('Failed to update Flutter Bunny: $e');
      }
      rethrow;
    }
  }
}
