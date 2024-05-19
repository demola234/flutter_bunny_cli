import 'package:args/args.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:universal_io/io.dart';

class FlutterBunnyCommandRunner extends CompletionCommandRunner<int> {
  FlutterBunnyCommandRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _environment = environment ?? Platform.environment,
        super('flutter_bunny:',
            'A CLI tool that helps to generate Flutter Code') {
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

  /// Standard timeout duration for the CLI.
  static const timeout = Duration(milliseconds: 500);

  final Logger _logger;
  final PubUpdater _pubUpdater;

  /// Map of environments information.
  Map<String, String> get environment => environmentOverride ?? _environment;
  final Map<String, String> _environment;

  @override
  void printUsage() => _logger.info(usage);

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final result = parse(args);

      if (result['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      return await runCommand(result) ?? ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);

      return ExitCode.usage.code;
    } on ArgumentError catch (e, stackTrace) {
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
    }
    return ExitCode.usage.code;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    super.runCommand(topLevelResults);
    if (topLevelResults['version'] == true) {
      _logger.info(await _pubUpdater.getLatestVersion(packageName));
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
      int? exitCode = ExitCode.unavailable.code;
      if (topLevelResults['version'] == true) {
        _logger.info(cliVersion);
        exitCode = ExitCode.success.code;
      } else {
        exitCode = await super.runCommand(topLevelResults);
      }
      // if (topLevelResults.command?.name != UpdateCommand.commandName) {
      //   await checkForUpdate();
      // }

      return exitCode;
    }

    // check for update
    // if update available, print update message
    // if update not available, print that you are up to date
    checkForUpdate() async {
      // check if cli is up to date
      final isUpToDate = await _pubUpdater.isUpToDate(
        packageName: packageName,
        currentVersion: cliVersion,
      );

      if (!isUpToDate) {
        // get latest version
        final latestVersion = await _pubUpdater.getLatestVersion(packageName);

        _logger
          ..info('')
          ..info('''
      ${lightBlue.wrap('update available')} ${lightBlue.wrap(cliVersion)}  \u2192 ${lightCyan.wrap(latestVersion)}
      ${lightBlue.wrap('flutter_bunny update')} to update the newest version
      ''');
      }
    }

    return null;
  }
}
