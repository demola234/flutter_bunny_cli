import 'package:args/args.dart';

const _defaultDescription =
    'A New Flutter Project Generated with Flutter Bunny Cli';
const _defaultOrgName = 'com.example.flutter_bunny';
const _hostUrl = 'https://bunnycli.com';

mixin ArgParserConfigurator {
  void configureArgParser(
    ArgParser argParser, {
    bool includeOrgName = false,
    bool includeHostUrl = false,
    bool includePublishable = false,
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
      );

    if (includeOrgName) {
      argParser.addOption(
        'org-name',
        help: 'The organization for this new project.',
        defaultsTo: _defaultOrgName,
        aliases: ['org'],
      );
    }

    if (includeHostUrl) {
      argParser.addOption(
        'host-url',
        help: 'Set the host url for the Flutter Bunny Cli.',
        defaultsTo: _hostUrl,
        allowed: [_hostUrl],
      );
    }

    if (includePublishable) {
      argParser.addFlag(
        'publishable',
        negatable: false,
        help: 'Whether the generated project is intended to be published.',
      );
    }
  }
}
