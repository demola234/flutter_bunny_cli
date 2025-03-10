// Flutter Bunny CLI Example
//
// This example demonstrates how to use Flutter Bunny programmatically,
// although most users will interact with it via the command line.

import 'package:flutter_bunny/src/commands/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// Example showing how to use Flutter Bunny programmatically.
void main() async {
  // Create a logger for output
  final logger = Logger();

  logger.info('Flutter Bunny CLI Example');

  // Example 1: Run a command programmatically
  logger.info('\nRunning version command:');
  final exitCode = await FlutterBunnyRunner().run(['version']);
  logger.info('Command completed with exit code: $exitCode');

  // Example 2: Create a project programmatically (commented out to avoid actual file creation)
  // To create a project, uncomment the following code:
  /*
  logger.info('\nCreating a new Flutter project:');
  final createExitCode = await FlutterBunny.run([
    'create',
    'app',
    '--name',
    'example_app',
    '--output-directory',
    'output',
    '--architecture',
    'clean_architecture',
    '--state-management',
    'riverpod',
  ]);
  logger.info('Project creation completed with exit code: $createExitCode');
  */

  // Example 3: Generate a component programmatically (commented out to avoid actual file creation)
  /*
  logger.info('\nGenerating a new screen:');
  final generateExitCode = await FlutterBunny.run([
    'generate',
    'screen',
    '--name',
    'HomeScreen',
    '--output',
    'lib/screens',
  ]);
  logger.info('Screen generation completed with exit code: $generateExitCode');
  */

  logger.info('\nExample completed.');
}
