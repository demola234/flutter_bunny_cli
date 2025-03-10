# 📋 Summary of the Next Level Features:

- Interactive Scaffolding
- Advanced Modular System
- Code Generators (Widgets, Features, Modules)
- State Management Integration
- Custom Theming
- Plugin Support
- CI/CD Integration
- Global Configurations and Preferences

```dart
void main(List<String> arguments) async {
  final logger = Logger();
  final runner = CommandRunner<void>(
    'flutter_bunny',
    'Flutter Bunny CLI - Generate Flutter project templates with ease 🐰',
  )
    ..addCommand(CreateProjectCommand())
    ..argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show detailed output during execution.',
    );

  try {
    final argResults = runner.parse(arguments);

    if (argResults['verbose'] == true) {
      logger.info('Verbose mode enabled');
    }

    // Check if no command is provided and start SetupWizard by default
    if (argResults.command == null) {
      logger.info('No command provided. Starting interactive setup...');
      final wizard = SetupWizard(logger: logger);
      final config = await wizard.startInteractiveSetup();

      logger.info(
          '✨ Setup completed successfully! You can now use the following configuration:');
      logger.info('   Project Name: ${config.name}');
      logger.info('   Architecture: ${config.architecture}');
      logger.info('   State Management: ${config.stateManagement}');
      logger.info('   Features: ${config.features.join(", ")}');
      logger.info('   Additional Modules: ${config.modules.join(", ")}');
    } else {
      await runner.run(arguments);
    }
  } catch (e, stackTrace) {
    logger.err('An error occurred: $e');
    logger.err(stackTrace.toString());
    exit(1);
  }
}

class SetupWizard {
  final Logger _logger;

  SetupWizard({Logger? logger}) : _logger = logger ?? Logger();

  Future<ProjectConfig> startInteractiveSetup() async {
    _logger.info('Welcome to Flutter Bunny! 🐰\n');
    _logger.info('Let\'s set up your Flutter project.\n');

    final projectName = await _promptProjectName();
    final architecture = await _promptArchitecture();
    final stateManagement = await _promptStateManagement();
    final features = await _promptFeatures();
    final modules = await _promptModules();

    Confirm selections
    _displaySummary(
      projectName: projectName,
      architecture: architecture,
      stateManagement: stateManagement,
      features: features,
      modules: modules,
    );

    final confirmed = await _confirmSetup();

    if (!confirmed) {
      _logger.info('Setup cancelled. Starting over...');
      return startInteractiveSetup();
    }

    return ProjectConfig(
      name: projectName,
      architecture: architecture,
      stateManagement: stateManagement,
      features: features,
      modules: modules,
    );
  }

  Future<String> _promptProjectName() async {
    final name = _logger.prompt(
      'What is your project name?',
      defaultValue: 'my_flutter_app',
    );

    if (!_isValidProjectName(name)) {
      _logger.err('Invalid project name. Please use snake_case.');
      return _promptProjectName();
    }

    return name;
  }

  Future<String> _promptArchitecture() async {
    final architectures = [
      'Clean Architecture',
      'MVVM',
      'MVC'
    ];

    return _logger.chooseOne(
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

    return _logger.chooseOne(
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

    final selectedFeatures = _logger.chooseAny(
      'Select features to include (Space to select, Enter to confirm):',
      choices: features,
    );

    if (selectedFeatures.isEmpty) {
      _logger.warn('No features selected. Please select at least one feature.');
      return _promptFeatures(); Recursive call if no features are selected
    }

    return selectedFeatures;
  }

  Future<List<String>> _promptModules() async {
    final modules = [
      'Network Layer',
      'Local Storage',
      'Localization',
      'Push Notification',
      'Theme Manager',
    ];

    final selectedModules = _logger.chooseAny(
      'Select additional modules to include:',
      choices: modules,
    );

    if (selectedModules.isEmpty) {
      _logger.warn('No modules selected. Please select at least one module.');
      return _promptModules(); Recursive call if no modules are selected
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
    _logger.info('\n📋 Project Summary:');
    _logger.info('   Project Name: $projectName');
    _logger.info('   Architecture: $architecture');
    _logger.info('   State Management: $stateManagement');
    _logger.info('   Features: ${features.join(", ")}');
    _logger.info('   Additional Modules: ${modules.join(", ")}\n');
  }

  Future<bool> _confirmSetup() async {
    return _logger.confirm('Would you like to proceed with this setup?');
  }

  bool _isValidProjectName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }
}

class ProjectConfig {
  final String name;
  final String architecture;
  final String stateManagement;
  final List<String> features;
  final List<String> modules;

  ProjectConfig({
    required this.name,
    required this.architecture,
    required this.stateManagement,
    required this.features,
    required this.modules,
  });
}

main_command.dart
class CreateProjectCommand extends Command<void> {
  @override
  final name = 'create';

  @override
  final description = 'Create a new Flutter project interactively';

  @override
  Future<void> run() async {
    final wizard = SetupWizard();
    final config = await wizard.startInteractiveSetup();

    Generate project based on config
    await ProjectGenerator(config).generate();
  }
}
```
