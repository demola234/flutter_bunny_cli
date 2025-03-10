import 'package:args/args.dart';
import 'package:flutter_bunny/src/common/config_manager.dart';

/// Default description for new Flutter projects.
const _defaultDescription =
    'This is a new Flutter project generated with Flutter Bunny CLI';

/// Mixin for configuring argument parsers in a consistent way.
///
/// This mixin provides a standard set of arguments for Flutter Bunny commands,
/// ensuring consistency across the CLI interface.
mixin ArgParserConfiguration {
  /// Configures an argument parser with standard Flutter Bunny options.
  ///
  /// [argParser] is the parser to configure.
  /// [projectName], [architecture], [stateManagement], [features], and [modules]
  /// are optional default values for the respective options.
  void configureArgParser(
    ArgParser argParser, {
    String? projectName,
    String? architecture,
    String? stateManagement,
    List<String>? features,
    List<String>? modules,
    ConfigManager? configManager,
  }) {
    // If we have a config manager, use it to get default values
    final config = configManager;
    
    // Get defaults from config or use provided defaults
    final defaultArchitecture = config?.getValue<String>(
      'defaults.architecture',
      defaultValue: architecture ?? 'clean_architecture',
    ) ?? architecture ?? 'clean_architecture';
    
    final defaultStateManagement = config?.getValue<String>(
      'defaults.state_management',
      defaultValue: stateManagement ?? 'provider',
    ) ?? stateManagement ?? 'provider';
    
    final defaultFeatures = config?.getValue<List<dynamic>>(
      'defaults.features',
      defaultValue: features?.cast<dynamic>() ?? ['authentication'],
    )?.cast<String>() ?? features ?? ['authentication'];
    
    final defaultModules = config?.getValue<List<dynamic>>(
      'defaults.modules',
      defaultValue: modules?.cast<dynamic>() ?? ['network_layer'],
    )?.cast<String>() ?? modules ?? ['network_layer'];
    
    // Configure the argument parser with the resolved default values
    argParser
      // Project configuration options
      ..addOption(
        'output-directory',
        abbr: 'o',
        help: 'The desired output directory when creating a new project.',
      )
      ..addOption(
        'description',
        help: 'The description for this new project.',
        aliases: ['desc'],
        defaultsTo: _defaultDescription,
      )
      ..addOption(
        'name',
        help: 'The name of the Flutter project (in snake_case).',
        defaultsTo: projectName ?? 'my_flutter_app',
      )
      
      // Architecture and structure options
      ..addOption(
        'architecture',
        help: 'The architectural pattern to use for the project.',
        allowed: [
          'clean_architecture',
          'mvvm',
          'mvc',
          'feature_driven',
        ],
        defaultsTo: defaultArchitecture,
      )
      ..addOption(
        'state-management',
        help: 'The state management solution to use.',
        allowed: [
          'provider',
          'riverpod',
          'bloc',
          'getx',
          'mobx',
          'redux',
        ],
        defaultsTo: defaultStateManagement,
      )
      
      // Feature and module options
      ..addMultiOption(
        'features',
        help: 'The features to include in the project.',
        allowed: [
          'authentication',
          'user_profile',
          'settings',
          'dashboard'
        ],
        defaultsTo: defaultFeatures,
      )
      ..addMultiOption(
        'modules',
        help: 'Additional modules to include in the project.',
        allowed: [
          'network_layer',
          'localization',
          'push_notifications',
          'theme_manager',
        ],
        defaultsTo: defaultModules,
      )
      
      // Mode options
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Run in interactive mode to configure the project.',
        negatable: true,
        defaultsTo: config?.getValue<bool>(
          'generation.interactive',
          defaultValue: true,
        ) ?? true,
      )
      ..addFlag(
        'verbose',
        help: 'Show verbose output for debugging.',
        negatable: false,
      );
  }
}