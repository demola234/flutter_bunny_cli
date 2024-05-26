import 'package:flutter_bunny/src/commands/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockPubUpdater extends Mock implements PubUpdater {}

const expectedUsage = [
  'A CLI tool that helps to generate Flutter Code\n'
      '\n'
      'Usage: flutter_bunny <command> [arguments]\n'
      '\n'
      'Global options:\n'
      '-h, --help            Print this usage information.\n'
      '    --version         Print the current version.\n'
      '    --[no-]verbose    Enable verbose logging, including all shell commands executed.\n'
      '\n'
      'Available commands:\n'
      '  create     Create a new Flutter application.\n'
      '\n'
      'Run "flutter_bunny help <command>" for more information about a command.'
];

const packageVersion = '1.0.0';

void main() {
  group('FlutterBunnyCommandRunner', () {
    late Logger mockLogger;
    late PubUpdater mockPubUpdater;
    late FlutterBunnyCommandRunner commandRunner;

    setUp(() {
      mockLogger = _MockLogger();
      mockPubUpdater = _MockPubUpdater();
      commandRunner = FlutterBunnyCommandRunner(
        logger: mockLogger,
        pubUpdater: mockPubUpdater,
        environment: {'CI': 'true'},
      );

      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.detail(any())).thenReturn(null);
      when(() => mockPubUpdater.getLatestVersion(any()))
          .thenAnswer((_) async => packageVersion);
    });

    group('run', () {
      // test('shows update message when newer version exists', () async {
      //   when(() => mockPubUpdater.getLatestVersion(any())).thenAnswer((_) async => '1.1.0');

      //   final result = await commandRunner.run(['--version']);
      //   expect(result, equals(ExitCode.success.code));
      //   verify(() => mockLogger.info('1.1.0')).called(1);
      // });

      test('handles pub update errors gracefully', () async {
        when(() => mockPubUpdater.getLatestVersion(any()))
            .thenThrow(Exception('oops'));

        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verifyNever(() => mockLogger.info('1.1.0'));
      });
    });
  });
}
