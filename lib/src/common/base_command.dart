import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/common/config_flags.dart';
import 'package:flutter_bunny/src/templates/template.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);
typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

abstract class BaseCommand extends Command<int> with ArgParserConfiguration {
  final Logger logger;
  final MasonGeneratorFromBundle _generatorFromBundle;
  final MasonGeneratorFromBrick _generatorFromBrick;

  BaseCommand({
    required this.logger,
    @visibleForTesting MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting MasonGeneratorFromBrick? generatorFromBrick,
  })  : _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick {
    configureArgParser(argParser);
  }

  @visibleForTesting
  ArgResults? argResultOverrides;

  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  Directory get outputDirectory {
    final directory = argResults['output-directory'] as String? ?? '.';
    return Directory(directory);
  }

  MasonTemplate get template;

  @override
  String get invocation => 'flutter_bunny create $name';

  @override
  Future<int> run() async {
    final projectName = await _promptProjectName();
    final architecture = await _promptArchitecture();
    final stateManagement = await _promptStateManagement();
    final features = await _promptFeatures();
    final modules = await _promptModules();

    _displaySummary(
      projectName: projectName,
      architecture: architecture,
      stateManagement: stateManagement,
      features: features,
      modules: modules,
    );

    if (!await _confirmSetup()) {
      logger.info('Setup cancelled. Please try again.');
      return ExitCode.success.code;
    }

    final template = this.template;
    final generator = await _getGeneratorForMasonTemplate();
    return await runCreate(
      generator,
      template,
      projectName: projectName,
      architecture: architecture,
      stateManagement: stateManagement,
      features: features,
      modules: modules,
    );
  }

  Future<int> runCreate(
    MasonGenerator generator,
    MasonTemplate template, {
    required String projectName,
    required String architecture,
    required String stateManagement,
    required List<String> features,
    required List<String> modules,
  }) async {
    final generateProgress = logger.progress('Creating $projectName...');

    var vars = await getMasonTemplateVars(
      projectName: projectName,
      architecture: architecture,
      stateManagement: stateManagement,
      features: features,
      modules: modules,
    );

    final target = DirectoryGeneratorTarget(outputDirectory);

    await generator.hooks.preGen(vars: vars, onVarsChanged: (v) => vars = v);
    final files = await generator.generate(target, vars: vars, logger: logger);

    generateProgress.complete('Project created successfully! 🎉');
    generateProgress.complete('Generated ${files.length} file(s)');

    displayNextSteps(
      projectName,
      target.dir.path.camelCase,
      template,
    );

    await template.onGenerateComplete(
      logger,
      Directory(path.join(target.dir.path, projectName)),
    );

    return ExitCode.success.code;
  }

  @mustCallSuper
  Future<Map<String, dynamic>> getMasonTemplateVars({
    required String projectName,
    required String architecture,
    required String stateManagement,
    required List<String> features,
    required List<String> modules,
  }) async {
    return {
      'project_name': projectName,
      'description': 'A New Flutter Project Generated with Flutter Bunny CLI',
      'architecture': architecture,
      'state_management': stateManagement,
      'features': features,
      'modules': modules,
    };
  }

  Future<String> _promptProjectName() async {
    final name = logger.prompt(
      'What is your project name?',
      defaultValue: 'my_flutter_app',
    );

    if (!_isValidProjectName(name)) {
      logger.err('Invalid project name. Please use snake_case.');
      return _promptProjectName();
    }

    return name;
  }

  Future<String> _promptArchitecture() async {
    final architectures = [
      'Clean Architecture',
      'MVVM',
      'MVC',
    ];

    return logger.chooseOne(
      'Select your preferred architecture:',
      choices: architectures,
      defaultValue: architectures.first,
    );
  }

