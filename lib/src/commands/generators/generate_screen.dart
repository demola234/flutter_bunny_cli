import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// Command to generate a new screen/page in a Flutter application.
class GenerateScreenCommand extends Command<int> {
  /// Creates a new GenerateScreenCommand.
  ///
  /// [logger] is used for console output.
  GenerateScreenCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Name of the screen to generate',
        mandatory: true,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory relative to lib/',
        defaultsTo: 'screens',
      )
      ..addFlag(
        'stateful',
        abbr: 's',
        help: 'Generate a StatefulWidget instead of a StatelessWidget',
        negatable: false,
      )
      ..addFlag(
        'with-test',
        help: 'Generate a corresponding test file',
        defaultsTo: true,
      );
  }

  /// Logger for console output.
  final Logger _logger;

  @override
  String get description => 'Generate a new screen/page';

  @override
  String get name => 'screen';

  @override
  Future<int> run() async {
    final screenName = argResults?['name'] as String;
    final outputDir = argResults?['output'] as String;
    final isStateful = argResults?['stateful'] as bool;
    final withTest = argResults?['with-test'] as bool;

    // Validate screen name
    if (!_isValidName(screenName)) {
      _logger
          .err('Invalid screen name. Please use PascalCase (e.g. HomeScreen).');
      return ExitCode.usage.code;
    }

    // Create screen file
    final result = await _createScreenFile(
      screenName: screenName,
      outputDir: outputDir,
      isStateful: isStateful,
    );

    if (!result) {
      return ExitCode.software.code;
    }

    // Create test file if requested
    if (withTest) {
      await _createTestFile(
        screenName: screenName,
        outputDir: outputDir,
        isStateful: isStateful,
      );
    }

    _logger.info('');
    _logger.info('${lightGreen.wrap('✓')} Successfully generated $screenName!');

    return ExitCode.success.code;
  }

  /// Validates the screen name format.
  bool _isValidName(String name) {
    // Check if name is PascalCase and ends with Screen
    return RegExp(r'^[A-Z][a-zA-Z0-9]*Screen$').hasMatch(name);
  }

  /// Creates the screen file.
  Future<bool> _createScreenFile({
    required String screenName,
    required String outputDir,
    required bool isStateful,
  }) async {
    final progress = _logger.progress('Creating $screenName...');

    try {
      // Ensure output directory exists
      final libDir = _findLibDirectory();
      if (libDir == null) {
        progress.fail(
          'Could not find lib/ directory. Are you in a Flutter project?',
        );
        return false;
      }

      final screenDir = Directory(path.join(libDir.path, outputDir));
      if (!await screenDir.exists()) {
        await screenDir.create(recursive: true);
      }

      // Create the file
      final fileName = _getFileName(screenName);
      final filePath = path.join(screenDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        progress.fail('$screenName already exists at $filePath');
        return false;
      }

      // Generate content based on template
      final content = isStateful
          ? _generateStatefulScreenContent(screenName)
          : _generateStatelessScreenContent(screenName);

      await file.writeAsString(content);
      progress.complete('Created $screenName at ${path.relative(filePath)}');

      return true;
    } catch (e) {
      progress.fail('Failed to create screen: $e');
      return false;
    }
  }

  /// Creates the test file for the screen.
  Future<bool> _createTestFile({
    required String screenName,
    required String outputDir,
    required bool isStateful,
  }) async {
    final progress = _logger.progress('Creating test for $screenName...');

    try {
      // Ensure test directory exists
      final testDir = _findTestDirectory();
      if (testDir == null) {
        progress.fail(
          'Could not find test/ directory. Are you in a Flutter project?',
        );
        return false;
      }

      final screenTestDir = Directory(path.join(testDir.path, outputDir));
      if (!await screenTestDir.exists()) {
        await screenTestDir.create(recursive: true);
      }

      // Create the file
      final fileName = _getTestFileName(screenName);
      final filePath = path.join(screenTestDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        progress.fail('Test for $screenName already exists at $filePath');
        return false;
      }

      // Generate content based on template
      final content = _generateTestContent(screenName, isStateful);

      await file.writeAsString(content);
      progress.complete(
        'Created test for $screenName at ${path.relative(filePath)}',
      );

      return true;
    } catch (e) {
      progress.fail('Failed to create test: $e');
      return false;
    }
  }

  /// Finds the lib directory in the current project.
  Directory? _findLibDirectory() {
    // Start from current directory and look for lib/
    Directory current = Directory.current;
    final libDir = Directory(path.join(current.path, 'lib'));

    if (libDir.existsSync()) {
      return libDir;
    }

    // If not found, look in parent directories (up to 3 levels)
    for (var i = 0; i < 3; i++) {
      final parent = current.parent;
      if (parent.path == current.path) break; // We're at the root

      current = parent;
      final parentLibDir = Directory(path.join(current.path, 'lib'));

      if (parentLibDir.existsSync()) {
        return parentLibDir;
      }
    }

    return null;
  }

  /// Finds the test directory in the current project.
  Directory? _findTestDirectory() {
    // Start from current directory and look for test/
    Directory current = Directory.current;
    final testDir = Directory(path.join(current.path, 'test'));

    if (testDir.existsSync()) {
      return testDir;
    }

    // If not found, look in parent directories (up to 3 levels)
    for (var i = 0; i < 3; i++) {
      final parent = current.parent;
      if (parent.path == current.path) break; // We're at the root

      current = parent;
      final parentTestDir = Directory(path.join(current.path, 'test'));

      if (parentTestDir.existsSync()) {
        return parentTestDir;
      }
    }

    return null;
  }

  /// Gets the file name for the screen.
  String _getFileName(String screenName) {
    final snakeCase = _toSnakeCase(screenName);
    return '$snakeCase.dart';
  }

  /// Gets the file name for the test.
  String _getTestFileName(String screenName) {
    final snakeCase = _toSnakeCase(screenName);
    return '${snakeCase}_test.dart';
  }

  /// Converts PascalCase to snake_case.
  String _toSnakeCase(String pascalCase) {
    return pascalCase.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => match.start == 0
          ? match.group(0)!.toLowerCase()
          : '_${match.group(0)!.toLowerCase()}',
    );
  }

  /// Generates content for a StatelessWidget screen.
  String _generateStatelessScreenContent(String screenName) {
    return '''
import 'package:flutter/material.dart';

/// $screenName displays...
///
/// This screen is responsible for...
class $screenName extends StatelessWidget {
  /// Creates a new $screenName.
  const $screenName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$screenName'),
      ),
      body: Center(
        child: const Text('$screenName Content'),
      ),
    );
  }
}
''';
  }

  /// Generates content for a StatefulWidget screen.
  String _generateStatefulScreenContent(String screenName) {
    return '''
import 'package:flutter/material.dart';

/// $screenName displays...
///
/// This screen is responsible for...
class $screenName extends StatefulWidget {
  /// Creates a new $screenName.
  const $screenName({Key? key}) : super(key: key);

  @override
  _${screenName}State createState() => _${screenName}State();
}

class _${screenName}State extends State<$screenName> {
  @override
  void initState() {
    super.initState();
    // TODO: Initialize state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$screenName'),
      ),
      body: Center(
        child: const Text('$screenName Content'),
      ),
    );
  }
  
  @override
  void dispose() {
    // TODO: Clean up resources
    super.dispose();
  }
}
''';
  }

  /// Generates content for a screen test.
  String _generateTestContent(String screenName, bool isStateful) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_app_package/screens/${_toSnakeCase(screenName)}.dart';

void main() {
  testWidgets('$screenName should display correctly', (WidgetTester tester) async {
    // Build our screen and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: $screenName(),
    ));

    // Verify that the screen contains expected elements
    expect(find.text('$screenName'), findsOneOrMore);
    expect(find.text('$screenName Content'), findsOneOrMore);
  });
}
''';
  }
}
