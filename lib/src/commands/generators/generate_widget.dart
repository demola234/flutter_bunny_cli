import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// Command to generate a new reusable widget in a Flutter application.
class GenerateWidgetCommand extends Command<int> {
  /// Creates a new GenerateWidgetCommand.
  ///
  /// [logger] is used for console output.
  GenerateWidgetCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Name of the widget to generate',
        mandatory: true,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory relative to lib/',
        defaultsTo: 'widgets',
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
  String get description => 'Generate a new reusable widget';

  @override
  String get name => 'widget';

  @override
  Future<int> run() async {
    final widgetName = argResults?['name'] as String;
    final outputDir = argResults?['output'] as String;
    final isStateful = argResults?['stateful'] as bool;
    final withTest = argResults?['with-test'] as bool;

    // Validate widget name
    if (!_isValidName(widgetName)) {
      _logger.err(
          'Invalid widget name. Please use PascalCase (e.g. CustomButton).');
      return ExitCode.usage.code;
    }

    // Create widget file
    final result = await _createWidgetFile(
      widgetName: widgetName,
      outputDir: outputDir,
      isStateful: isStateful,
    );

    if (!result) {
      return ExitCode.software.code;
    }

    // Create test file if requested
    if (withTest) {
      await _createTestFile(
        widgetName: widgetName,
        outputDir: outputDir,
        isStateful: isStateful,
      );
    }

    _logger.info('');
    _logger.info('${lightGreen.wrap('✓')} Successfully generated $widgetName!');
    _logger.info('''
To use this widget:

import 'package:${_getPackageName()}/${outputDir.replaceAll('\\', '/')}/${_toSnakeCase(widgetName)}.dart';

// Then in your build method:
$widgetName(),
''');

    return ExitCode.success.code;
  }

  /// Validates the widget name format.
  bool _isValidName(String name) {
    // Check if name is PascalCase
    return RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(name);
  }

  /// Creates the widget file.
  Future<bool> _createWidgetFile({
    required String widgetName,
    required String outputDir,
    required bool isStateful,
  }) async {
    final progress = _logger.progress('Creating $widgetName...');

    try {
      // Ensure output directory exists
      final libDir = _findLibDirectory();
      if (libDir == null) {
        progress.fail(
            'Could not find lib/ directory. Are you in a Flutter project?');
        return false;
      }

      final widgetDir = Directory(path.join(libDir.path, outputDir));
      if (!await widgetDir.exists()) {
        await widgetDir.create(recursive: true);
      }

      // Create the file
      final fileName = _getFileName(widgetName);
      final filePath = path.join(widgetDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        progress.fail('$widgetName already exists at $filePath');
        return false;
      }

      // Generate content based on template
      final content = isStateful
          ? _generateStatefulWidgetContent(widgetName)
          : _generateStatelessWidgetContent(widgetName);

      await file.writeAsString(content);
      progress.complete('Created $widgetName at ${path.relative(filePath)}');

      return true;
    } catch (e) {
      progress.fail('Failed to create widget: $e');
      return false;
    }
  }

  /// Creates the test file for the widget.
  Future<bool> _createTestFile({
    required String widgetName,
    required String outputDir,
    required bool isStateful,
  }) async {
    final progress = _logger.progress('Creating test for $widgetName...');

    try {
      // Ensure test directory exists
      final testDir = _findTestDirectory();
      if (testDir == null) {
        progress.fail(
            'Could not find test/ directory. Are you in a Flutter project?');
        return false;
      }

      final widgetTestDir = Directory(path.join(testDir.path, outputDir));
      if (!await widgetTestDir.exists()) {
        await widgetTestDir.create(recursive: true);
      }

      // Create the file
      final fileName = _getTestFileName(widgetName);
      final filePath = path.join(widgetTestDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        progress.fail('Test for $widgetName already exists at $filePath');
        return false;
      }

      // Generate content based on template
      final content = _generateTestContent(widgetName, outputDir, isStateful);

      await file.writeAsString(content);
      progress.complete(
          'Created test for $widgetName at ${path.relative(filePath)}');

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

  /// Gets the package name from pubspec.yaml.
  String _getPackageName() {
    try {
      final pubspecFile =
          File(path.join(Directory.current.path, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final nameMatch = RegExp(r'name:\s*([^\s]+)').firstMatch(content);
        if (nameMatch != null && nameMatch.groupCount >= 1) {
          return nameMatch.group(1)!;
        }
      }
    } catch (_) {}

    return 'your_app_package';
  }

  /// Gets the file name for the widget.
  String _getFileName(String widgetName) {
    final snakeCase = _toSnakeCase(widgetName);
    return '$snakeCase.dart';
  }

  /// Gets the file name for the test.
  String _getTestFileName(String widgetName) {
    final snakeCase = _toSnakeCase(widgetName);
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

  /// Generates content for a StatelessWidget.
  String _generateStatelessWidgetContent(String widgetName) {
    return '''
import 'package:flutter/material.dart';

/// A reusable $widgetName widget.
///
/// This widget is responsible for...
class $widgetName extends StatelessWidget {
  /// Creates a new $widgetName.
  const $widgetName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Text('$widgetName'),
    );
  }
}
''';
  }

  /// Generates content for a StatefulWidget.
  String _generateStatefulWidgetContent(String widgetName) {
    return '''
import 'package:flutter/material.dart';

/// A reusable $widgetName widget.
///
/// This widget is responsible for...
class $widgetName extends StatefulWidget {
  /// Creates a new $widgetName.
  const $widgetName({Key? key}) : super(key: key);

  @override
  _${widgetName}State createState() => _${widgetName}State();
}

class _${widgetName}State extends State<$widgetName> {
  @override
  void initState() {
    super.initState();
    // TODO: Initialize state
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Text('$widgetName'),
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

  /// Generates content for a widget test.
  String _generateTestContent(
      String widgetName, String outputDir, bool isStateful) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:${_getPackageName()}/$outputDir/${_toSnakeCase(widgetName)}.dart';

void main() {
  testWidgets('$widgetName should render correctly', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: $widgetName(),
      ),
    ));

    // Verify that the widget displays the expected text
    expect(find.text('$widgetName'), findsOneOrMore);
    
    // Add more widget-specific test assertions here
  });
}
''';
  }
}
