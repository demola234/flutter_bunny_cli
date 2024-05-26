import 'package:flutter_bunny/src/common/template.dart';
import 'package:flutter_bunny/src/templates/bunny_template_bundle.dart';
import 'package:flutter_bunny/src/templates/post_generate_actions.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

class FlutterBunnyFlutterApp extends MasonTemplate {
  FlutterBunnyFlutterApp()
      : super(
          name: 'core',
          bundle: bunnyTemplateBundle,
          help: 'Generate a Bunny Flutter application.',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    if (await installFlutterPackages(logger, outputDir)) {
      await applyDartFixes(logger, outputDir);
    }
    _logSummary(logger, outputDir);
  }

  void _logSummary(Logger logger, Directory outputDir) {
    final relativePath = path.relative(
      outputDir.path,
      from: Directory.current.path,
    );

    final projectPath = relativePath;
    final projectPathLink =
        link(uri: Uri.parse(projectPath), message: projectPath);

    final readmePath = path.join(relativePath, 'README.md');
    final readmePathLink =
        link(uri: Uri.parse(readmePath), message: readmePath);

    final details = '''
  • To get started refer to $readmePathLink
  • Your project code is in $projectPathLink
''';

    logger
      ..info('\n')
      ..info(lightCyan.wrap(styleBold.wrap("🐰 Generating Bunny...")))
      ..info(details)
      ..info('''
        ${lightBlue.wrap(
        '''
         🐰 Flutter Bunny Application Successfully Generated🔥''',
      )}
         ''');
  }
}
