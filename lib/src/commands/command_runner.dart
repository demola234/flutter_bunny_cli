import 'package:args/args.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:flutter_bunny/src/commands/create_app_commad.dart';
import 'package:flutter_bunny/src/commands/flutter_bunny_base.dart';
import 'package:flutter_bunny/src/commands/update_command.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:pub_updater/pub_updater.dart';
import 'package:universal_io/io.dart';

/// The command runner for the Flutter Bunny CLI tool.
///
/// This class is responsible for handling command-line arguments,
/// executing the appropriate commands, and providing version information
/// and verbose logging options.
class FlutterBunnyCommandRunner extends CompletionCommandRunner<int> {
  final FlutterBunnyBase _base;

  /// Creates a new instance of [FlutterBunnyCommandRunner].
  ///
  /// [logger] is used for logging messages.
  /// [pubUpdater] is used to check for updates to the CLI tool.
  /// [environment] is a map of environment variables.
  ///
  ///
  FlutterBunnyCommandRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
    Map<String, String>? environment,
  })  : _base = FlutterBunnyBase(
          logger: logger,
          pubUpdater: pubUpdater,
          environment: environment,
        ),
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
        help: 'Enable verbose logging, including all shell commands executed.',
      );
    addCommand(CreateAppCommand(logger: _base.logger));
    addCommand(UpdateCommand(logger: _base.logger));
  }

  /// Prints the usage information for the CLI tool.
  @override
  void printUsage() => _base.logger.info(usage);

  /// Boolean for checking if windows, which can be overridden for
  /// testing purposes.
  @visibleForTesting
  bool? isWindowsOverride;
  bool get _isWindows => isWindowsOverride ?? Platform.isWindows;

  /// Runs the command with the given [args].
  ///
  /// Parses the arguments, sets up logging, and handles the 'version' flag.
  @override
  Future<int> run(Iterable<String> args) async {
    final argResults = _parseArgs(args);
    if (argResults == null) return ExitCode.usage.code;

    if (argResults['verbose'] == true) {
      _base.logger.level = Level.verbose;
    }

    if (argResults['version'] == true) {
      _base.logger.info(cliVersion);
      return ExitCode.success.code;
    }

    return await super.runCommand(argResults) ?? ExitCode.success.code;
  }

  /// Parses the command line arguments.
  ///
  /// Returns an [ArgResults] object if the arguments are valid, otherwise
  /// handles the error and returns null.
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

  /// Runs the command specified by [topLevelResults].
  ///
  /// Logs the arguments and executes the appropriate subcommand if specified.
  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    _base.logArguments(topLevelResults);
    if (topLevelResults.command != null) {
      return await _runSubCommand(topLevelResults);
    }

    return await super.runCommand(topLevelResults);
  }

  /// Runs the subcommand specified in the [topLevelResults].
  ///
  /// Checks for the 'version' flag and prints the version if set.
  /// Otherwise, runs the specified subcommand and checks for updates.
  Future<int?> _runSubCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      _base.logger.info(cliVersion); // Ensure this matches your tests
      return ExitCode.success.code;
    }
    final exitCode = await super.runCommand(topLevelResults);
    await _base.checkForUpdate();
    return exitCode;
  }

  Directory get _configDir {
    if (_isWindows) {
      // Use localappdata on windows
      final localAppData = _base.environment['LOCALAPPDATA']!;
      return Directory(path.join(localAppData, 'FlutterBunny'));
    } else {
      // Try using XDG config folder
      var dirPath = _base.environment['XDG_CONFIG_HOME'];
      // Fallback to $HOME if not following XDG specification
      if (dirPath == null || dirPath.isEmpty) {
        dirPath = _base.environment['HOME'];
      }
      return Directory(path.join(dirPath!, '.flutter_bunny'));
    }
  }
}
