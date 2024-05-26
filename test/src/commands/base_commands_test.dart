import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/commands/base_commands.dart';
import 'package:flutter_bunny/src/common/template.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

class _MockTemplate extends Mock implements MasonTemplate {}

class _MockLogger extends Mock implements Logger {}

class _MockProgress extends Mock implements Progress {}

class _MockMasonGenerator extends Mock implements MasonGenerator {}

class _MockMasonBundle extends Mock implements MasonBundle {}

class _MockGeneratorHooks extends Mock implements GeneratorHooks {}

class _FakeLogger extends Fake implements Logger {}

class _FakeDirectoryGeneratorTarget extends Fake
    implements DirectoryGeneratorTarget {}

class _FakeDirectory extends Fake implements Directory {}

class _TestFlutterBunnyCommand extends FlutterBunnyCommand {
  _TestFlutterBunnyCommand({
    required this.template,
    required super.logger,
    super.generatorFromBundle,
    super.generatorFromBrick,
  });

  @override
  final MasonTemplate template;

  @override
  final String name = 'test_command';

  @override
  final String description = 'Test command';
}

void main() {
  final generatedFiles = List.filled(10, const GeneratedFile.created(path: ''));

  late List<String> progressLogs;
  late Logger logger;
  late Progress progress;

  setUpAll(() {
    registerFallbackValue(_FakeDirectoryGeneratorTarget());
    registerFallbackValue(_FakeLogger());
    registerFallbackValue(_FakeDirectory());
  });

  setUp(() {
    progressLogs = <String>[];

    logger = _MockLogger();
    progress = _MockProgress();

    when(() => progress.complete(any())).thenAnswer((_) {
      final message = _.positionalArguments.elementAt(0) as String?;
      if (message != null) progressLogs.add(message);
    });
    when(() => logger.progress(any())).thenReturn(progress);
  });

  group('FlutterBunnyCommand', () {
    late MasonTemplate template;
    late _MockMasonBundle bundle;

    setUp(() {
      bundle = _MockMasonBundle();
      when(() => bundle.name).thenReturn('test');
      when(() => bundle.description).thenReturn('Test bundle');
      when(() => bundle.version).thenReturn('0.1.0');

      template = _MockTemplate();
      when(() => template.bundle).thenReturn(bundle);
      when(() => template.onGenerateComplete(any(), any())).thenAnswer(
        (_) async {},
      );
    });

// group('can be instantiated', () {
//       test('with default options', () {
//         final command = _TestFlutterBunnyCommand(
//           template: template,
//           logger: logger,
//         );

//         expect(command.name, isNotNull);
//         expect(command.description, isNotNull);
//         expect(command.argParser.options, containsPair(
//           'output-directory',
//           isA<Option>()
//               .having((o) => o.isSingle, 'isSingle', true)
//               .having((o) => o.abbr, 'abbr', 'o')
//               .having((o) => o.defaultsTo, 'defaultsTo', '.')
//               .having((o) => o.mandatory, 'mandatory', false),
//         ));
//         expect(command.argParser.options, containsPair(
//           'description',
//           isA<Option>()
//               .having((o) => o.isSingle, 'isSingle', true)
//               .having((o) => o.abbr, 'abbr', null)
//               .having(
//                 (o) => o.defaultsTo,
//                 'defaultsTo',
//                 'A New Flutter Project Generated with Flutter Bunny Cli',
//               )
//               .having((o) => o.mandatory, 'mandatory', false),
//         ));
//         expect(command.argParser.commands, isEmpty);
//       });
//     });

    group('running command', () {
      late GeneratorHooks hooks;
      late MasonGenerator generator;

      late CommandRunner<int> runner;

      setUp(() {
        hooks = _MockGeneratorHooks();
        generator = _MockMasonGenerator();

        when(() => generator.hooks).thenReturn(hooks);
        when(
          () => hooks.preGen(
            vars: any(named: 'vars'),
            onVarsChanged: any(named: 'onVarsChanged'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => generator.generate(
            any(),
            vars: any(named: 'vars'),
            logger: any(named: 'logger'),
          ),
        ).thenAnswer((_) async {
          return generatedFiles;
        });

        final command = _TestFlutterBunnyCommand(
          template: template,
          logger: logger,
          generatorFromBundle: (_) async => throw Exception('oops'),
          generatorFromBrick: (_) async => generator,
        );

        runner = CommandRunner<int>('runner', 'Test command runner')
          ..addCommand(command);
      });

      test('parses description, output dir and project name', () async {
        final result = await runner.run([
          'test_command',
          'test_project',
          '--description',
          'test_desc',
          '--output-directory',
          'test_dir',
        ]);

        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('BunnyCli: Generating test_project'))
            .called(1);

        verify(
          () => hooks.preGen(
            vars: <String, dynamic>{
              'project_name': 'test_project',
              'description': 'test_desc',
            },
            onVarsChanged: any(named: 'onVarsChanged'),
          ),
        );
        verify(
          () => generator.generate(
            any(
              that: isA<DirectoryGeneratorTarget>().having(
                (g) => g.dir.path,
                'dir',
                'test_dir',
              ),
            ),
            vars: <String, dynamic>{
              'project_name': 'test_project',
              'description': 'test_desc',
            },
            logger: logger,
          ),
        ).called(1);
        expect(
          progressLogs,
          equals(['Generated ${generatedFiles.length} file(s)']),
        );
        verify(
          () => template.onGenerateComplete(
            logger,
            any(
              that: isA<Directory>().having(
                (d) => d.path,
                'path',
                path.join('test_dir', 'test_project'),
              ),
            ),
          ),
        ).called(1);
      });

      test('uses default values for omitted options', () async {
        final result = await runner.run([
          'test_command',
          'test_project',
        ]);

        expect(result, equals(ExitCode.success.code));
        verify(() => logger.progress('BunnyCli: Generating test_project'))
            .called(1);

        verify(
          () {
            return hooks.preGen(
              vars: <String, dynamic>{
                'project_name': 'test_project',
                'description':
                    'A New Flutter Project Generated with Flutter Bunny Cli',
              },
              onVarsChanged: any(named: 'onVarsChanged'),
            );
          },
        );

        verify(
          () => generator.generate(
            any(
              that: isA<DirectoryGeneratorTarget>().having(
                (g) => g.dir.path,
                'dir',
                '.',
              ),
            ),
            vars: <String, dynamic>{
              'project_name': 'test_project',
              'description':
                  'A New Flutter Project Generated with Flutter Bunny Cli',
            },
            logger: logger,
          ),
        ).called(1);

        verify(
          () => template.onGenerateComplete(
            logger,
            any(
              that: isA<Directory>().having(
                (d) => d.path,
                'path',
                path.join('.', 'test_project'),
              ),
            ),
          ),
        ).called(1);
      });

      group('validates project name', () {
        test(
          'throws UsageException when project-name is omitted',
          () async {
            await expectLater(
              runner.run(
                [
                  'test_command',
                  '--description="some description"',
                ],
              ),
              throwsA(
                isA<UsageException>().having(
                  (e) => e.message,
                  'message',
                  'No option specified for the project name.',
                ),
              ),
            );
          },
        );

        test(
          'throws UsageException when project-name is invalid',
          () async {
            await expectLater(
              runner.run(['test_command', 'invalid-name']),
              throwsA(
                isA<UsageException>().having(
                  (e) => e.message,
                  'message',
                  '''
"invalid-name" is not a valid package name.

See https://dart.dev/tools/pub/pubspec#name for more information.''',
                ),
              ),
            );
          },
        );
      });

      group('mason generator selection', () {
        test('uses remote brick when possible', () async {
          final command = _TestFlutterBunnyCommand(
            template: template,
            logger: logger,
            generatorFromBundle: (_) async {
              throw Exception('oops');
            },
            generatorFromBrick: (_) async => generator,
          );
          final runner = CommandRunner<int>('runner', 'Test command runner')
            ..addCommand(command);

          final result = await runner.run([
            'test_command',
            'test_project',
          ]);

          expect(result, equals(ExitCode.success.code));

          verify(
            () => generator.generate(
              any(
                that: isA<DirectoryGeneratorTarget>().having(
                  (g) => g.dir.path,
                  'dir',
                  '.',
                ),
              ),
              vars: <String, dynamic>{
                'project_name': 'test_project',
                'description':
                    'A New Flutter Project Generated with Flutter Bunny Cli',
              },
              logger: logger,
            ),
          ).called(1);
        });

        test('falls back to bundle', () async {
          final command = _TestFlutterBunnyCommand(
            template: template,
            logger: logger,
            generatorFromBundle: (_) async => generator,
          );
          final runner = CommandRunner<int>('runner', 'Test command runner')
            ..addCommand(command);

          final result = await runner.run([
            'test_command',
            'test_project',
          ]);

          expect(result, equals(ExitCode.success.code));

          verify(
            () => generator.generate(
              any(
                that: isA<DirectoryGeneratorTarget>().having(
                  (g) => g.dir.path,
                  'dir',
                  '.',
                ),
              ),
              vars: <String, dynamic>{
                'project_name': 'test_project',
                'description':
                    'A New Flutter Project Generated with Flutter Bunny Cli',
              },
              logger: logger,
            ),
          ).called(1);
        });
      });
    });
  });
}
