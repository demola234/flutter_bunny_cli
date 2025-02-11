import 'package:flutter_bunny/src/common/base_command.dart';
import 'package:flutter_bunny/src/templates/bunny_generate.dart';
import 'package:flutter_bunny/src/templates/template.dart';

class CreateFlutterApp extends BaseCommand {
  CreateFlutterApp({
    required super.logger,
    super.generatorFromBundle,
    super.generatorFromBrick,
  }) {
    // argParser
    //   ..addOption(
    //     'output-directory',
    //     abbr: 'o',
    //     help: 'Output directory for the project',
    //     defaultsTo: '.',
    //   )
    //   ..addFlag(
    //     'overwrite',
    //     help: 'Overwrite existing files',
    //     defaultsTo: false,
    //   );
  }

  @override
  String get description => 'Creates a new Flutter application.';

  @override
  String get name => 'app';

  Future<String> _promptOrgName() async {
    final orgName = logger.prompt(
      'What is your organization name? (reverse domain notation)',
      defaultValue: 'com.example',
    );

    if (!_isValidOrgName(orgName)) {
      logger.err(
        'Invalid organization name. Please use reverse domain notation (e.g., com.example)',
      );
      return _promptOrgName();
    }

    return orgName;
  }

  bool _isValidOrgName(String name) {
    return RegExp(r'^[a-zA-Z][\w-]*(\.[a-zA-Z][\w-]*)+$').hasMatch(name);
  }

  Future<Map<String, bool>> _promptDependencies() async {
    final dependencies = [
      'dio',
      'shared_preferences',
      'hive',
      'get_it',
      'flutter_secure_storage',
      'firebase_core',
      'firebase_analytics',
    ];

    final selectedDeps = logger.chooseAny(
      'Select dependencies to include:',
      choices: dependencies,
    );

    return {
      for (var dep in dependencies) dep.toString(): selectedDeps.contains(dep)
    };
  }

  Future<bool> _promptFirebaseSetup() async {
    return logger.confirm(
      'Would you like to set up Firebase in your project?',
      defaultValue: false,
    );
  }

  @override
  Future<Map<String, dynamic>> getMasonTemplateVars({
    String? projectName,
    String? architecture,
    String? stateManagement,
    List<String>? features,
    List<String>? modules,
  }) async {
    final vars = await super.getMasonTemplateVars(
      projectName: projectName ?? '',
      architecture: architecture ?? '',
      stateManagement: stateManagement ?? '',
      features: features ?? [],
      modules: modules ?? [],
    );

    // final orgName = await _promptOrgName();
    final dependencies = await _promptDependencies();
    final setupFirebase = await _promptFirebaseSetup();

    return {
      ...vars,
      // 'org_name': orgName,
      'dependencies': dependencies,
      'setup_firebase': setupFirebase,
    };
  }

  @override
  MasonTemplate get template => BunnyGenerate();

//   @override
//   void _displayNextSteps(
//     String projectName,
//     String projectPath,
//     MasonTemplate template,
//   ) {
//     super._displayNextSteps(projectName, projectPath, template);

//     final vars = getMasonTemplateVars();
//     if (vars['setup_firebase'] as bool) {
//       logger.info('''

// 🔥 Firebase Setup:
//   1. Install Firebase CLI if not already installed:
//      curl -sL https://firebase.tools | bash
//   2. Run "firebase login" to authenticate
//   3. Inside your project directory, run:
//      firebase init
//   4. Select the Firebase services you want to use
//       ''');
//     }
//   }
}
