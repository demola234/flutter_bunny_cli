import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/cli/cli_runner.dart';
import 'package:flutter_bunny/src/common/cli_exception.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// Command to check the health of a Flutter project.
class DoctorCommand extends Command<int> {
  /// Logger for console output.
  final Logger _logger;

  /// Creates a new DoctorCommand.
  DoctorCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'directory',
        abbr: 'C',
        help: 'Directory to check',
        defaultsTo: '.',
      )
      ..addFlag(
        'project-only',
        help: 'Only check project-specific issues, not Flutter SDK',
        negatable: false,
      )
      ..addFlag(
        'fix',
        abbr: 'f',
        help: 'Attempt to fix issues automatically',
        negatable: false,
      );
  }

  @override
  String get description => 'Check the health of your Flutter project';

  @override
  String get name => 'doctor';

  @override
  Future<int> run() async {
    final directory = argResults?['directory'] as String;
    final projectOnly = argResults?['project-only'] as bool;
    final shouldFix = argResults?['fix'] as bool;

    // Check if the directory is valid
    if (!await Directory(directory).exists()) {
      _logger.err('Directory does not exist: $directory');
      return ExitCode.usage.code;
    }

    final cliRunner = CliRunner();
    final health = _logger.progress('Checking project health...');

    try {
      // First run Flutter doctor if needed
      if (!projectOnly) {
        await _runFlutterDoctor(cliRunner);
      }

      // Check project-specific issues
      final issues = await _checkProjectHealth(directory);
      
      if (issues.isEmpty) {
        health.complete('No project issues found!');
      } else {
        health.complete('Found ${issues.length} issues with your project');
        
        // Print the issues
        _logger.info('');
        _logger.info('Project Health Check Results:');
        
        for (int i = 0; i < issues.length; i++) {
          final issue = issues[i];
          _logger.info('${i + 1}. ${lightRed.wrap(issue.title)}');
          _logger.info('   ${issue.description}');
          
          if (issue.canFix && shouldFix) {
            final fixProgress = _logger.progress('   Fixing issue...');
            try {
              final fixed = await issue.fix!();
              if (fixed) {
                fixProgress.complete('Issue fixed!');
              } else {
                fixProgress.fail('Failed to fix the issue automatically');
              }
            } catch (e) {
              fixProgress.fail('Error fixing issue: $e');
            }
          } else if (issue.canFix) {
            _logger.info('   ${lightBlue.wrap('This issue can be fixed automatically with --fix')}');
          }
          
          if (issue.recommendations.isNotEmpty) {
            _logger.info('   Recommendations:');
            for (final recommendation in issue.recommendations) {
              _logger.info('   - $recommendation');
            }
          }
          
          if (i < issues.length - 1) {
            _logger.info('');
          }
        }
      }

      return issues.isEmpty ? ExitCode.success.code : ExitCode.software.code;
    } catch (e) {
      health.fail('Failed to check project health: $e');
      return ExitCode.software.code;
    }
  }

  /// Runs the Flutter doctor command.
  Future<void> _runFlutterDoctor(CliRunner cliRunner) async {
    final flutterProgress = _logger.progress('Running Flutter doctor...');

    try {
      final result = await cliRunner.runCommand(
        'flutter',
        ['doctor', '-v'],
        log: _logger,
        shouldThrowOnError: false,
      );

      if (result.exitCode == 0) {
        flutterProgress.complete('Flutter environment looks good!');
      } else {
        flutterProgress.fail('Issues found with Flutter environment');
      }

      // Print the Flutter doctor output
      _logger.info('');
      _logger.info('Flutter Doctor Output:');
      _logger.info(result.stdout as String);
      _logger.info('');
    } catch (e) {
      flutterProgress.fail('Failed to run Flutter doctor: $e');
    }
  }

  /// Checks the health of a Flutter project.
  Future<List<ProjectIssue>> _checkProjectHealth(String directory) async {
    final issues = <ProjectIssue>[];

    // Check for pubspec.yaml
    final pubspecFile = File(path.join(directory, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      issues.add(
        ProjectIssue(
          title: 'Missing pubspec.yaml',
          description: 'Could not find pubspec.yaml in the project directory.',
          recommendations: [
            'Create a pubspec.yaml file in your project root',
            'Make sure you are running the command in a Flutter project directory',
          ],
        ),
      );
      return issues; // Can't continue without pubspec
    }

    // Check for pubspec lock consistency
    final pubspecLockFile = File(path.join(directory, 'pubspec.lock'));
    if (!await pubspecLockFile.exists()) {
      issues.add(
        ProjectIssue(
          title: 'Missing pubspec.lock',
          description: 'Could not find pubspec.lock in the project directory.',
          recommendations: [
            'Run "flutter pub get" to generate pubspec.lock',
          ],
          canFix: true,
          fix: () async {
            try {
              final result = await Process.run(
                'flutter',
                ['pub', 'get'],
                workingDirectory: directory,
              );
              return result.exitCode == 0;
            } catch (e) {
              return false;
            }
          },
        ),
      );
    } else {
      // Check if pubspec.lock is up to date
      final pubspecMTime = await pubspecFile.lastModified();
      final lockMTime = await pubspecLockFile.lastModified();

      if (pubspecMTime.isAfter(lockMTime)) {
        issues.add(
          ProjectIssue(
            title: 'Outdated pubspec.lock',
            description: 'pubspec.yaml has been modified after pubspec.lock was generated.',
            recommendations: [
              'Run "flutter pub get" to update dependencies',
            ],
            canFix: true,
            fix: () async {
              try {
                final result = await Process.run(
                  'flutter',
                  ['pub', 'get'],
                  workingDirectory: directory,
                );
                return result.exitCode == 0;
              } catch (e) {
                return false;
              }
            },
          ),
        );
      }
    }

    // Check for analysis_options.yaml
    final analysisOptionsFile = File(path.join(directory, 'analysis_options.yaml'));
    if (!await analysisOptionsFile.exists()) {
      issues.add(
        ProjectIssue(
          title: 'Missing analysis_options.yaml',
          description: 'No analysis_options.yaml file found. This file helps maintain code quality.',
          recommendations: [
            'Create an analysis_options.yaml file with appropriate lints',
            'Consider using package:lints/recommended.yaml as a base',
          ],
          canFix: true,
          fix: () async {
            try {
              final file = File(path.join(directory, 'analysis_options.yaml'));
              await file.writeAsString('''
# Recommended lints for Flutter projects
include: package:lints/recommended.yaml

linter:
  rules:
    - always_declare_return_types
    - prefer_single_quotes
    - sort_child_properties_last
    - unawaited_futures
    - use_key_in_widget_constructors
''');
              return true;
            } catch (e) {
              return false;
            }
          },
        ),
      );
    }

    // Check for .gitignore
    final gitignoreFile = File(path.join(directory, '.gitignore'));
    if (!await gitignoreFile.exists()) {
      issues.add(
        ProjectIssue(
          title: 'Missing .gitignore',
          description: 'No .gitignore file found. This file prevents committing generated files.',
          recommendations: [
            'Create a .gitignore file with Flutter-specific ignores',
          ],
          canFix: true,
          fix: () async {
            try {
              final file = File(path.join(directory, '.gitignore'));
              await file.writeAsString('''
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks 
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release
''');
              return true;
            } catch (e) {
              return false;
            }
          },
        ),
      );
    }

    // Check for README.md
    final readmeFile = File(path.join(directory, 'README.md'));
    if (!await readmeFile.exists()) {
      issues.add(
        ProjectIssue(
          title: 'Missing README.md',
          description: 'No README.md file found. Documentation is important!',
          recommendations: [
            'Create a README.md file with project documentation',
            'Include setup instructions and basic usage information',
          ],
        ),
      );
    }

    // Check for tests directory
    final testsDir = Directory(path.join(directory, 'test'));
    if (!await testsDir.exists()) {
      issues.add(
        ProjectIssue(
          title: 'Missing test directory',
          description: 'No test directory found. Testing is essential for robust apps.',
          recommendations: [
            'Create a test directory and add unit, widget, and integration tests',
            'Run "flutter test" to execute your tests',
          ],
          canFix: true,
          fix: () async {
            try {
              final dir = Directory(path.join(directory, 'test'));
              await dir.create();
              
              // Create a sample test file
              final testFile = File(path.join(dir.path, 'widget_test.dart'));
              await testFile.writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Example test', (WidgetTester tester) async {
    // Add your test code here
  });
}
''');
              return true;
            } catch (e) {
              return false;
            }
          },
        ),
      );
    } else {
      // Check if tests directory is empty
      final testFiles = await testsDir.list().toList();
      if (testFiles.isEmpty) {
        issues.add(
          ProjectIssue(
            title: 'Empty test directory',
            description: 'The test directory exists but contains no tests.',
            recommendations: [
              'Add unit, widget, and integration tests to your project',
              'Run "flutter test" to execute your tests',
            ],
          ),
        );
      }
    }

    // Check for lib directory structure
    final libDir = Directory(path.join(directory, 'lib'));
    if (await libDir.exists()) {
      // Check if lib contains more than just main.dart
      final libFiles = await libDir.list().toList();
      if (libFiles.length <= 1) {
        issues.add(
          ProjectIssue(
            title: 'Minimal lib directory structure',
            description: 'The lib directory has minimal structure. Consider organizing your code better.',
            recommendations: [
              'Create subdirectories for different parts of your app (widgets, screens, models, etc.)',
              'Separate business logic from UI code',
            ],
          ),
        );
      }
    }

    return issues;
  }
}

/// Represents an issue found in a project.
class ProjectIssue {
  /// The title or name of the issue.
  final String title;
  
  /// A detailed description of the issue.
  final String description;
  
  /// Recommendations for resolving the issue.
  final List<String> recommendations;
  
  /// Whether the issue can be fixed automatically.
  final bool canFix;
  
  /// A function that attempts to fix the issue.
  final Future<bool> Function()? fix;

  /// Creates a new ProjectIssue.
  ProjectIssue({
    required this.title,
    required this.description,
    this.recommendations = const [],
    this.canFix = false,
    this.fix,
  }) : assert(!canFix || fix != null, 'If canFix is true, fix must be provided');
}