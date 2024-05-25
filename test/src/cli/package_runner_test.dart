import 'dart:io';

import 'package:flutter_bunny/src/cli/cli_runner.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// Mock classes
class MockCliRunner extends Mock implements CliRunner {}

class MockLogger extends Mock implements Logger {}

class MockFile extends Mock implements File {}

class MockDirectory extends Mock implements Directory {}

class MockProgress extends Mock implements Progress {}

void main() {
  final successProcessResult = ProcessResult(
    42,
    ExitCode.success.code,
    '',
    '',
  );

  final softwareErrorProcessResult = ProcessResult(
    42,
    ExitCode.software.code,
    '',
    'Some error',
  );

  late MockCliRunner mockCliRunner;
  late MockLogger mockLogger;
  late MockFile mockFile;
  late MockDirectory mockDirectory;
  late Progress mockProgress;

  setUp(() {
    mockCliRunner = MockCliRunner();
    mockLogger = MockLogger();
    mockFile = MockFile();
    mockDirectory = MockDirectory();
    mockProgress = MockProgress();

    when(() => mockLogger.progress(any())).thenReturn(mockProgress);
  });

  group('PackageRunner', () {
    group('.isFlutterInstalled', () {
      test('returns true when flutter is installed', () async {
        when(() => mockCliRunner.runCommand('flutter', ['--version'],
            log: mockLogger)).thenAnswer((_) async => successProcessResult);

        final result = await PackageRunner.isFlutterInstalled(
            logger: mockLogger, cliRunner: mockCliRunner);

        expect(result, isTrue);
      });

      test('returns false when flutter is not installed', () async {
        when(() => mockCliRunner.runCommand('flutter', ['--version'],
            log: mockLogger)).thenThrow(Exception());

        final result = await PackageRunner.isFlutterInstalled(
            logger: mockLogger, cliRunner: mockCliRunner);

        expect(result, isFalse);
      });
    });

    group('.isDartInstalled', () {
      test('returns true when dart is installed', () async {
        when(() => mockCliRunner.runCommand('dart', ['--version'],
            log: mockLogger)).thenAnswer((_) async => successProcessResult);

        final result = await PackageRunner.isDartInstalled(
            logger: mockLogger, cliRunner: mockCliRunner);

        expect(result, isTrue);
      });

      test('returns false when dart is not installed', () async {
        when(() => mockCliRunner.runCommand('dart', ['--version'],
            log: mockLogger)).thenThrow(Exception());

        final result = await PackageRunner.isDartInstalled(
            logger: mockLogger, cliRunner: mockCliRunner);

        expect(result, isFalse);
      });
    });

    group('.installDependencies', () {
      test('runs "flutter pub get" successfully', () async {
        when(() => mockCliRunner.runCommand('flutter', ['pub', 'get'],
            dir: '.',
            log: mockLogger)).thenAnswer((_) async => successProcessResult);

        final result = await PackageRunner.installDependencies(
            logger: mockLogger, cliRunner: mockCliRunner);

        expect(result, isTrue);
        verify(() => mockProgress.complete()).called(1);
      });
    });

    group('.applyFixes', () {
      test('applies fixes to a single directory', () async {
        when(() => mockFile.existsSync()).thenReturn(true);
        when(() => mockCliRunner.runCommand('dart', ['fix', '--apply'],
            dir: '.',
            log: mockLogger)).thenAnswer((_) async => successProcessResult);

        await PackageRunner.applyFixes(
            logger: mockLogger,
            cliRunner: mockCliRunner,
            cwd: '.',
            recursive: false);

        verify(() => mockCliRunner.runCommand('dart', ['fix', '--apply'],
            dir: '.', log: mockLogger)).called(1);
      });

      test('applies fixes recursively', () async {
        final tempDir = Directory.systemTemp.createTempSync();
        addTearDown(() => tempDir.deleteSync(recursive: true));
        final nestedDir = Directory(p.join(tempDir.path, 'nested'))
          ..createSync();
        File(p.join(nestedDir.path, 'pubspec.yaml'))
            .writeAsStringSync('name: test\n');

        when(() => mockDirectory.listSync(recursive: true)).thenReturn([
          File(p.join(nestedDir.path, 'pubspec.yaml')),
        ]);
        when(() => mockDirectory.listSync(recursive: true)).thenReturn([
          File(p.join(nestedDir.path, 'pubspec.yaml')),
        ]);
        when(() => mockFile.existsSync()).thenReturn(true);
        when(() => mockCliRunner.runCommand('dart', ['fix', '--apply'],
            dir: nestedDir.path,
            log: mockLogger)).thenAnswer((_) async => successProcessResult);

        await PackageRunner.applyFixes(
            logger: mockLogger,
            cliRunner: mockCliRunner,
            cwd: tempDir.path,
            recursive: true);

        verify(() => mockCliRunner.runCommand('dart', ['fix', '--apply'],
            dir: nestedDir.path, log: mockLogger)).called(1);
      });
    });
  });
}
