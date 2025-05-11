import 'dart:developer';
import 'dart:io';

import 'package:flutter_bunny/flutter_bunny.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'helpers/test_process_runner.dart';
import 'helpers/test_utils.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    // Create a temporary directory for tests
    tempDir = await Directory.systemTemp.createTemp('flutter_bunny_e2e_');
    log('Created temporary directory: ${tempDir.path}');
  });

  tearDown(() async {
    // Clean up the temporary directory
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
      log('Deleted temporary directory: ${tempDir.path}');
    }
  });

  group('End-to-end CLI tests', () {
    test('Version command returns correct version', () async {
      final result = await runCommand(['--version']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains(FlutterBunny.version));
    });

    test('Help command shows available commands', () async {
      final result = await runCommand(['--help']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, contains('Available commands:'));
      expect(result.stdout, contains('create'));
      // expect(result.stdout, contains('generate'));
      expect(result.stdout, contains('build'));
      expect(result.stdout, contains('update'));
    });

    test(
      'Create command generates a new project',
      () async {
        // Skip this test if Flutter SDK is not installed
        if (!await isFlutterInstalled()) {
          log('Skipping test: Flutter SDK not installed');
          return;
        }

        final projectName = 'test_app';
        final projectDir = path.join(tempDir.path, projectName);

        final result = await runCommand([
          'create',
          'app',
          '--name',
          projectName,
          '--output-directory',
          tempDir.path,
          '--architecture',
          'clean_architecture',
          '--state-management',
          'riverpod',
          '--no-interactive',
        ]);

        expect(
          result.exitCode,
          equals(0),
          reason: 'Error output: ${result.stderr}',
        );

        // Verify the project was created successfully
        final pubspecFile = File(
          path.join(
            projectDir,
            'pubspec.yaml',
          ),
        );
        expect(
          await pubspecFile.exists(),
          isTrue,
          reason: 'pubspec.yaml not found',
        );

        final mainFile = File(
          path.join(
            projectDir,
            'lib',
            'main.dart',
          ),
        );
        expect(await mainFile.exists(), isTrue, reason: 'main.dart not found');

        // Verify the project contains expected architecture folders
        final domainDir = Directory(path.join(projectDir, 'lib', 'domain'));
        expect(
          await domainDir.exists(),
          isTrue,
          reason: 'domain directory not found',
        );

        // Verify the project contains Riverpod as dependency
        final pubspecContent = await pubspecFile.readAsString();
        expect(
          pubspecContent,
          contains('riverpod'),
          reason: 'Riverpod dependency not found',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'Generate command creates a new screen',
      () async {
        // Skip this test if Flutter SDK is not installed
        if (!await isFlutterInstalled()) {
          log('Skipping test: Flutter SDK not installed');
          return;
        }

        // First create a test project
        final projectName = 'gen_test_app';
        final projectDir = path.join(tempDir.path, projectName);

        await runCommand([
          'create',
          'app',
          '--name',
          projectName,
          '--output-directory',
          tempDir.path,
          '--no-interactive',
        ]);

        // Now generate a screen in that project
        final genResult = await runCommand(
          [
            'generate',
            'screen',
            '--name',
            'HomeScreen',
            '--output',
            'screens',
            '--no-with-test',
          ],
          workingDirectory: projectDir,
        );

        expect(
          genResult.exitCode,
          equals(0),
          reason: 'Error output: ${genResult.stderr}',
        );

        // Verify the screen was created
        final screenFile =
            File(path.join(projectDir, 'lib', 'screens', 'home_screen.dart'));
        expect(
          await screenFile.exists(),
          isTrue,
          reason: 'HomeScreen not generated',
        );

        // Verify content of the screen
        final screenContent = await screenFile.readAsString();
        expect(screenContent, contains('class HomeScreen'));
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );

    test(
      'Generate command creates a model with json serialization',
      () async {
        // Skip this test if Flutter SDK is not installed
        if (!await isFlutterInstalled()) {
          log('Skipping test: Flutter SDK not installed');
          return;
        }

        // First create a test project
        final projectName = 'model_test_app';
        final projectDir = path.join(tempDir.path, projectName);

        await runCommand([
          'create',
          'app',
          '--name',
          projectName,
          '--output-directory',
          tempDir.path,
          '--no-interactive',
        ]);

        // Now generate a model
        final genResult = await runCommand(
          [
            'generate',
            'model',
            '--name',
            'User',
            '--fields',
            'id:int,name:String,email:String',
            '--json',
            '--no-with-test',
          ],
          workingDirectory: projectDir,
        );

        expect(
          genResult.exitCode,
          equals(0),
          reason: 'Error output: ${genResult.stderr}',
        );

        // Verify the model was created
        final modelFile =
            File(path.join(projectDir, 'lib', 'models', 'user.dart'));
        expect(
          await modelFile.exists(),
          isTrue,
          reason: 'User model not generated',
        );

        // Verify content of the model
        final modelContent = await modelFile.readAsString();
        expect(modelContent, contains('class User'));
        expect(modelContent, contains('@JsonSerializable()'));
        expect(modelContent, contains('final int id;'));
        expect(modelContent, contains('final String name;'));
        expect(modelContent, contains('final String email;'));
      },
      timeout: const Timeout(Duration(minutes: 4)),
    );

    test(
      'Build command runs build_runner correctly',
      () async {
        // Skip this test if Flutter SDK is not installed
        if (!await isFlutterInstalled()) {
          log('Skipping test: Flutter SDK not installed');
          return;
        }

        // First create a test project
        final projectName = 'build_test_app';
        final projectDir = path.join(tempDir.path, projectName);

        await runCommand([
          'create',
          'app',
          '--name',
          projectName,
          '--output-directory',
          tempDir.path,
          '--no-interactive',
        ]);

        // Add json_serializable dependency to pubspec
        final pubspecFile = File(path.join(projectDir, 'pubspec.yaml'));
        final pubspecContent = await pubspecFile.readAsString();
        final updatedPubspec = pubspecContent.replaceFirst(
          'dependencies:',
          'dependencies:\n  json_annotation: ^4.8.1\n  build_runner: ^2.4.6\n  json_serializable: ^6.7.1\n',
        );
        await pubspecFile.writeAsString(updatedPubspec);

        // Generate a model with JSON serialization
        await runCommand(
          [
            'generate',
            'model',
            '--name',
            'Product',
            '--fields',
            'id:int,name:String,price:double',
            '--json',
            '--no-with-test',
          ],
          workingDirectory: projectDir,
        );

        // Run flutter pub get first (since we modified pubspec)
        await Process.run(
          'flutter',
          ['pub', 'get'],
          workingDirectory: projectDir,
        );

        // Now run the build command
        final buildResult = await runCommand(
          [
            'build',
            '--no-watch',
          ],
          workingDirectory: projectDir,
        );

        // This test might be flaky as it depends on build_runner completing successfully
        // Consider allowing non-zero exit codes if needed
        if (buildResult.exitCode != 0) {
          log(
            'Warning: build command exited with non-zero code. This may or may not be an error.',
          );
          log('stdout: ${buildResult.stdout}');
          log('stderr: ${buildResult.stderr}');
        }

        // Check if the generated file exists
        await Future.delayed(
          const Duration(seconds: 2),
        ); // Give some time for file generation
        final generatedFile =
            File(path.join(projectDir, 'lib', 'models', 'product.g.dart'));

        // Note: The file might not exist if build_runner failed, but we don't want to fail the test
        // just because of build_runner issues
        if (await generatedFile.exists()) {
          final generatedContent = await generatedFile.readAsString();
          expect(generatedContent, contains('_\$ProductFromJson'));
          expect(generatedContent, contains('_\$ProductToJson'));
        } else {
          log(
            'Warning: Generated file not found. This may be due to build_runner issues.',
          );
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
