import 'dart:async';

import 'package:flutter_bunny/src/cli/cli_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

// Mock classes
class MockLogger extends Mock implements Logger {}

class MockProcessResult extends Mock {
  int get exitCode =>
      super.noSuchMethod(Invocation.getter(#exitCode), returnValue: 0) as int;

  dynamic get stdout =>
      super.noSuchMethod(Invocation.getter(#stdout), returnValue: '')
          as dynamic;

  dynamic get stderr =>
      super.noSuchMethod(Invocation.getter(#stderr), returnValue: '')
          as dynamic;
}

class _FakeProcess {
  final MockProcessResult mockProcessResult;

  _FakeProcess(this.mockProcessResult);

  Future<ProcessResult> run(
    String command,
    List<String> args, {
    bool runInShell = false,
    String? workingDirectory,
  }) async {
    return Future<ProcessResult>.value(
        mockProcessResult as FutureOr<ProcessResult>?);
  }
}

void main() {
  group('CliRunner', () {
    late CliRunner cliRunner;
    late MockLogger mockLogger;
    late MockProcessResult mockProcessResult;
    late _FakeProcess fakeProcess;

    setUp(() {
      cliRunner = CliRunner();
      mockLogger = MockLogger();
      mockProcessResult = MockProcessResult();
      fakeProcess = _FakeProcess(mockProcessResult);
    });

    test('uses custom Process.run when specified', () {
      ProcessOverrides.runWithOverrides(
        () {
          final overrides = ProcessOverrides.current;
          expect(overrides!.runProcess, equals(fakeProcess.run));
        },
        runProcess: fakeProcess.run,
      );
    });

    test(
        'uses current Process.run when not specified '
        'and zone already contains a Process.run', () {
      ProcessOverrides.runWithOverrides(
        () {
          ProcessOverrides.runWithOverrides(() {
            final overrides = ProcessOverrides.current;
            expect(overrides!.runProcess, equals(fakeProcess.run));
          });
        },
        runProcess: fakeProcess.run,
      );
    });

    test(
        'uses nested Process.run when specified '
        'and zone already contains a Process.run', () {
      final rootProcess = _FakeProcess(mockProcessResult);
      ProcessOverrides.runWithOverrides(
        () {
          final nestedProcess = _FakeProcess(mockProcessResult);
          final overrides = ProcessOverrides.current;
          expect(overrides!.runProcess, equals(rootProcess.run));
          ProcessOverrides.runWithOverrides(
            () {
              final overrides = ProcessOverrides.current;
              expect(overrides!.runProcess, equals(nestedProcess.run));
            },
            runProcess: nestedProcess.run,
          );
        },
        runProcess: rootProcess.run,
      );
    });
  });
}
