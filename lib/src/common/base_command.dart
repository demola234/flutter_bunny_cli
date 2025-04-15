import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

import '../templates/template.dart';
import '../templates/template_manager.dart';
import 'config_flags.dart';
import 'config_manager.dart';

/// Type definition for creating a Mason generator from a bundle.
typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

/// Type definition for creating a Mason generator from a brick.
typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

/// Base class for all Flutter Bunny commands.
///
/// Provides shared functionality for project creation, template management,
/// and user interaction.
abstract class BaseCommand extends Command<int> with ArgParserConfiguration {
  /// Creates a new base command.
  ///
  /// [logger] is used for console output.
  /// [generatorFromBundle] and [generatorFromBrick] are used for testing.
  BaseCommand({
    required this.logger,
    @visibleForTesting MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting MasonGeneratorFromBrick? generatorFromBrick,
    ConfigManager? configManager,
  })  : _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick,
        _templateManager = TemplateManager(
          logger: logger,
          configManager: configManager ?? ConfigManager(logger: logger),
        ) {
    configureArgParser(argParser);

    // Add template selection option
    argParser.addOption(
      'template',
      abbr: 't',
      help: 'Template to use for generation',
    );
  }

  /// Logger for console output.
  final Logger logger;

  /// Template manager for handling templates.
  final TemplateManager _templateManager;

  final MasonGeneratorFromBundle _generatorFromBundle;
  final MasonGeneratorFromBrick _generatorFromBrick;

  /// Allows overriding arg results for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  /// Gets the output directory for the command.
  Directory get outputDirectory {
    final directory = argResults['output-directory'] as String? ?? '.';
    return Directory(directory);
  }

  /// The template to use for generation.
  MasonTemplate get template;

  @override
  String get invocation => 'flutter_bunny create $name';

  @override
  Future<int> run() async {
    // Interactive project setup flow
    final projectName = await _promptProjectName();
    final architecture = await _promptArchitecture();
    final stateManagement = await _promptStateManagement();
    final features = await _promptFeatures();
    final modules = await _promptModules();

    // Display summary and confirm
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

    // Generate the project
    final template = this.template;
    final generator = await _getGeneratorForTemplate();

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

  /// Executes the project creation with the specified parameters.
  ///
  /// [generator] is the Mason generator to use.
  /// [template] is the template to generate.
  /// [projectName] is the name of the project.
  /// [architecture] is the architecture to use.
  /// [stateManagement] is the state management solution to use.
  /// [features] are the features to include.
  /// [modules] are the modules to include.
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

    // Run pre-generation hooks
    await generator.hooks.preGen(vars: vars, onVarsChanged: (v) => vars = v);

    // Generate the files
    final files = await generator.generate(target, vars: vars, logger: logger);

    generateProgress.complete('Project created successfully! 🎉');
    generateProgress.complete('Generated ${files.length} file(s)');

    // Display next steps
    displayNextSteps(
      projectName,
      path.basename(target.dir.path),
      template,
    );

    // Run post-generation hooks
    await template.onGenerateComplete(
      logger,
      Directory(path.join(target.dir.path, projectName)),
    );

    return ExitCode.success.code;
  }

  /// Gets the variables for the Mason template.
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

  /// Prompts the user for a project name.
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

  /// Prompts the user for an architecture.
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

  /// Prompts the user for a state management solution.
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

  /// Prompts the user for features to include.
  Future<List<String>> _promptFeatures() async {
    // Save cursor position
    stdout.write('\x1B[s');

    final features = [
      'Authentication',
      'User Profile',
      'Settings',
      'Dashboard',
    ];

    // Run your prompt
    final selectedFeatures = logger.chooseAny(
      'Select features to include (Space to select, Enter to confirm):',
      choices: features,
    );

    // Restore cursor position and clear below
    stdout.write('\x1B[u\x1B[J');

    if (selectedFeatures.isEmpty) {
      logger.warn('No features selected. Please select at least one feature.');
      return _promptFeatures();
    }

    return selectedFeatures;
  }

  /// Prompts the user for modules to include.
  Future<List<String>> _promptModules() async {
    final modules = [
      'Network Layer',
      'Localization',
      'Push Notification',
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

  /// Displays a summary of the project configuration.
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

  /// Confirms the setup with the user.
  Future<bool> _confirmSetup() async {
    return logger.confirm('Would you like to proceed with this setup?');
  }

  /// Validates a project name.
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

  /// Displays next steps after project creation.
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

  /// Gets a Mason generator for the specified template.
  Future<MasonGenerator> _getGeneratorForTemplate() async {
    final templateName = argResults['template'] as String? ?? template.name;

    try {
      // Try to get the template from the template manager
      final selectedTemplate = await _templateManager.getTemplate(templateName);

      // Check if it's a custom brick template
      if (selectedTemplate is CustomBrickTemplate) {
        return await selectedTemplate.getGenerator();
      }

      // Otherwise, use the regular method
      try {
        final brick = Brick.version(
          name: selectedTemplate.bundle.name,
          version: '^${selectedTemplate.bundle.version}',
        );
        logger.detail(
          'Building generator from brick: ${brick.name} ${brick.location.version}',
        );
        return await _generatorFromBrick(brick);
      } catch (e) {
        logger.detail('Building generator from brick failed: $e');
      }
      logger.detail(
        'Building generator from bundle ${selectedTemplate.bundle.name} ${selectedTemplate.bundle.version}',
      );
      return _generatorFromBundle(selectedTemplate.bundle);
    } catch (e) {
      // If we couldn't get the template, fall back to the default one
      logger.detail('Using default template: ${template.name}');

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
}
