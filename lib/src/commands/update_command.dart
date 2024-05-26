import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/common/constants.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:universal_io/io.dart';

class UpdateCommand extends Command<int> {
  UpdateCommand({
    required Logger logger,
    PubUpdater? pubUpdater,
  })  : logger = logger,
        pubUpdater = pubUpdater ?? PubUpdater();

  final Logger logger;
  final PubUpdater pubUpdater;

  @override
  String get description => 'Update Flutter Bunny CLI.';

  /// The [name] of the command. But static.
  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final updateCheckProgress = logger.progress('Checking for updates');
    late final String latestVersion;
    try {
      latestVersion = await pubUpdater.getLatestVersion(packageName);
    } catch (error) {
      updateCheckProgress.fail();
      logger.err('$error');
      return ExitCode.software.code;
    }
    updateCheckProgress.complete('Checked for updates');

    final isUpToDate = cliVersion == latestVersion;
    if (isUpToDate) {
      logger.info('Bunny CLI is already at the latest version.');
      return ExitCode.success.code;
    } else {
      logger.success(Constants.newVersionMessage
          .replaceAll('X.X.X', cliVersion)
          .replaceAll('Y.Y.Y', latestVersion));
    }

    late ProcessResult result;
    try {
      result = await pubUpdater.update(
        packageName: packageName,
        versionConstraint: latestVersion,
      );
    } catch (error) {
      updateCheckProgress.fail();
      logger.err('$error');
      return ExitCode.software.code;
    }

    if (result.exitCode != ExitCode.success.code) {
      updateCheckProgress.fail();
      logger.err('Error Updating Bunny CLI: ${result.stderr}');
      return ExitCode.software.code;
    }

    updateCheckProgress.complete('Updated to $latestVersion');

    return ExitCode.success.code;
  }
}
