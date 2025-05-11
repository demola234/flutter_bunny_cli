import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

import '../../common/generator/equatable_generator.dart';
import '../../common/generator/freezed_generator.dart';
import '../../common/generator/json_serializable_model.dart';
import '../../common/generator/manual_generator.dart';
import '../../common/json_utils.dart';
import '../../common/string_utils.dart';

/// Command to generate model classes with different serialization options.
class GenerateModelCommand extends Command<int> {
  GenerateModelCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Name of the model class',
      )
      ..addOption(
        'directory',
        abbr: 'd',
        help: 'Directory to create the model in',
        defaultsTo: 'lib/models',
      )
      ..addOption(
        'serializer',
        abbr: 's',
        help: 'JSON serialization method to use',
        allowed: ['freezed', 'json_serializable', 'manual', 'equatable'],
        defaultsTo: 'json_serializable',
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Use interactive mode to configure model',
        defaultsTo: true,
      )
      ..addOption(
        'json',
        help: 'JSON sample to generate model from',
      );
  }

  /// Logger for console output.
  final Logger _logger;

  @override
  String get description => 'Generate model classes with serialization options';

  @override
  String get name => 'model';

  @override
  List<String> get aliases => ['m'];

  @override
  String get summary => 'Creates model classes with JSON serialization support';

  @override
  Future<int> run() async {
    final args = argResults!;
    final interactive = args['interactive'] as bool;

    // Model name
    String? modelName = args['name'] as String?;
    if (modelName == null || modelName.isEmpty) {
      if (interactive) {
        modelName = _logger.prompt('Enter model name (e.g., User):');
      } else {
        _logger.err('Model name is required');
        return ExitCode.usage.code;
      }
    }

    // Convert to PascalCase
    modelName = StringUtils.toPascalCase(modelName);

    // Directory
    String directory = args['directory'] as String;

    // Serialization method
    String serializationMethod = args['serializer'] as String;
    if (interactive) {
      final serializerChoices = [
        'freezed',
        'json_serializable',
        'manual',
        'equatable',
      ];
      final serializerDescriptions = [
        'Freezed - Code generation for immutable classes with unions/pattern-matching',
        'json_serializable - Simple JSON serialization',
        'Manual - Custom toJson/fromJson methods',
        'Equatable - Simple classes with value equality',
      ];

      _logger.info('Select JSON serialization method:');
      for (var i = 0; i < serializerChoices.length; i++) {
        _logger.info('${i + 1}. ${serializerDescriptions[i]}');
      }

      final choice = _logger.prompt(
        'Enter your choice (1-${serializerChoices.length}):',
        defaultValue: '2',
      );

      try {
        final index = int.parse(choice) - 1;
        if (index >= 0 && index < serializerChoices.length) {
          serializationMethod = serializerChoices[index];
        }
      } catch (_) {
        // Fallback to default if invalid input
      }
    }

    // JSON sample
    String? jsonSample = args['json'] as String?;
    Map<String, dynamic>? jsonMap;

    if (interactive && (jsonSample == null || jsonSample.isEmpty)) {
      final useJson = _logger.confirm(
        'Do you want to provide a JSON sample to generate the model?',
      );

      if (useJson) {
        // Check if a file was provided
        final useFile =
            _logger.confirm('Do you want to load JSON from a file?');

        if (useFile) {
          final filePath = _logger.prompt('Enter file path:');
          try {
            final file = File(filePath);
            if (await file.exists()) {
              jsonSample = await file.readAsString();
            } else {
              _logger.err('File not found: $filePath');
              return ExitCode.ioError.code;
            }
          } catch (e) {
            _logger.err('Error reading file: $e');
            return ExitCode.ioError.code;
          }
        } else {
          _logger
              .info('Enter/paste JSON sample (press Enter twice when done):');
          final lines = <String>[];
          String? line;

          while ((line = stdin.readLineSync()) != null && line!.isNotEmpty) {
            lines.add(line);
          }

          if (lines.isNotEmpty) {
            jsonSample = lines.join('\n');
          }
        }
      }
    }

    if (jsonSample != null && jsonSample.isNotEmpty) {
      try {
        jsonMap = json.decode(jsonSample) as Map<String, dynamic>;
        _logger.info(
          'Successfully parsed JSON with ${jsonMap.length} top-level keys.',
        );

        // If there's a complex nested structure, ask if user wants to generate multiple files
        final nestedStructure = JsonUtils.identifyNestedStructure(jsonMap);
        if (nestedStructure.isNotEmpty && interactive) {
          _logger.info(
            '\nDetected complex nested structure with these potential models:',
          );
          for (final entry in nestedStructure.entries) {
            _logger.info('- ${entry.key} (${entry.value})');
          }

          final generateMultiple = _logger.confirm(
            'Would you like to generate separate model files for these nested objects?',
          );

          if (generateMultiple) {
            return await _generateMultipleModels(
              mainModelName: modelName,
              directory: directory,
              serializationMethod: serializationMethod,
              jsonMap: jsonMap,
            );
          }
        }
      } catch (e) {
        _logger.err('Invalid JSON format: $e');
        if (interactive) {
          if (!_logger.confirm('Continue without JSON sample?')) {
            return ExitCode.usage.code;
          }
        } else {
          return ExitCode.usage.code;
        }
      }
    }

    // Generate single model file
    final result = await _generateSingleModel(
      modelName: modelName,
      directory: directory,
      serializationMethod: serializationMethod,
      jsonMap: jsonMap,
    );

    return result ? ExitCode.success.code : ExitCode.software.code;
  }

  Future<bool> _generateSingleModel({
    required String modelName,
    required String directory,
    required String serializationMethod,
    Map<String, dynamic>? jsonMap,
  }) async {
    final progress = _logger.progress('Generating $modelName model');

    try {
      // Create directory if it doesn't exist
      final dir = Directory(directory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Generate file name (snake_case)
      final fileName = StringUtils.toSnakeCase(modelName);
      final filePath = path.join(directory, '$fileName.dart');

      // Generate model content
      final modelContent = _generateModelClass(
        modelName: modelName,
        serializationMethod: serializationMethod,
        jsonMap: jsonMap,
        fileName: fileName,
      );

      // Write to file
      final file = File(filePath);
      await file.writeAsString(modelContent);

      progress.complete('Generated $modelName model at $filePath');

      // Suggest dependency additions if needed
      _suggestDependencies(serializationMethod);

      return true;
    } catch (e) {
      progress.fail('Failed to generate model: $e');
      return false;
    }
  }

  Future<int> _generateMultipleModels({
    required String mainModelName,
    required String directory,
    required String serializationMethod,
    required Map<String, dynamic> jsonMap,
  }) async {
    final progress =
        _logger.progress('Generating $mainModelName and related models');

    try {
      // Create directory if it doesn't exist
      final dir = Directory(directory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Extract nested models
      final nestedModels = JsonUtils.extractNestedModels(jsonMap);

      // Generate main model file
      final fileName = StringUtils.toSnakeCase(mainModelName);
      final filePath = path.join(directory, '$fileName.dart');

      // Create imports for nested models
      String imports = '';
      if (nestedModels.isNotEmpty) {
        for (final nestedModelName in nestedModels.keys) {
          final nestedFileName = StringUtils.toSnakeCase(nestedModelName);
          imports += 'import \'$nestedFileName.dart\';\n';
        }
        imports += '\n';
      }

      // Generate main model content with imports
      String modelContent = _getFileHeader(
        serializationMethod: serializationMethod,
        fileName: fileName,
        additionalImports: imports,
      );

      // Add model class
      modelContent += _generateModelClass(
        modelName: mainModelName,
        serializationMethod: serializationMethod,
        jsonMap: jsonMap,
        fileName: fileName,
        skipHeader: true,
      );

      // Write main model to file
      final file = File(filePath);
      await file.writeAsString(modelContent);

      // Generate nested model files
      for (final entry in nestedModels.entries) {
        final nestedClassName = entry.key;
        final nestedJsonMap = entry.value;
        final nestedFileName = StringUtils.toSnakeCase(nestedClassName);
        final nestedFilePath = path.join(directory, '$nestedFileName.dart');

        // Generate nested model header with standard imports
        String nestedModelContent = _getFileHeader(
          serializationMethod: serializationMethod,
          fileName: nestedFileName,
        );

        // Generate nested model class
        nestedModelContent += _generateModelClass(
          modelName: nestedClassName,
          serializationMethod: serializationMethod,
          jsonMap: nestedJsonMap,
          fileName: nestedFileName,
          skipHeader: true,
        );

        // Write nested model to file
        final nestedFile = File(nestedFilePath);
        await nestedFile.writeAsString(nestedModelContent);

        _logger.detail('Generated $nestedClassName model at $nestedFilePath');
      }

      progress.complete(
        'Generated $mainModelName model and ${nestedModels.length} related models at $directory',
      );

      // Suggest dependency additions if needed
      _suggestDependencies(serializationMethod);

      return ExitCode.success.code;
    } catch (e) {
      progress.fail('Failed to generate models: $e');
      return ExitCode.software.code;
    }
  }

  String _getFileHeader({
    required String serializationMethod,
    required String fileName,
    String additionalImports = '',
  }) {
    switch (serializationMethod) {
      case 'freezed':
        return '// ignore_for_file: invalid_annotation_target\n\nimport \'package:freezed_annotation/freezed_annotation.dart\';\n$additionalImports\npart \'$fileName.freezed.dart\';\npart \'$fileName.g.dart\';\n\n';
      case 'json_serializable':
        return 'import \'package:json_annotation/json_annotation.dart\';\n$additionalImports\npart \'$fileName.g.dart\';\n\n';
      case 'equatable':
        return 'import \'package:equatable/equatable.dart\';\n$additionalImports\n';
      default:
        return additionalImports;
    }
  }

  String _generateModelClass({
    required String modelName,
    required String serializationMethod,
    Map<String, dynamic>? jsonMap,
    required String fileName,
    bool skipHeader = false,
  }) {
    final fields = JsonUtils.getFieldsFromJson(jsonMap);

    switch (serializationMethod) {
      case 'freezed':
        return FreezedGenerator.generate(
          modelName: modelName,
          fields: fields,
          skipHeader: skipHeader,
        );
      case 'json_serializable':
        return JsonSerializableGenerator.generate(
          modelName: modelName,
          fields: fields,
          skipHeader: skipHeader,
        );
      case 'equatable':
        return EquatableGenerator.generate(
          modelName: modelName,
          fields: fields,
          skipHeader: skipHeader,
        );
      default:
        return ManualGenerator.generate(
          modelName: modelName,
          fields: fields,
          skipHeader: skipHeader,
        );
    }
  }

  void _suggestDependencies(String serializationMethod) {
    switch (serializationMethod) {
      case 'freezed':
        _logger.info(
          '\nℹ️  Don\'t forget to add these dependencies to your pubspec.yaml:',
        );
        _logger.info('''
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  build_runner: ^2.4.6
  freezed: ^2.4.5
  json_serializable: ^6.7.1''');
        _logger.info(
          '\nRun the following command to generate the required files:',
        );
        _logger.info(
          'flutter pub run build_runner build --delete-conflicting-outputs',
        );
        break;
      case 'json_serializable':
        _logger.info(
          '\nℹ️  Don\'t forget to add these dependencies to your pubspec.yaml:',
        );
        _logger.info('''
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.6
  json_serializable: ^6.7.1''');
        _logger.info(
          '\nRun the following command to generate the required files:',
        );
        _logger.info(
          'flutter pub run build_runner build --delete-conflicting-outputs',
        );
        break;
      case 'equatable':
        _logger.info(
          '\nℹ️  Don\'t forget to add this dependency to your pubspec.yaml:',
        );
        _logger.info('''
dependencies:
  equatable: ^2.0.5''');
        break;
      default:
        // No additional dependencies needed for manual serialization
        break;
    }
  }
}
