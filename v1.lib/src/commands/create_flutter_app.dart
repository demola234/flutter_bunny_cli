import 'base_commands.dart';
import '../common/template.dart';
import '../templates/bunny_template.dart';

class CreateFlutterApp extends FlutterBunnyCommand with OrgName {
  CreateFlutterApp({
    required super.logger,
    required super.generatorFromBundle,
    required super.generatorFromBrick,
  }) {
    argParser.addOption(
      'application-id',
      help: 'The bundle identifier on iOS or application id on Android. '
          '(defaults to <org-name>.<project-name>)',
    );
  }

  @override
  String get name => 'app';

  @override
  String get description => 'Generate a Bunny Flutter application.';

  @override
  Map<String, dynamic> getMasonTemplateVars() {
    final vars = super.getMasonTemplateVars();

    final applicationId = argResults['application-id'] as String?;
    if (applicationId != null) {
      vars['application_id'] = applicationId;
    }

    return vars;
  }

  @override
  MasonTemplate get template => FlutterBunnyFlutterApp();
}
