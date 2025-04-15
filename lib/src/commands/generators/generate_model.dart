import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// Command to generate a new data model in a Flutter application.
class GenerateModelCommand extends Command<int> {
  /// Creates a new GenerateModelCommand.
  ///
  /// [logger] is used for console output.
  GenerateModelCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Name of the model to generate',
        mandatory: true,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory relative to lib/',
        defaultsTo: 'models',
      )
      ..addMultiOption(
        'fields',
        abbr: 'f',
        help: 'Fields in format name:type (e.g. id:int,name:String)',
        defaultsTo: [],
      )
      ..addFlag(
        'json',
        help: 'Add JSON serialization/deserialization',
        defaultsTo: true,
      )
      ..addFlag(
        'equatable',
        help: 'Make model extend Equatable',
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
  String get description => 'Generate a new data model';

  @override
  String get name => 'model';

  @override
  Future<int> run() async {
    final modelName = argResults?['name'] as String;
    final outputDir = argResults?['output'] as String;
    final fieldsInput = argResults?['fields'] as List<String>;
    final useJson = argResults?['json'] as bool;
    final useEquatable = argResults?['equatable'] as bool;
    final withTest = argResults?['with-test'] as bool;

    // Parse fields
    final fields = _parseFields(fieldsInput);

    // Validate model name
    if (!_isValidName(modelName)) {
      _logger.err('Invalid model name. Please use PascalCase (e.g. User).');
      return ExitCode.usage.code;
    }

    // Create model file
    final result = await _createModelFile(
      modelName: modelName,
      outputDir: outputDir,
      fields: fields,
      useJson: useJson,
      useEquatable: useEquatable,
    );

    if (!result) {
      return ExitCode.software.code;
    }

    // Create test file if requested
    if (withTest) {
      await _createTestFile(
        modelName: modelName,
        outputDir: outputDir,
        fields: fields,
        useJson: useJson,
      );
    }

    _logger.info('');
    _logger.info(
      '${lightGreen.wrap('✓')} Successfully generated $modelName model!',
    );

    if (useJson) {
      _logger.info('''
🔸 Don't forget to run build_runner to generate JSON serialization code:
  flutter pub run build_runner build --delete-conflicting-outputs
''');
    }

    return ExitCode.success.code;
  }

  /// Parses field definitions from command line input.
  Map<String, String> _parseFields(List<String> fieldsInput) {
    final fields = <String, String>{};

    if (fieldsInput.isEmpty) {
      // Add some default fields if none specified
      fields['id'] = 'int';
      fields['name'] = 'String';
      fields['createdAt'] = 'DateTime';
      return fields;
    }

    for (final field in fieldsInput) {
      final parts = field.split(':');
      if (parts.length != 2) {
        _logger.warn(
          'Invalid field format: "$field". Expected "name:type". Skipping.',
        );
        continue;
      }

      final name = parts[0].trim();
      final type = parts[1].trim();

      if (name.isEmpty || type.isEmpty) {
        _logger.warn('Field name or type is empty in "$field". Skipping.');
        continue;
      }

      fields[name] = type;
    }

    return fields;
  }

  /// Validates the model name format.
  bool _isValidName(String name) {
    // Check if name is PascalCase
    return RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(name);
  }

  /// Creates the model file.
  Future<bool> _createModelFile({
    required String modelName,
    required String outputDir,
    required Map<String, String> fields,
    required bool useJson,
    required bool useEquatable,
  }) async {
    final progress = _logger.progress('Creating $modelName model...');

    try {
      // Ensure output directory exists
      final libDir = _findLibDirectory();
      if (libDir == null) {
        progress.fail(
          'Could not find lib/ directory. Are you in a Flutter project?',
        );
        return false;
      }

      final modelDir = Directory(path.join(libDir.path, outputDir));
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      // Create the file
      final fileName = _getFileName(modelName);
      final filePath = path.join(modelDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        progress.fail('$modelName model already exists at $filePath');
        return false;
      }

      // Generate content based on template
      final content = _generateModelContent(
        modelName: modelName,
        fields: fields,
        useJson: useJson,
        useEquatable: useEquatable,
      );

      await file.writeAsString(content);
      progress
          .complete('Created $modelName model at ${path.relative(filePath)}');

      return true;
    } catch (e) {
      progress.fail('Failed to create model: $e');
      return false;
    }
  }

  /// Creates the test file for the model.
  Future<bool> _createTestFile({
    required String modelName,
    required String outputDir,
    required Map<String, String> fields,
    required bool useJson,
  }) async {
    final progress = _logger.progress('Creating test for $modelName model...');

    try {
      // Ensure test directory exists
      final testDir = _findTestDirectory();
      if (testDir == null) {
        progress.fail(
          'Could not find test/ directory. Are you in a Flutter project?',
        );
        return false;
      }

      final modelTestDir = Directory(path.join(testDir.path, outputDir));
      if (!await modelTestDir.exists()) {
        await modelTestDir.create(recursive: true);
      }

      // Create the file
      final fileName = _getTestFileName(modelName);
      final filePath = path.join(modelTestDir.path, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        progress.fail('Test for $modelName model already exists at $filePath');
        return false;
      }

      // Generate content based on template
      final content = _generateTestContent(
        modelName: modelName,
        outputDir: outputDir,
        fields: fields,
        useJson: useJson,
      );

      await file.writeAsString(content);
      progress.complete(
        'Created test for $modelName model at ${path.relative(filePath)}',
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

  /// Gets the file name for the model.
  String _getFileName(String modelName) {
    final snakeCase = _toSnakeCase(modelName);
    return '$snakeCase.dart';
  }

  /// Gets the file name for the test.
  String _getTestFileName(String modelName) {
    final snakeCase = _toSnakeCase(modelName);
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

  /// Generates content for a model class.
  /// Generates content for a model class.
  String _generateModelContent({
    required String modelName,
    required Map<String, String> fields,
    required bool useJson,
    required bool useEquatable,
  }) {
    final buffer = StringBuffer();

    // Add imports
    buffer.writeln("import 'package:flutter/foundation.dart';");

    if (useJson) {
      buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    }

    if (useEquatable) {
      buffer.writeln("import 'package:equatable/equatable.dart';");
    }

    if (useJson) {
      buffer.writeln();
      buffer.writeln("part '${_toSnakeCase(modelName)}.g.dart';");
    }

    buffer.writeln();

    // Add class annotation for JSON serialization
    if (useJson) {
      buffer.writeln('@JsonSerializable()');
    }

    // Begin class definition
    buffer.write('class $modelName');

    if (useEquatable) {
      buffer.write(' extends Equatable');
    }

    buffer.writeln(' {');

    // Add fields
    for (final entry in fields.entries) {
      buffer.writeln('  final ${entry.value} ${entry.key};');
    }

    buffer.writeln();

    // Add constructor
    buffer.writeln('  const $modelName({');
    for (final entry in fields.entries) {
      buffer.writeln('    required this.${entry.key},');
    }
    buffer.writeln('  });');

    // Add fromJson factory if needed
    if (useJson) {
      buffer.writeln();
      buffer.writeln('  /// Creates a [$modelName] from JSON map.');
      buffer.writeln(
        '  factory $modelName.fromJson(Map<String, dynamic> json) => ',
      );
      buffer.writeln('      _\$${modelName}FromJson(json);');

      buffer.writeln();
      buffer.writeln('  /// Converts this [$modelName] into a JSON map.');
      buffer.writeln(
        '  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);',
      );
    }

    // Add copyWith method
    buffer.writeln();
    buffer.writeln(
      '  /// Creates a copy of this [$modelName] with specified attributes replaced with new values.',
    );
    buffer.writeln('  $modelName copyWith({');
    for (final entry in fields.entries) {
      buffer.writeln('    ${entry.value}? ${entry.key},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $modelName(');
    for (final entry in fields.entries) {
      buffer.writeln('      ${entry.key}: ${entry.key} ?? this.${entry.key},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    // Add Equatable properties
    if (useEquatable) {
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  List<Object?> get props => [');
      for (final entry in fields.entries) {
        buffer.writeln('    ${entry.key},');
      }
      buffer.writeln('  ];');
    } else {
      // Add equals and hashCode
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  bool operator ==(Object other) {');
      buffer.writeln('    if (identical(this, other)) return true;');
      buffer.writeln('    return other is $modelName &&');

      final fieldsList = fields.keys.toList();
      for (var i = 0; i < fieldsList.length; i++) {
        final field = fieldsList[i];
        buffer.write('        other.$field == $field');
        if (i < fieldsList.length - 1) {
          buffer.writeln(' &&');
        } else {
          buffer.writeln(';');
        }
      }

      buffer.writeln('  }');

      // FIXED: Improved hashCode implementation
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  int get hashCode =>');

      // Use the same fieldsList from above instead of declaring a new one
      String hashCodeExpression = '';
      for (var i = 0; i < fieldsList.length; i++) {
        final field = fieldsList[i];
        if (i == 0) {
          hashCodeExpression += '$field.hashCode';
        } else {
          hashCodeExpression += ' ^ $field.hashCode';
        }
      }
      buffer.writeln('      $hashCodeExpression;');
    }

    // Add toString method
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  String toString() {');
    buffer.write('    return \'$modelName{');

    final fieldKeys = fields.keys.toList();
    for (var i = 0; i < fieldKeys.length; i++) {
      final field = fieldKeys[i];
      buffer.write('$field: \$$field');
      if (i < fieldKeys.length - 1) {
        buffer.write(', ');
      }
    }

    buffer.writeln('}\';');
    buffer.writeln('  }');

    // End class
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generates content for a model test.
  String _generateTestContent({
    required String modelName,
    required String outputDir,
    required Map<String, String> fields,
    required bool useJson,
  }) {
    final buffer = StringBuffer();

    // Add imports
    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln(
      "import 'package:${_getPackageName()}/$outputDir/${_toSnakeCase(modelName)}.dart';",
    );
    buffer.writeln();

    buffer.writeln('void main() {');
    buffer.writeln('  group(\'$modelName\', () {');

    // Test instance creation
    buffer.writeln('    test(\'can be instantiated\', () {');
    buffer.writeln('      final model = $modelName(');

    // Add field values for constructor
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldType = entry.value;

      // Generate an appropriate test value based on the type
      final testValue = _getTestValueForType(fieldType, fieldName);
      buffer.writeln('        $fieldName: $testValue,');
    }

    buffer.writeln('      );');
    buffer.writeln();

    // Test field values
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldType = entry.value;
      final testValue = _getTestValueForType(fieldType, fieldName);

      buffer.writeln('      expect(model.$fieldName, $testValue);');
    }

    buffer.writeln('    });');
    buffer.writeln();

    // Test copyWith
    buffer.writeln('    test(\'copyWith works correctly\', () {');
    buffer.writeln('      final model = $modelName(');

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldType = entry.value;
      final testValue = _getTestValueForType(fieldType, fieldName);
      buffer.writeln('        $fieldName: $testValue,');
    }

    buffer.writeln('      );');
    buffer.writeln();

    // Choose first field for copyWith test
    final firstField = fields.entries.first;
    final newTestValue = _getAlternateTestValueForType(
      firstField.value,
      firstField.key,
    );

    buffer.writeln('      final updated = model.copyWith(');
    buffer.writeln('        ${firstField.key}: $newTestValue,');
    buffer.writeln('      );');
    buffer.writeln();
    buffer.writeln('      expect(updated.${firstField.key}, $newTestValue);');

    // Test that other fields remain unchanged
    for (final entry in fields.entries.skip(1)) {
      buffer.writeln('      expect(updated.${entry.key}, model.${entry.key});');
    }

    buffer.writeln('    });');

    // Test JSON serialization if enabled
    if (useJson) {
      buffer.writeln();
      buffer.writeln('    test(\'can be serialized and deserialized\', () {');
      buffer.writeln('      final model = $modelName(');

      for (final entry in fields.entries) {
        final testValue = _getTestValueForType(entry.value, entry.key);
        buffer.writeln('        ${entry.key}: $testValue,');
      }

      buffer.writeln('      );');
      buffer.writeln();
      buffer.writeln('      final json = model.toJson();');
      buffer.writeln('      final fromJson = $modelName.fromJson(json);');
      buffer.writeln();
      buffer.writeln('      expect(fromJson, equals(model));');
      buffer.writeln('    });');
    }

    buffer.writeln('  });');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Gets a test value for a given type.
  String _getTestValueForType(String type, String fieldName) {
    switch (type) {
      case 'int':
        return '42';
      case 'double':
        return '42.0';
      case 'String':
        return '\'Test $fieldName\'';
      case 'bool':
        return 'true';
      case 'DateTime':
        return 'DateTime(2023, 1, 1)';
      case 'List<String>':
        return '[\'Item 1\', \'Item 2\']';
      case 'Map<String, dynamic>':
        return '{\'key\': \'value\'}';
      default:
        if (type.startsWith('List<')) {
          return '[]';
        } else if (type.startsWith('Map<')) {
          return '{}';
        }
        return 'null';
    }
  }

  /// Gets an alternate test value for a given type (for testing copyWith).
  String _getAlternateTestValueForType(String type, String fieldName) {
    switch (type) {
      case 'int':
        return '100';
      case 'double':
        return '100.0';
      case 'String':
        return '\'Updated $fieldName\'';
      case 'bool':
        return 'false';
      case 'DateTime':
        return 'DateTime(2023, 12, 31)';
      case 'List<String>':
        return '[\'Updated Item\']';
      case 'Map<String, dynamic>':
        return '{\'updated\': \'value\'}';
      default:
        if (type.startsWith('List<')) {
          return '[]';
        } else if (type.startsWith('Map<')) {
          return '{}';
        }
        return 'null';
    }
  }
}