  Future<String> _promptStateManagement() async {
    final stateManagements = [
      'Provider',
      'Riverpod',
      'Bloc',
      'GetX',
      'MobX',
      'Redux',
    ];

    return logger.chooseOne(
      'Select your preferred state management solution:',
      choices: stateManagements,
      defaultValue: stateManagements.first,
    );
  }

  Future<List<String>> _promptFeatures() async {
    final features = [
      'Authentication',
      'User Profile',
      'Settings',
      'Dashboard',
    ];

    final selectedFeatures = logger.chooseAny(
      'Select features to include (Space to select, Enter to confirm):',
      choices: features,
    );

    if (selectedFeatures.isEmpty) {
      logger.warn('No features selected. Please select at least one feature.');
      return _promptFeatures();
    }

    return selectedFeatures;
  }

  Future<List<String>> _promptModules() async {
    final modules = [
      'Network Layer',
      'Local Storage',
      'Analytics',
      'Push Notifications',
      'Theme Manager',
    ];

    final selectedModules = logger.chooseAny(
      'Select additional modules to include:',
      choices: modules,
    );

    if (selectedModules.isEmpty) {
      logger.warn('No modules selected. Please select at least one module.');
      return _promptModules();
    }

    return selectedModules;
  }

  void _displaySummary({
    required String projectName,
    required String architecture,
    required String stateManagement,
    required List<String> features,
    required List<String> modules,
  }) {
    logger.info('\n📋 Project Summary:');
    logger.info('   Project Name: $projectName');
    logger.info('   Architecture: $architecture');
    logger.info('   State Management: $stateManagement');
    logger.info('   Features: ${features.join(", ")}');
    logger.info('   Additional Modules: ${modules.join(", ")}\n');
  }

  Future<bool> _confirmSetup() async {
    return logger.confirm('Would you like to proceed with this setup?');
  }

  bool _isValidProjectName(String name) {
    if (name.isEmpty) return false;

    // Check against identifier regular expression
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) return false;

    // Check for Dart keywords
    final keywords = {
      'do',
      'if',
      'in',
      'for',
      'new',
      'try',
      'var',
      'case',
      'else',
      'enum',
      'null',
      'this',
      'true',
      'void',
      'with',
      'break',
      'catch',
      'class',
      'false',
      'final',
      'super',
      'while',
      'async',
      'await',
      'const',
      'throw',
      'yield',
      'assert',
      'double',
      'import',
      'native',
      'return',
      'switch',
      'typedef',
      'default',
      'dynamic',
      'extends',
      'factory',
      'library',
      'operator',
      'rethrow',
      'static',
      'export',
      'external',
      'abstract',
      'continue',
      'deferred',
      'implements',
      'interface',
      'covariant',
    };

    if (keywords.contains(name)) return false;

    // Additional validation rules
    if (name.startsWith('_')) return false;
    if (name.contains('__')) return false;
    if (name.endsWith('_')) return false;

    return true;
  }

  @mustCallSuper
  void displayNextSteps(
    String projectName,
    String projectPath,
    MasonTemplate template,
  ) {
    logger.info('''
    
🎯 Next steps:
  1. cd $projectName
  2. Review the generated project structure
  3. Run "flutter run" to start the application

📁 Your ${template.name} has been created at: $projectPath

💡 Tips:
  • Check the README.md for project documentation
  • Review pubspec.yaml for installed dependencies
  • Start coding in lib/main.dart
    ''');
  }

  Future<MasonGenerator> _getGeneratorForMasonTemplate() async {
    try {
      final brick = Brick.version(
        name: template.bundle.name,
        version: '^${template.bundle.version}',
      );
      logger.detail(
        'Building generator from brick: ${brick.name} ${brick.location.version}',
      );
      return await _generatorFromBrick(brick);
    } catch (e) {
      logger.detail('Building generator from brick failed: $e');
    }
    logger.detail(
      'Building generator from bundle ${template.bundle.name} ${template.bundle.version}',
    );
    return _generatorFromBundle(template.bundle);
  }
}
