import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

import 'bunny_template_bundle.dart';
import 'post_gen.dart';
import 'template.dart';

/// A template generator for Flutter Bunny applications.
/// Handles project scaffolding, dependency installation, and post-generation tasks.
class BunnyGenerate extends MasonTemplate {
  /// Creates a new Flutter Bunny application generator.
  BunnyGenerate()
      : super(
          name: 'core',
          bundle: bunnyCliTemplateBundle,
          help:
              'Generate a Bunny Flutter application with best practices and common features.',
        );

  /// Tracked files that should be generated
  static const _requiredFiles = {
    'pubspec.yaml',
    'lib/main.dart',
    'README.md',
    'analysis_options.yaml',
  };

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    try {
      // Validate template generation
      if (!await _validateGeneration(logger, outputDir)) {
        throw Exception('Template generation validation failed');
      }

      // Install packages with progress tracking
      final packagesProgress =
          logger.progress('Installing Flutter packages...');
      try {
        if (!await installFlutterPackages(logger, outputDir)) {
          packagesProgress.fail('Failed to install Flutter packages');
          return;
        }
        packagesProgress.complete('Flutter packages installed successfully');
      } catch (e) {
        packagesProgress.fail('Error installing Flutter packages: $e');
        return;
      }

      // Apply Dart fixes with progress tracking
      final fixesProgress = logger.progress('Applying Dart fixes...');
      try {
        await applyDartFixes(logger, outputDir);
        fixesProgress.complete('Dart fixes applied successfully');
      } catch (e) {
        fixesProgress.fail('Error applying Dart fixes: $e');
        return;
      }

      // Add .gitignore if not present
      await _ensureGitignore(outputDir);

      // Format Dart code
      await _formatDartCode(logger, outputDir);

      // Log generation summary
      _logSummary(logger, outputDir);
    } catch (e, stackTrace) {
      logger.err('Error during project generation');
      logger.detail('$e\n$stackTrace');
      return;
    }
  }

  /// Validates that all required files were generated correctly
  Future<bool> _validateGeneration(Logger logger, Directory outputDir) async {
    final validationProgress =
        logger.progress('Validating project structure...');

    try {
      for (final requiredFile in _requiredFiles) {
        final file = File(path.join(outputDir.path, requiredFile));
        if (!await file.exists()) {
          validationProgress.fail(
            'Missing required file: $requiredFile',
          );
          return false;
        }
      }

      validationProgress.complete('Project structure validated successfully');
      return true;
    } catch (e) {
      validationProgress.fail('Error validating project structure: $e');
      return false;
    }
  }

  /// Ensures a .gitignore file exists with common Flutter ignores
  Future<void> _ensureGitignore(Directory outputDir) async {
    final gitignorePath = path.join(outputDir.path, '.gitignore');
    final gitignoreFile = File(gitignorePath);

    if (!await gitignoreFile.exists()) {
      await gitignoreFile.writeAsString('''
# Flutter/Dart specific
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
coverage/

# Android specific
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java

# iOS specific
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# IDE specific
.idea/
.vscode/
*.iml
*.ipr
*.iws
''');
    }
  }

  /// Formats all Dart files in the project
  Future<void> _formatDartCode(Logger logger, Directory outputDir) async {
    final formatProgress = logger.progress('Formatting Dart code...');

    try {
      final result = await Process.run(
        'dart',
        ['format', '.'],
        workingDirectory: outputDir.path,
      );

      if (result.exitCode != 0) {
        formatProgress.fail('Failed to format Dart code: ${result.stderr}');
        return;
      }

      formatProgress.complete('Dart code formatted successfully');
    } catch (e) {
      formatProgress.fail('Error formatting Dart code: $e');
    }
  }

  void _logSummary(Logger logger, Directory outputDir) {
    final relativePath = path.relative(
      outputDir.path,
      from: Directory.current.path,
    );

    final projectPath = relativePath;

    final readmePath = path.join(relativePath, 'README.md');
    final readmePathLink = link(
      uri: Uri.parse(readmePath),
      message: readmePath,
    );

    final nextSteps = '''
🎯 Next steps:
  1. Navigate to your project: cd $projectPath
  2. Review the $readmePathLink for setup instructions
  3. Run 'flutter pub get' to ensure dependencies are up to date
  4. Start the app with 'flutter run'

📁 Project structure:
  • lib/               - Your application code
  • test/             - Unit and widget tests
  • assets/           - Images, fonts, and other resources
  • pubspec.yaml      - Project configuration
  
🔧 Need help? Check out:
  • https://flutter.dev/docs
  • https://github.com/demola234/flutter_bunny_cli/issues
  • https://flutterbunny.xyz
''';

    logger
      ..info('\n')
      ..info(
        lightCyan.wrap(
          styleBold.wrap('🐰 Flutter Bunny Application Generated Successfully'),
        ),
      )
      ..info(nextSteps)
      ..info(
        lightBlue.wrap(
          '🚀 Happy coding with Flutter Bunny! 🐰',
        ),
      );
  }
}
