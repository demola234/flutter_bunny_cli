import 'package:args/args.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:flutter_bunny/src/commands/create_app_command.dart';
import 'package:flutter_bunny/src/commands/update_app_command.dart';
import 'package:flutter_bunny/src/common/base.dart';
import 'package:flutter_bunny/src/common/cli_exception.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

import 'build_command.dart';

class FlutterBunnyRunner extends CompletionCommandRunner<int> {
  final Base _base;

  FlutterBunnyRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _base = Base(
          logger: logger,
          pubUpdater: pubUpdater,
          environment: environment,
        ),
        super(
          'flutter_bunny',
          'Flutter Bunny CLI 🐰 - Let\'s set up your Flutter project 🚀',
        ) {
    _setupArgParser();
    addCommand(CreateAppCommand(logger: _base.logger));
    addCommand(UpdateCommand(_base.logger));
    addCommand(BuildCommand(logger: _base.logger));
  }

  void _setupArgParser() {
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: true,
        help: 'Prints out the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Enable verbose logging, including all shell commands executed.',
      );
  }

  @override
  void printUsage() => _base.logger.info(usage);

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = await _safeParseArgs(args);
      if (argResults == null) return ExitCode.usage.code;

      _configureLogging(argResults);

      if (argResults['version'] == true) {
        return await _handleVersionFlag();
      }

      return await super.runCommand(argResults) ?? ExitCode.success.code;
    } on CliException catch (e) {
      _base.logger.err(e.toString());
      if (e.stackTrace != null) {
        _base.logger.detail(e.stackTrace.toString());
      }
      return ExitCode.software.code;
    } catch (e, stackTrace) {
      final wrappedException = CliException('Unexpected error occurred', e);
      wrappedException.setStackTrace(stackTrace);
      _base.handleError(wrappedException.toString(), stackTrace);
      return ExitCode.software.code;
    }
  }

  Future<ArgResults?> _safeParseArgs(Iterable<String> args) async {
    try {
      return parse(args);
    } on FormatException catch (e, stackTrace) {
      final exception =
          CliException('Invalid argument format: ${e.message}', e);
      exception.setStackTrace(stackTrace);
      throw exception;
    } on ArgumentError catch (e, stackTrace) {
      final exception = CliException('Invalid argument: ${e.message}', e);
      exception.setStackTrace(stackTrace);
      throw exception;
    }
  }

  void _configureLogging(ArgResults results) {
    if (results['verbose'] == true) {
      _base.logger.level = Level.verbose;
    }
  }

  Future<int> _handleVersionFlag() async {
    _base.logger.info(cliVersion);
    return ExitCode.success.code;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    try {
      _base.logArguments(topLevelResults);

      if (topLevelResults.command == null) {
        return await super.runCommand(topLevelResults);
      }

      return await _executeSubCommand(topLevelResults);
    } on CommandException catch (e) {
      _base.logger.err(e.toString());
      return ExitCode.software.code;
    }
  }

  Future<int?> _executeSubCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      return await _handleVersionFlag();
    }

    final exitCode = await super.runCommand(topLevelResults);
    await _checkForUpdates();
    return exitCode;
  }

  Future<void> _checkForUpdates() async {
    try {
      await _base.checkForUpdate();
    } catch (e) {
      _base.logger.detail('Failed to check for updates: $e');
    }
  }
}
