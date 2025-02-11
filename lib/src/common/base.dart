import 'package:args/args.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:universal_io/io.dart';

class Base {
  final Logger _logger;
  final PubUpdater _pubUpdater;
  final Map<String, String> _environment;
  static const timeout = Duration(milliseconds: 1000);

  Base({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _environment = environment ?? Platform.environment;

  Map<String, String> get environment => _environment;
  Logger get logger => _logger;

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

  void logArguments(ArgResults results) {
    if (_logger.level != Level.verbose) return;

    _logger.detail('Arguments: ${results.arguments}');
    if (results.command != null) {
      _logger.detail('Command: ${results.command!.name}');
    }
  }

  Future<void> validateEnvironment() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode != 0) throw Exception('Flutter not found');
    } catch (e) {
      _logger.err('Flutter SDK not found. Please install Flutter first.');
      exit(1);
    }
  }

  void handleError(String message, StackTrace stackTrace) {
    final usage = 'Usage: flutter_bunny <command> [arguments]';

    _logger.err(message);
    _logger.err('$stackTrace');
    _logger.info('');
    _logger.info(usage);
    exit(1);
  }
}
