import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/commands/config_flags.dart';
import 'package:flutter_bunny/src/common/template.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

/// A method which returns a [Future<MasonGenerator>] given a [Brick].
typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

final RegExp _identifierRegExp = RegExp(r'^[a-z_][a-z0-9_]*');
final RegExp _orgNameRegExp = RegExp(r'^[a-zA-Z][\w-]*(\.[a-zA-Z][\w-]*)+$');

const _defaultDescription =
    'A New Flutter Project Generated with Flutter Bunny Cli';
const _defaultOrgName = 'com.example.flutter_bunny';
const _hostUrl = 'https://bunnycli.com';

abstract class FlutterBunnyCommand extends Command<int>
    with ArgParserConfigurator {
  FlutterBunnyCommand({
    required this.logger,
    @visibleForTesting MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting MasonGeneratorFromBrick? generatorFromBrick,
  })  : _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick {
    configureArgParser(
      argParser,
      includeOrgName: this is OrgName,
      includeHostUrl: this is HostUrl,
      includePublishable: this is Publishable,
    );
  }

  final Logger logger;
  final MasonGeneratorFromBundle _generatorFromBundle;
  final MasonGeneratorFromBrick _generatorFromBrick;

  @visibleForTesting
  ArgResults? argResultOverrides;

  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  Directory get outputDirectory {
    final directory = argResults['output-directory'] as String? ?? '.';
    return Directory(directory);
  }

  String get projectName {
    final args = argResults.rest;
    _validateProjectName(args);
    return args.first;
  }

  String get projectDescription =>
      argResults['description'] as String? ?? _defaultDescription;

  MasonTemplate get template;

  @override
  String get invocation => 'bunny_cli create $name <project-name> [arguments]';

  @override
  Future<int> run() async {
    final template = this.template;
    final generator = await _getGeneratorForMasonTemplate();
    return await runCreate(generator, template);
  }

  Future<int> runCreate(
      MasonGenerator generator, MasonTemplate template) async {
    final generateProgress =
        logger.progress('BunnyCli: Generating $projectName');
    var vars = getMasonTemplateVars();

    final target = DirectoryGeneratorTarget(outputDirectory);

    await generator.hooks.preGen(vars: vars, onVarsChanged: (v) => vars = v);
    final files = await generator.generate(target, vars: vars, logger: logger);
    generateProgress.complete('Generated ${files.length} file(s)');

    await template.onGenerateComplete(
      logger,
      Directory(path.join(target.dir.path, projectName)),
    );

    return ExitCode.success.code;
  }

  @mustCallSuper
  Map<String, dynamic> getMasonTemplateVars() {
    final vars = <String, dynamic>{
      'project_name': projectName,
      'description': projectDescription,
    };
    if (this is OrgName) vars['org_name'] = (this as OrgName).orgName;

    if (this is HostUrl) vars['host_url'] = (this as HostUrl).hostUrl;

    if (this is Publishable) {
      vars['publishable'] = (this as Publishable).publishable;
    }

    return vars;
  }

  void _validateProjectName(List<String> args) {
    logger.detail('Validating project name; args: $args');

    if (args.isEmpty) {
      usageException('No option specified for the project name.');
    }

    final name = args.first;
    if (!_isValidPackageName(name)) {
      usageException(
        '"$name" is not a valid package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
      );
    }
  }

  bool _isValidPackageName(String name) =>
      _identifierRegExp.matchAsPrefix(name)?.end == name.length;

  Future<MasonGenerator> _getGeneratorForMasonTemplate() async {
    try {
      final brick = Brick.version(
          name: template.bundle.name, version: '^${template.bundle.version}');
      logger.detail(
          'Building generator from brick: ${brick.name} ${brick.location.version}');
      return await _generatorFromBrick(brick);
    } catch (_) {
      logger.detail('Building generator from brick failed: $_');
    }
    logger.detail(
        'Building generator from bundle ${template.bundle.name} ${template.bundle.version}');
    return _generatorFromBundle(template.bundle);
  }
}

class OrgNameValidator {
  static String validateOrgName(String name, Logger logger) {
    logger.detail('Validating org name; $name');
    if (!_isValidOrgName(name)) {
      throw UsageException(
          '"$name" is not a valid org name.\n\n'
              'A valid org name has at least 2 parts separated by "."\n'
              'Each part must start with a letter and only include '
              'alphanumeric characters (A-Z, a-z, 0-9), underscores (_),',
          '');
    }
    return name;
  }

  static bool _isValidOrgName(String name) => _orgNameRegExp.hasMatch(name);
}

class HostUrlValidator {
  static String validateHostUrl(String url, Logger logger) {
    logger.detail('Validating host url; $url');
    if (!_isValidHostUrl(url)) {
      throw UsageException(
          '"$url" is not a valid host url.\n\n'
              'The host url must be $url',
          '');
    }
    return url;
  }

  static bool _isValidHostUrl(String url) => url == _hostUrl;
}

mixin OrgName on FlutterBunnyCommand {
  String get orgName {
    final orgName = argResults['org-name'] as String? ?? _defaultOrgName;
    return OrgNameValidator.validateOrgName(orgName, logger);
  }
}

mixin HostUrl on FlutterBunnyCommand {
  String get hostUrl {
    argResults['host-url'] as String? ?? _hostUrl;
    return HostUrlValidator.validateHostUrl(hostUrl, logger);
  }
}

class PublishableValidator {
  static bool isPublishable(ArgResults argResults) {
    return argResults['publishable'] as bool? ?? false;
  }
}

mixin Publishable on FlutterBunnyCommand {
  bool get publishable => PublishableValidator.isPublishable(argResults);
}
