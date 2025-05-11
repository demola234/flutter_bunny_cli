import 'package:args/args.dart';
import 'package:flutter_bunny/src/cli/cli_runner.dart';
import 'package:flutter_bunny/src/commands/build_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class MockCliRunner extends Mock implements CliRunner {}

class MockProgress extends Mock implements Progress {}

class MockArgResults extends Mock implements ArgResults {}

// Since we can't mock static methods directly, we'll use a helper class
class BuildRunnerHelper {
  static Future<bool> runBuildRunner({
    required Logger logger,
    required CliRunner cliRunner,
    String cwd = '.',
    bool deleteConflicting = true,
    bool watch = false,
  }) async {
    // We'll replace this implementation in tests
    throw UnimplementedError('This should be replaced in tests');
  }
}

void main() {
  group('BuildCommand', () {
    late MockLogger logger;
    late BuildCommand command;
    late MockArgResults argResults;

    setUp(() {
      logger = MockLogger();
      command = BuildCommand(logger: logger);
      argResults = MockArgResults();

      // Set up mock arg results
      when(() => argResults['watch']).thenReturn(false);
      when(() => argResults['delete-conflicting-outputs']).thenReturn(true);
      when(() => argResults['directory']).thenReturn('.');

      // Set up default mocks
      when(() => logger.progress(any())).thenReturn(MockProgress());
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.success(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);
    });

    test('has correct name and description', () {
      expect(command.name, equals('build'));
      expect(command.description, contains('build_runner'));
    });

    test('has correct aliases', () {
      expect(command.aliases, contains('codegen'));
    });

    test('has correct options', () {
      final argParser = command.argParser;

      expect(argParser.options, contains('watch'));
      expect(argParser.options, contains('delete-conflicting-outputs'));
      expect(argParser.options, contains('directory'));

      expect(argParser.options['watch']!.abbr, equals('w'));
      expect(
        argParser.options['delete-conflicting-outputs']!.abbr,
        equals('d'),
      );
      expect(argParser.options['directory']!.abbr, equals('C'));
    });

    // test('runBuildRunner is called with correct arguments for standard build', () async {
    //   // Override the PackageRunner.runBuildRunner method using our helper
    //   var wasCalledCorrectly = false;
    //   var originalMethod = PackageRunner.runBuildRunner;

    //   try {
    //     // Use a spy to intercept calls with our test implementation
    //     PackageRunner.runBuildRunner = ({
    //       required Logger logger,
    //       required CliRunner cliRunner,
    //       String cwd = '.',
    //       bool deleteConflicting = true,
    //       bool watch = false,
    //     }) async {
    //       // Check if arguments match expectations
    //       wasCalledCorrectly =
    //         cwd == '.' &&
    //         deleteConflicting == true &&
    //         watch == false;

    //       return true;
    //     };

    //     // Make the command use our mock ArgResults
    //     // We need to access the protected field using noSuchMethod
    //     command.noSuchMethod(
    //       Invocation.setter(
    //         #argResults,
    //         [argResults],
    //       ),
    //     );

    //     // Run the command
    //     final exitCode = await command.run();

    //     // Verify the command exited successfully and called our method correctly
    //     expect(exitCode, equals(0));
    //     expect(wasCalledCorrectly, isTrue);
    //   } finally {
    //     // Restore the original method
    //     PackageRunner.runBuildRunner = originalMethod;
    //   }
    // });

    // test('displays success message when build completes', () async {
    //   // Override the PackageRunner.runBuildRunner method
    //   var originalMethod = PackageRunner.runBuildRunner;

    //   try {
    //     // Use a spy to intercept calls with our test implementation
    //     PackageRunner.runBuildRunner = ({
    //       required Logger logger,
    //       required CliRunner cliRunner,
    //       String cwd = '.',
    //       bool deleteConflicting = true,
    //       bool watch = false,
    //     }) async {
    //       return true;
    //     };

    //     // Make the command use our mock ArgResults
    //     command.noSuchMethod(
    //       Invocation.setter(
    //         #argResults,
    //         [argResults],
    //       ),
    //     );

    //     // Run the command
    //     await command.run();

    //     // Verify success message was shown (only when not in watch mode)
    //     verify(() => logger.success(any())).called(1);
    //   } finally {
    //     // Restore the original method
    //     PackageRunner.runBuildRunner = originalMethod;
    //   }
    // });

    // test('does not display success message in watch mode', () async {
    //   // Set up watch mode
    //   when(() => argResults['watch']).thenReturn(true);

    //   // Override the PackageRunner.runBuildRunner method
    //   var originalMethod = PackageRunner.runBuildRunner;

    //   try {
    //     // Use a spy to intercept calls with our test implementation
    //     PackageRunner.runBuildRunner = ({
    //       required Logger logger,
    //       required CliRunner cliRunner,
    //       String cwd = '.',
    //       bool deleteConflicting = true,
    //       bool watch = false,
    //     }) async {
    //       return true;
    //     };

    //     // Make the command use our mock ArgResults
    //     command.noSuchMethod(
    //       Invocation.setter(
    //         #argResults,
    //         [argResults],
    //       ),
    //     );

    //     // Run the command
    //     await command.run();

    //     // Verify success message was NOT shown in watch mode
    //     verifyNever(() => logger.success(any()));
    //   } finally {
    //     // Restore the original method
    //     PackageRunner.runBuildRunner = originalMethod;
    //   }
    // });

    // test('returns error code when build fails', () async {
    //   // Override the PackageRunner.runBuildRunner method
    //   var originalMethod = PackageRunner.runBuildRunner;

    //   try {
    //     // Use a spy to intercept calls with our test implementation
    //     PackageRunner.runBuildRunner = ({
    //       required Logger logger,
    //       required CliRunner cliRunner,
    //       String cwd = '.',
    //       bool deleteConflicting = true,
    //       bool watch = false,
    //     }) async {
    //       return false;
    //     };

    //     // Make the command use our mock ArgResults
    //     command.noSuchMethod(
    //       Invocation.setter(
    //         #argResults,
    //         [argResults],
    //       ),
    //     );

    //     // Run the command
    //     final exitCode = await command.run();

    //     // Verify error code was returned
    //     expect(exitCode, equals(1)); // ExitCode.software.code
    //   } finally {
    //     // Restore the original method
    //     PackageRunner.runBuildRunner = originalMethod;
    //   }
    // });
  });
}
