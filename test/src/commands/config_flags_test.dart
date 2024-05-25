import 'package:args/args.dart';
import 'package:test/test.dart';

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

void main() {
  group('ArgParserConfigurator', () {
    late ArgParser argParser;
    late ArgParserConfigurator configurator;

    setUp(() {
      argParser = ArgParser();
      configurator = _ArgParserConfiguratorImpl();
    });

    test('adds default options', () {
      configurator.configureArgParser(argParser);

      expect(argParser.options.containsKey('output-directory'), isTrue);
      expect(argParser.options['output-directory']?.abbr, 'o');
      expect(argParser.options.containsKey('description'), isTrue);
      expect(argParser.options['description']?.defaultsTo, _defaultDescription);
    });

    test('adds org-name option when includeOrgName is true', () {
      configurator.configureArgParser(argParser, includeOrgName: true);

      expect(argParser.options.containsKey('org-name'), isTrue);
      expect(argParser.options['org-name']?.defaultsTo, _defaultOrgName);
      expect(argParser.options['org-name']?.aliases, contains('org'));
    });

    test('adds host-url option when includeHostUrl is true', () {
      configurator.configureArgParser(argParser, includeHostUrl: true);

      expect(argParser.options.containsKey('host-url'), isTrue);
      expect(argParser.options['host-url']?.defaultsTo, _hostUrl);
      expect(argParser.options['host-url']?.allowed, [_hostUrl]);
    });

    test('adds publishable flag when includePublishable is true', () {
      configurator.configureArgParser(argParser, includePublishable: true);

      expect(argParser.options.containsKey('publishable'), isTrue);
      expect(argParser.options['publishable']?.negatable, isFalse);
    });
  });
}

class _ArgParserConfiguratorImpl with ArgParserConfigurator {}
