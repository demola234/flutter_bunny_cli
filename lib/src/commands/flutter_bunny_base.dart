// flutter_bunny_base.dart

import 'package:args/args.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:universal_io/io.dart';

class FlutterBunnyBase {
  final Logger _logger;
  final PubUpdater _pubUpdater;
  final Map<String, String> _environment;

  FlutterBunnyBase({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _environment = environment ?? Platform.environment;

  static const timeout = Duration(milliseconds: 1000);

  Map<String, String> get environment => _environment;

  Logger get logger => _logger;

  Future<void> checkForUpdate() async {
    final isUpToDate = await _pubUpdater.isUpToDate(
        packageName: packageName, currentVersion: cliVersion);
    if (!isUpToDate) {
      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      _logger
        ..info('')
        ..info('''
      ${lightBlue.wrap('update available')} ${lightBlue.wrap(cliVersion)}  \u2192 ${lightCyan.wrap(latestVersion)}
      ${lightBlue.wrap('flutter_bunny update')} to update to the newest version
      ''');
    }
  }

  Future<int> printVersion() async {
    _logger.info(await _pubUpdater.getLatestVersion(packageName));
    return ExitCode.success.code;
  }

  void handleError(String message, StackTrace stackTrace) {
    final usage = 'Usage: flutter_bunny <command> [arguments]';

    _logger
      ..err(message)
      ..err('$stackTrace')
      ..info('')
      ..info(usage);
  }

  void logArguments(ArgResults topLevelResults) {
    _logger
      ..detail('Argument information:')
      ..detail('Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('Command: ${commandResult.name}')
        ..detail('Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('- $option: ${commandResult[option]}');
        }
      }
      if (commandResult.command != null) {
        final subCommandResult = commandResult.command!;
        _logger.detail('Command sub command: ${subCommandResult.name}');
      }
    }
  }
}
