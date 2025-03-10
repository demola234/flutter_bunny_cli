import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:universal_io/io.dart';

import '../cli/cli_runner.dart';

/// Command to run static analysis on a Flutter project.
class AnalyzeCommand extends Command<int> {
  /// Creates a new AnalyzeCommand.
  AnalyzeCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'directory',
        abbr: 'C',
        help: 'Directory to analyze',
        defaultsTo: '.',
      )
      ..addFlag(
        'fix',
        abbr: 'f',
        help: 'Apply fixes to the code',
        negatable: false,
      )
      ..addFlag(
        'fatal-infos',
        help: 'Treat info level issues as fatal',
        negatable: false,
      )
      ..addFlag(
        'fatal-warnings',
        help: 'Treat warning level issues as fatal',
        defaultsTo: true,
      );
  }

  /// Logger for console output.
  final Logger _logger;

  @override
  String get description => 'Run static analysis on your Flutter project';

  @override
  String get name => 'analyze';

  @override
  Future<int> run() async {
    final directory = argResults?['directory'] as String;
    final shouldFix = argResults?['fix'] as bool;
    final fatalInfos = argResults?['fatal-infos'] as bool;
    final fatalWarnings = argResults?['fatal-warnings'] as bool;

    // Check if the directory is valid
    if (!await Directory(directory).exists()) {
      _logger.err('Directory does not exist: $directory');
      return ExitCode.usage.code;
    }

    // Check if this is a Flutter project
    if (!await _isFlutterProject(directory)) {
      _logger.err('Not a Flutter project: $directory');
      return ExitCode.usage.code;
    }

    final cliRunner = CliRunner();

    // First check if we need to run dart fix
    if (shouldFix) {
      final fixProgress = _logger.progress('Applying fixes...');
      try {
        final fixResult = await cliRunner.runCommand(
          'dart',
          ['fix', '--apply'],
          log: _logger,
          dir: directory,
        );

        if (fixResult.exitCode != 0) {
          fixProgress.fail('Failed to apply fixes');
          _logger.err(fixResult.stderr as String);
          return ExitCode.software.code;
        }

        fixProgress.complete('Fixes applied successfully');
      } catch (e) {
        fixProgress.fail('Failed to apply fixes: $e');
        return ExitCode.software.code;
      }
    }

    // Now run the actual analysis
    final analyzeProgress = _logger.progress('Analyzing Flutter project...');
    try {
      final args = [
        'analyze',
        if (fatalInfos) '--fatal-infos',
        if (fatalWarnings) '--fatal-warnings' else '--no-fatal-warnings',
      ];

      final result = await cliRunner.runCommand(
        'flutter',
        args,
        log: _logger,
        dir: directory,
        shouldThrowOnError: false,
      );

      // Process the output
      final output = result.stdout as String;
      final errorOutput = result.stderr as String;

      if (result.exitCode == 0) {
        analyzeProgress.complete('No issues found!');
        _logger.info(output);
        return ExitCode.success.code;
      } else {
        analyzeProgress.fail('Issues found');

        // Parse the output to provide a more structured report
        _printAnalysisReport(output + errorOutput);

        return ExitCode.software.code;
      }
    } catch (e) {
      analyzeProgress.fail('Failed to analyze project: $e');
      return ExitCode.software.code;
    }
  }

  /// Checks if the directory is a Flutter project.
  Future<bool> _isFlutterProject(String directory) async {
    try {
      final pubspecFile = File('$directory/pubspec.yaml');
      if (!await pubspecFile.exists()) {
        return false;
      }

      final content = await pubspecFile.readAsString();
      return content.contains('sdk: flutter') || content.contains('flutter:');
    } catch (e) {
      _logger.detail('Error checking if directory is a Flutter project: $e');
      return false;
    }
  }

  /// Prints a structured analysis report.
  void _printAnalysisReport(String output) {
    // Count issues by type
    final infoPattern = RegExp(r'info •');
    final warningPattern = RegExp(r'warning •');
    final errorPattern = RegExp(r'error •');

    final infoCount = infoPattern.allMatches(output).length;
    final warningCount = warningPattern.allMatches(output).length;
    final errorCount = errorPattern.allMatches(output).length;

    _logger.info('');
    _logger.info('Analysis Results:');
    _logger.info('${lightRed.wrap('Errors:   ')} $errorCount');
    _logger.info('${lightYellow.wrap('Warnings: ')} $warningCount');
    _logger.info('${lightBlue.wrap('Info:     ')} $infoCount');
    _logger.info('');

    // Print the detailed output
    _logger.info(output);

    // Print some help
    if (errorCount > 0 || warningCount > 0) {
      _logger.info('');
      _logger.info('To automatically fix some issues, try:');
      _logger.info('  flutter_bunny analyze --fix');
    }
  }
}
