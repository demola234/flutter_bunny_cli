import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

class VeryGoodCommandRunner extends CompletionCommandRunner<int> {
  VeryGoodCommandRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _environment = environment ?? Platform.environment,
        super('flutter_bunny', '🌟 A Flutter Bunny Command-Line Interface') {
    argParser
      ..addFlag(
        'version',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );
  }

  /// Map of environments information.
  Map<String, String> get environment => environmentOverride ?? _environment;
  final Map<String, String> _environment;

  /// Standard timeout duration for the CLI.
  static const timeout = Duration(milliseconds: 500);

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      if (argResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      return await runCommand(argResults) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }

  void _showThankYou() {
    if (environment.containsKey('CI')) return;

//     final versionFile = File(
//       path.join(_configDir.path, 'version'),
//     )..createSync(recursive: true);

//     if (versionFile.readAsStringSync() == packageVersion) return;
//     versionFile.writeAsStringSync(packageVersion);

//     _logger.wrap(
//       lightMagenta.wrap('''

// Thank you for using Very Good Ventures open source tools!
// Don't forget to fill out this form to get information on future updates and releases here: ${lightBlue.wrap(link(uri: Uri.parse('https://verygood.ventures/open-source/cli/subscribe-latest-tool-updates')))}'''),
//       print: _logger.info,
//     );
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    _logger
      ..detail('Argument information:')
      ..detail('  Top level options:');
    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.detail('  - $option: ${topLevelResults[option]}');
      }
    }
    if (topLevelResults.command != null) {
      final commandResult = topLevelResults.command!;
      _logger
        ..detail('  Command: ${commandResult.name}')
        ..detail('    Command options:');
      for (final option in commandResult.options) {
        if (commandResult.wasParsed(option)) {
          _logger.detail('    - $option: ${commandResult[option]}');
        }
      }

      if (commandResult.command != null) {
        final subCommandResult = commandResult.command!;
        _logger.detail('    Command sub command: ${subCommandResult.name}');
      }
    }

    int? exitCode = ExitCode.unavailable.code;
    if (topLevelResults['version'] == true) {
      // _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }
    // if (topLevelResults.command?.name != UpdateCommand.commandName) {
    // await _checkForUpdates();
    // }
    _showThankYou();
    return exitCode;
  }
}
