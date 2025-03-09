import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/cli/cli_runner.dart';
import 'package:flutter_bunny/src/common/cli_exception.dart';
import 'package:mason_logger/mason_logger.dart';

/// Command to run the build_runner tool for code generation.
class BuildCommand extends Command<int> {
  /// Logger for console output.
  final Logger _logger;

  /// Creates a new BuildCommand.
  ///
  /// [logger] is used for console output.
  BuildCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addFlag(
        'watch',
        abbr: 'w',
        help: 'Watch for file changes and rebuild as needed',
        defaultsTo: false,
        negatable: false,
      )
      ..addFlag(
        'delete-conflicting-outputs',
        abbr: 'd',
        help: 'Delete conflicting outputs to resolve build conflicts',
        defaultsTo: true,
      )
      ..addOption(
        'directory',
        abbr: 'C',
        help: 'Directory in which to run the build_runner',
        defaultsTo: '.',
      );
  }

  @override
  String get description => 'Run build_runner to generate code';

  @override
  String get name => 'build';

  @override
  List<String> get aliases => ['codegen'];

  @override
  String get invocation => 'flutter_bunny build [options]';

  @override
  Future<int> run() async {
    final watch = argResults?['watch'] as bool;
    final deleteConflicting = argResults?['delete-conflicting-outputs'] as bool;
    final directory = argResults?['directory'] as String;

    _logger.info(
        '${watch ? 'Starting' : 'Running'} code generation${watch ? ' in watch mode' : ''}...');

    try {
      final success = await PackageRunner.runBuildRunner(
        logger: _logger,
        cliRunner: CliRunner(),
        cwd: directory,
        deleteConflicting: deleteConflicting,
        watch: watch,
      );

      if (!success) {
        return ExitCode.software.code;
      }

      if (!watch) {
        _logger.success('Code generation completed successfully!');
      }

      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Failed to run build_runner: $e');
      return ExitCode.software.code;
    }
  }
}
