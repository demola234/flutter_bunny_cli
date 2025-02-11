import 'package:args/args.dart';

const _defaultDescription =
    'This is a new Flutter project generated with Flutter Bunny Cli';

mixin ArgParserConfiguration {
  void configureArgParser(
    ArgParser argParser, {
    String? projectName,
    String? architecture,
    String? stateManagement,
    List<String>? features,
    List<String>? modules,
  }) {
    argParser
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
      ..addOption(
        'architecture',
        help: 'The architectural pattern to use for the project.',
        allowed: [
          'clean_architecture',
          'mvvm',
          'mvc',
          'feature_driven',
        ],
        defaultsTo: architecture ?? 'clean_architecture',
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
        defaultsTo: stateManagement ?? 'provider',
      )
      ..addMultiOption(
        'features',
        help: 'The features to include in the project.',
        allowed: [
          'authentication',
          'user_profile',
          'settings',
          'dashboard',
          'products',
          'shopping_cart',
        ],
        defaultsTo: features ?? ['authentication'],
      )
      ..addMultiOption(
        'modules',
        help: 'Additional modules to include in the project.',
        allowed: [
          'network_layer',
          'local_storage',
          'analytics',
          'push_notifications',
          'theme_manager',
        ],
        defaultsTo: modules ?? ['network_layer'],
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Run in interactive mode to configure the project.',
        negatable: false,
      );
  }
}
