import '../common/base_command.dart';
import '../templates/bunny_generate.dart';
import '../templates/template.dart';

class CreateFlutterApp extends BaseCommand {
  CreateFlutterApp({
    required super.logger,
    super.generatorFromBundle,
    super.generatorFromBrick,
  });

  // Store the template vars for later use
  Map<String, dynamic>? _templateVars;

  @override
  String get description => 'Creates a new Flutter application.';

  @override
  String get name => 'app';

  @override
  Future<int> run() async {
    logger.info('''
🐰 Welcome to Flutter Bunny CLI! Let's create an awesome Flutter project together.
    ''');
    return super.run();
  }

  String _generateBundleIdentifier(String projectName) {
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

    final bundleIdentifier = _generateBundleIdentifier(projectName ?? '');

    // Check if push notification is selected
    final hasPushNotification = modules?.contains('Push Notification') ?? false;

    _templateVars = {
      ...vars,
      'bundle_identifier': bundleIdentifier,
      'setup_firebase': hasPushNotification,
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
    // Call the parent method to display the standard next steps
    super.displayNextSteps(projectName, projectPath, template);

    final hasPushNotification =
        _templateVars?['modules']?.contains('Push Notification') ?? false;

    if (hasPushNotification) {
      logger.info('''
🔥 Firebase Setup for Push Notifications:
  1. Install the FlutterFire CLI:
     dart pub global activate flutterfire_cli
  2. Run the following command in your project directory:
     flutterfire configure
  3. Follow the interactive setup to select your Firebase project and platforms
  4. The CLI will automatically add the necessary configuration files for Android and iOS

📚 Documentation:
  For detailed setup instructions, visit:
  https://www.flutterbunny.xyz/guide/firebase-setup
      ''');
    }

    // Add the happy coding message at the end
    logger.info('🚀 Happy coding with Flutter Bunny! 🐰');
  }
}
