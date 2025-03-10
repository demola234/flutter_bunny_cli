import 'package:args/args.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:universal_io/io.dart';

/// Base class providing shared utilities for the CLI.
///
/// This class handles common operations like logging, environment checks,
/// and update verification.
class Base {
  final Logger _logger;
  final PubUpdater _pubUpdater;
  final Map<String, String> _environment;

  /// Timeout for update checks.
  static const timeout = Duration(milliseconds: 1000);

  /// Creates a new Base instance.
  ///
  /// [logger] is used for console output.
  /// [pubUpdater] is used to check for updates.
  /// [environment] is used for environment variables.
  Base({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _environment = environment ?? Platform.environment;

  /// Gets the environment variables.
  Map<String, String> get environment => _environment;

  /// Gets the logger.
  Logger get logger => _logger;

  /// Checks for updates to the CLI.
  ///
  /// If an update is available, it displays a message.
  Future<void> checkForUpdate() async {
    try {
      final isUpToDate = await _pubUpdater
          .isUpToDate(
            packageName: packageName,
            currentVersion: cliVersion,
          )
          .timeout(timeout);

      if (!isUpToDate) {
        final latestVersion = await _pubUpdater.getLatestVersion(packageName);
        _logger.info(
          'Update available: $cliVersion → $latestVersion\n'
          'Run flutter_bunny update to update',
        );
      }
    } catch (error) {
      _logger.detail('Update check failed: $error');
    }
  }

  /// Prints the current version of the CLI.
  Future<int> printVersion() async {
    try {
      final version = await _pubUpdater.getLatestVersion(packageName);
      _logger.info(version);
      return 0;
    } catch (error) {
      _logger.err('Version check failed: $error');
      return 1;
    }
  }

  /// Logs command arguments at the verbose level.
  void logArguments(ArgResults results) {
    if (_logger.level != Level.verbose) return;

    _logger.detail('Arguments: ${results.arguments}');
    if (results.command != null) {
      _logger.detail('Command: ${results.command!.name}');
    }
  }

  /// Validates the environment for Flutter development.
  ///
  /// Checks if Flutter is installed and available.
  Future<void> validateEnvironment() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode != 0) throw Exception('Flutter not found');
    } catch (e) {
      _logger.err('Flutter SDK not found. Please install Flutter first.');
      exit(1);
    }
  }

  /// Handles errors in a consistent way.
  ///
  /// Logs the error and stack trace, then displays usage information.
  void handleError(String message, StackTrace stackTrace) {
    final usage = 'Usage: flutter_bunny <command> [arguments]';

    _logger.err(message);
    _logger.detail('$stackTrace');
    _logger.info('');
    _logger.info(usage);
    exit(1);
  }

  /// Updates the CLI to the latest version.
  ///
  /// Returns true if the update was successful, false otherwise.
  Future<bool> updateCli() async {
    final updateProgress = _logger.progress('Checking for updates');

    try {
      final isUpToDate = await _pubUpdater.isUpToDate(
        packageName: packageName,
        currentVersion: cliVersion,
      );

      if (isUpToDate) {
        updateProgress.complete('Already up to date');
        return true;
      }

      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      updateProgress.update('Updating to $latestVersion');

      if (isUpToDate) {
        updateProgress.complete('Updated to $latestVersion');
        return true;
      } else {
        updateProgress.fail('Update failed');
        return false;
      }
    } catch (e) {
      updateProgress.fail('Update failed: $e');
      return false;
    }
  }
}
