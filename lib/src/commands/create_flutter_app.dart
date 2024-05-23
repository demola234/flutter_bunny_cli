import 'package:flutter_bunny/src/commands/base.dart';
import 'package:flutter_bunny/src/common/template.dart';
import 'package:flutter_bunny/src/templates/bunny_template.dart';

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
  String get name => 'flutter_app';

  @override
  String get description => 'Generate a Bunny Flutter application.';

  @override
  Map<String, dynamic> getTemplateVars() {
    final vars = super.getTemplateVars();

    final applicationId = argResults['application-id'] as String?;
    if (applicationId != null) {
      vars['application_id'] = applicationId;
    }

    return vars;
  }

  @override
  Template get template => FlutterBunnyFlutterApp();
}
