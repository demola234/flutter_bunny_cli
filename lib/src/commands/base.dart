import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/common/template.dart';
import 'package:mason/mason.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

/// A method which returns a [Future<MasonGenerator>] given a [Brick].
typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

final RegExp _identifierRegExp = RegExp('[a-z_][a-z0-9_]*');
final RegExp _orgNameRegExp = RegExp(r'^[a-zA-Z][\w-]*(\.[a-zA-Z][\w-]*)+$');

const _defaultDescription =
    'A New Flutter Project Generated with Flutter Bunny Cli';
const _defaultOrgName = 'com.example.flutter_bunny';

abstract class FlutterBunnyCommand extends Command<int> {
  FlutterBunnyCommand({
    required this.logger,
    @visibleForTesting required MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting required MasonGeneratorFromBrick? generatorFromBrick,
  })  : _generatorFromBundle = generatorFromBundle ?? MasonGenerator.fromBundle,
        _generatorFromBrick = generatorFromBrick ?? MasonGenerator.fromBrick {
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
      );

    // Add the templates arg if the command has multiple templates.
    if (this is MultiTemplates) {
      final multiTemplates = this as MultiTemplates;
      final defaultTemplateName = multiTemplates.defaultTemplateName;
      final templates = multiTemplates.templates;

      argParser.addOption(
        'template',
        abbr: 't',
        help: 'The template used to generate this new project.',
        defaultsTo: defaultTemplateName,
        allowed: templates.map((element) => element.name).toList(),
        allowedHelp: templates.fold<Map<String, String>>(
          {},
          (previousValue, element) => {
            ...previousValue,
            element.name: element.help,
          },
        ),
      );
    }

    if (this is OrgName) {
      argParser.addOption(
        'org-name',
        help: 'The organization for this new project.',
        defaultsTo: _defaultOrgName,
        aliases: ['org'],
      );
    }

    if (this is Publishable) {
      argParser.addFlag(
        'publishable',
        negatable: false,
        help: 'Whether the generated project is intended to be published.',
      );
    }
  }

  /// The logger user to notify the user of the command's progress.
  final Logger logger;
  final MasonGeneratorFromBundle _generatorFromBundle;
  final MasonGeneratorFromBrick _generatorFromBrick;

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  /// Overridden to support line wrapping when printing usage.
  ///
  ///   @override
  @override
  ArgResults get argResults => argResultOverrides ?? super.argResults!;

  /// Gets the output [Directory].
  Directory get outputDirectory {
    final directory = argResults['output-directory'] as String? ?? '.';
    return Directory(directory);
  }

  /// Gets the project name.
  String get projectName {
    final args = argResults.rest;
    _validateProjectName(args);
    return args.first;
  }

  /// Gets the description for the project.
  String get projectDescription => argResults['description'] as String? ?? '';

  /// Should return the desired template to be created during a command run.
  ///
  /// For sub commands with multiple templates, see [MultiTemplates].
  Template get template;

  @override
  String get invocation => 'very_good create $name <project-name> [arguments]';

  bool _isValidPackageName(String name) {
    final match = _identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  }

  void _validateProjectName(List<String> args) {
    logger.detail('Validating project name; args: $args');

    if (args.isEmpty) {
      usageException('No option specified for the project name.');
    }

    if (args.length > 1) {
      usageException('Multiple project names specified.');
    }

    final name = args.first;
    final isValidProjectName = _isValidPackageName(name);
    if (!isValidProjectName) {
      usageException(
        '"$name" is not a valid package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
      );
    }
  }

  Future<MasonGenerator> _getGeneratorForTemplate() async {
    try {
      final brick = Brick.version(
        name: template.bundle.name,
        version: '^${template.bundle.version}',
      );
      logger.detail(
        '''Building generator from brick: ${brick.name} ${brick.location.version}''',
      );
      return await _generatorFromBrick(brick);
    } catch (_) {
      logger.detail('Building generator from brick failed: $_');
    }
    logger.detail(
      '''Building generator from bundle ${template.bundle.name} ${template.bundle.version}''',
    );
    return _generatorFromBundle(template.bundle);
  }

  @override
  Future<int> run() async {
    final template = this.template;
    final generator = await _getGeneratorForTemplate();
    final result = await runCreate(generator, template);

    return result;
  }

  /// Invoked by [run] to create the project, contains the logic for using
  /// the template vars obtained by [getTemplateVars] to generate the project
  /// from the [generator] and [template].
  Future<int> runCreate(MasonGenerator generator, Template template) async {
    var vars = getTemplateVars();

    final generateProgress = logger.progress('Bootstrapping');
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

  /// Responsible for returns the template parameters to be passed to the
  /// template brick.
  ///
  /// Override if the create sub command requires additional template
  /// parameters.
  ///
  /// For subcommands that mix with [OrgName], it includes 'org_name'.
  /// For subcommands that mix with [Publishable], it includes 'publishable'.
  @mustCallSuper
  Map<String, dynamic> getTemplateVars() {
    final projectName = this.projectName;
    final projectDescription = this.projectDescription;

    return <String, dynamic>{
      'project_name': projectName,
      'description': projectDescription,
      if (this is OrgName) 'org_name': (this as OrgName).orgName,
      if (this is Publishable) 'publishable': (this as Publishable).publishable,
    };
  }
}

/// Takes care of parsing from [argResults] and validating the org name.
mixin OrgName on FlutterBunnyCommand {
  /// Gets the organization name.
  String get orgName {
    final orgName = argResults['org-name'] as String? ?? _defaultOrgName;
    _validateOrgName(orgName);
    return orgName;
  }

  void _validateOrgName(String name) {
    logger.detail('Validating org name; $name');
    final isValidOrgName = _isValidOrgName(name);
    if (!isValidOrgName) {
      usageException(
        '"$name" is not a valid org name.\n\n'
        'A valid org name has at least 2 parts separated by "."\n'
        'Each part must start with a letter and only include '
        'alphanumeric characters (A-Z, a-z, 0-9), underscores (_), '
        'and hyphens (-)\n'
        '(ex. very.good.org)',
      );
    }
  }

  bool _isValidOrgName(String name) {
    return _orgNameRegExp.hasMatch(name);
  }
}

mixin MultiTemplates on FlutterBunnyCommand {
  /// Gets the desired template to be created during a command run when the
  /// template argument is not provided.
  ///
  /// Defaults to the first template in [templates].
  String get defaultTemplateName => templates.first.name;

  /// Gets all the templates to be created during a command run.
  List<Template> get templates;

  @nonVirtual
  @override
  Template get template {
    final templateName =
        argResults['template'] as String? ?? defaultTemplateName;

    return templates.firstWhere(
      (element) => element.name == templateName,
    );
  }
}

/// Mixin for [CreateSubCommand] subclasses that receives the publishable
/// flag.
///
/// Takes care of parsing it from [argResults] and pass it
/// to the brick generator.
mixin Publishable on FlutterBunnyCommand {
  /// Gets the publishable flag.
  bool get publishable => argResults['publishable'] as bool? ?? false;
}
