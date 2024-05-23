import 'package:args/args.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:flutter_bunny/src/commands/create_app_commad.dart';
import 'package:flutter_bunny/src/commands/flutter_bunny_base.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

class FlutterBunnyCommandRunner extends CompletionCommandRunner<int> {
  final FlutterBunnyBase _base;

  FlutterBunnyCommandRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _base = FlutterBunnyBase(
            logger: logger, pubUpdater: pubUpdater, environment: environment),
        super(
            'flutter_bunny', 'A CLI tool that helps to generate Flutter Code') {
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
    addCommand(CreateAppCommand(logger: _base.logger));
  }

  @override
  void printUsage() => _base.logger.info(usage);

  @override
  Future<int> run(Iterable<String> args) async {
    final argResults = _parseArgs(args);
    if (argResults == null) return ExitCode.usage.code;

    if (argResults['verbose'] == true) {
      _base.logger.level = Level.verbose;
    }

    if (argResults['version'] == true) {
      return _base.printVersion();
    }

    return await super.runCommand(argResults) ?? ExitCode.success.code;
  }

  ArgResults? _parseArgs(Iterable<String> args) {
    try {
      return parse(args);
    } on FormatException catch (e, stackTrace) {
      _base.handleError(e.message, stackTrace);
    } on ArgumentError catch (e, stackTrace) {
      _base.handleError(e.message, stackTrace);
    }
    return null;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    _base.logArguments(topLevelResults);
    if (topLevelResults.command != null) {
      return await _runSubCommand(topLevelResults);
    }

    return await super.runCommand(topLevelResults);
  }

  Future<int?> _runSubCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      _base.logger.info(cliVersion);
      return ExitCode.success.code;
    }
    final exitCode = await super.runCommand(topLevelResults);
    await _base.checkForUpdate();
    return exitCode;
  }
}
