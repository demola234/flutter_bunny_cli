import 'package:flutter_bunny/src/common/base_command.dart';
import 'package:flutter_bunny/src/templates/bunny_generate.dart';
import 'package:flutter_bunny/src/templates/template.dart';

class CreateFlutterApp extends BaseCommand {
  // Store the template vars for later use
  Map<String, dynamic>? _templateVars;

  CreateFlutterApp({
    required super.logger,
    super.generatorFromBundle,
    super.generatorFromBrick,
  });

  @override
  String get description => 'Creates a new Flutter application.';

  @override
  String get name => 'app';

  String _generateOrgName(String projectName) {
    // Handle various input formats (camelCase, snake_case, etc.)
    String normalized = projectName.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    );

    // Split by common delimiters (space, underscore, hyphen)
    List<String> parts = normalized.split(RegExp(r'[_\- ]+'));

    // Clean up each part and convert to lowercase
    parts = parts
        .map((part) => part.trim().toLowerCase())
        .where((part) => part.isNotEmpty)
        .toList();

    // Join all parts and remove any non-alphanumeric characters
    final appName = parts.join().replaceAll(RegExp(r'[^a-z0-9]'), '');

    return 'com.example.$appName';
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

  Future<bool> _promptFirebaseSetup(Map<String, bool> dependencies) async {
    // Only prompt for Firebase setup if any Firebase-related dependencies are selected
    final hasFirebaseDeps = dependencies.entries
        .where((entry) => entry.key.startsWith('firebase_') && entry.value)
        .isNotEmpty;

    if (!hasFirebaseDeps) {
      return false;
    }

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

    final orgName = _generateOrgName(projectName ?? '');
    final dependencies = await _promptDependencies();
    final setupFirebase = await _promptFirebaseSetup(dependencies);

    _templateVars = {
      ...vars,
      'org_name': orgName,
      'dependencies': dependencies,
      'setup_firebase': setupFirebase,
    };

    return _templateVars!;
  }

  @override
  MasonTemplate get template => BunnyGenerate();

  @override
  void displayNextSteps(
    String projectName,
    String projectPath,
    MasonTemplate template,
  ) {
    super.displayNextSteps(projectName, projectPath, template);

    final setupFirebase = _templateVars?['setup_firebase'] as bool? ?? false;
    if (setupFirebase) {
      logger.info('''
🔥 Firebase Setup:
  1. Install Firebase CLI if not already installed:
     curl -sL https://firebase.tools | bash
  2. Run "firebase login" to authenticate
  3. Inside your project directory, run:
     firebase init
  4. Select the Firebase services you want to use
      ''');
    }
  }
}
