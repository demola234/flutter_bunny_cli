import 'dart:io';

import 'package:flutter_bunny/src/commands/command_runner.dart';
import 'package:flutter_bunny/src/common/package_info.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class MockPubUpdater extends Mock implements PubUpdater {}

class MockProgress extends Mock implements Progress {}

class MockDirectory extends Mock implements Directory {}

class MockFile extends Mock implements File {}

class MockStdout extends Mock implements Stdout {}

const expectedUsage = '''
A CLI tool that helps to generate Flutter Code

Usage: flutter_bunny: <command> [arguments]

Global options:
-h, --help            Print this usage information.
    --version         Print the current version.
    --[no-]verbose    Noisy logging, including all shell commands executed.

Available commands:
  completion                   Handles shell completion (should never be called manually)
  help                         Display help information for flutter_bunny:.
  install-completion-files     Manually installs completion files for the current shell.
  uninstall-completion-files   Manually uninstalls completion files for the current shell.

Run "flutter_bunny: help <command>" for more information about a command.''';

const latestVersion = '0.0.0';

final updatePrompt = '''
${lightBlue.wrap('update available')} ${lightBlue.wrap(cliVersion)}  \u2192 ${lightCyan.wrap(latestVersion)}
${lightBlue.wrap('flutter_bunny update')} to update the newest version
''';

void main() {
  group('FlutterBunnyCommandRunner', () {
    late MockLogger mockLogger;
    late MockPubUpdater mockPubUpdater;
    late FlutterBunnyCommandRunner commandRunner;

    setUp(() {
      mockLogger = MockLogger();
      mockPubUpdater = MockPubUpdater();
      commandRunner = FlutterBunnyCommandRunner(
        logger: mockLogger,
        pubUpdater: mockPubUpdater,
        environment: {'CI': 'true'},
      );
    });

    test('can be instantiated without optional parameters', () {
      expect(FlutterBunnyCommandRunner.new, returnsNormally);
    });

    group('run', () {
      test('prints version when --version flag is passed', () async {
        when(() => mockPubUpdater.getLatestVersion(any()))
            .thenAnswer((_) async => cliVersion);
        final result = await commandRunner.run(['--version']);
        verify(() => mockLogger.info(cliVersion)).called(1);
        expect(result, ExitCode.success.code);
      });

      test('sets logger level to verbose when --verbose flag is passed',
          () async {
        await commandRunner.run(['--verbose']);
        verify(() => mockLogger.level = Level.verbose).called(1);
      });


      test('handles FormatException', () async {
        const exception = FormatException('oops!');
        var isFirstInvocation = true;
        when(() => mockLogger.info(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => mockLogger.err(exception.message)).called(1);
        verify(() => mockLogger.info(commandRunner.usage)).called(1);
      });

      test('handles FormatException', () async {
        const exception = FormatException('oops!');
        var isFirstInvocation = true;
        when(() => mockLogger.info(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => mockLogger.err(exception.message)).called(1);
        verify(() => mockLogger.info(commandRunner.usage)).called(1);
      });


      test('handles pub update errors gracefully', () async {
        when(() => mockPubUpdater.getLatestVersion(any()))
            .thenThrow(Exception('oops'));
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.success.code));
        verifyNever(() => mockLogger.info(updatePrompt));
      });

      test('handles FormatException', () async {
        const exception = FormatException('oops!');
        when(() => mockLogger.info(any())).thenThrow(exception);
        final result = await commandRunner.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => mockLogger.err(exception.message)).called(1);
        verify(() => mockLogger.info(commandRunner.usage)).called(1);
      });

      test('handles no command', () async {
        final result = await commandRunner.run([]);
        verify(() => mockLogger.info(expectedUsage)).called(1);
        expect(result, equals(ExitCode.success.code));
      });

      test('handles completion command', () async {
        final result = await commandRunner.run(['completion']);
        verifyNever(() => mockLogger.info(any()));
        verifyNever(() => mockLogger.err(any()));
        verifyNever(() => mockLogger.warn(any()));
        verifyNever(() => mockLogger.write(any()));
        verifyNever(() => mockLogger.success(any()));
        verifyNever(() => mockLogger.detail(any()));

        expect(result, equals(ExitCode.success.code));
      });

      group('--help', () {
        test('outputs usage', () async {
          final result = await commandRunner.run(['--help']);
          verify(() => mockLogger.info(expectedUsage)).called(1);
          expect(result, equals(ExitCode.success.code));

          final resultAbbr = await commandRunner.run(['-h']);
          verify(() => mockLogger.info(expectedUsage)).called(1);
          expect(resultAbbr, equals(ExitCode.success.code));
        });
      });

      group('--version', () {
        test('outputs current version', () async {
          final result = await commandRunner.run(['--version']);
          expect(result, equals(ExitCode.success.code));
          verify(() => mockLogger.info(cliVersion)).called(1);
        });
      });

      group('--verbose', () {
        test('enables verbose logging', () async {
          final result = await commandRunner.run(['--verbose']);
          expect(result, equals(ExitCode.success.code));

          verify(() => mockLogger.detail('Argument information:')).called(1);
          verify(() => mockLogger.detail('  Top level options:')).called(1);
          verify(() => mockLogger.detail('  - verbose: true')).called(1);
          verifyNever(() => mockLogger.detail('    Command options:'));
        });

        test('enables verbose logging for sub commands', () async {
          final result = await commandRunner.run(['--verbose', 'help']);
          expect(result, equals(ExitCode.success.code));

          verify(() => mockLogger.detail('Argument information:')).called(1);
          verify(() => mockLogger.detail('  Top level options:')).called(1);
          verify(() => mockLogger.detail('  - verbose: true')).called(1);
          verify(() => mockLogger.detail('  Command: help')).called(1);
        });
      });
    });
  });
}
