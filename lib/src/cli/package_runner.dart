part of 'cli_runner.dart';

/// Manages package-related operations for Flutter and Dart projects.
///
/// This class handles tasks like dependency installation, Dart fixes,
/// and environment validation.
class PackageRunner {
  /// The CLI runner to use for command execution.
  final CliRunner cliRunner;

  /// Creates a new PackageRunner.
  PackageRunner({required this.cliRunner});

  /// Checks if Flutter is installed and available.
  static Future<bool> isFlutterInstalled({
    required Logger logger,
    required CliRunner cliRunner,
  }) async {
    try {
      await cliRunner.runCommand('flutter', ['--version'], log: logger);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Checks if Dart is installed and available.
  static Future<bool> isDartInstalled({
    required Logger logger,
    required CliRunner cliRunner,
  }) async {
    try {
      await cliRunner.runCommand('dart', ['--version'], log: logger);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Installs dependencies in the specified directory.
  ///
  /// [logger] is the logger to use for output.
  /// [cliRunner] is the CLI runner to use for command execution.
  /// [cwd] is the working directory to run in.
  /// [recursive] determines whether to run recursively.
  /// [ignore] is a set of patterns to ignore.
  static Future<bool> installDependencies({
    required Logger logger,
    required CliRunner cliRunner,
    String cwd = '.',
    bool recursive = false,
    Set<String> ignore = const {},
  }) async {
    final initialCwd = cwd;

    final results = await _runCommand(
      cmd: (cwd) async {
        final relativePath = p.relative(cwd, from: initialCwd);
        final path =
            relativePath == '.' ? '.' : '.${p.context.separator}$relativePath';

        final installProgress =
            logger.progress('Running "flutter pub get" in $path');

        try {
          final result = await cliRunner.runCommand(
            'flutter',
            ['pub', 'get'],
            dir: cwd,
            log: logger,
          );
          return result;
        } finally {
          installProgress.complete();
        }
      },
      cwd: cwd,
      recursive: recursive,
      ignore: ignore,
    );

    return results.every((result) => result.exitCode == 0);
  }

  /// Runs the build_runner to generate code.
  ///
  /// [logger] is the logger to use for output.
  /// [cliRunner] is the CLI runner to use for command execution.
  /// [cwd] is the working directory to run in.
  /// [deleteConflicting] determines whether to delete conflicting outputs.
  /// [watch] determines whether to watch for changes continuously.
  static Future<bool> runBuildRunner({
    required Logger logger,
    required CliRunner cliRunner,
    String cwd = '.',
    bool deleteConflicting = true,
    bool watch = false,
  }) async {
    final command = watch ? 'watch' : 'build';
    final arguments = ['pub', 'run', 'build_runner', command];

    if (deleteConflicting) {
      arguments.add('--delete-conflicting-outputs');
    }

    final buildProgress = logger.progress(
      'Running build_runner ${watch ? 'watch' : 'build'}...',
    );

    try {
      final result = await cliRunner.runCommand(
        'flutter',
        arguments,
        dir: cwd,
        log: logger,
        shouldThrowOnError: false,
      );

      if (result.exitCode != 0) {
        buildProgress.fail('Build runner failed: ${result.stderr}');
        return false;
      }

      if (watch) {
        buildProgress.complete('Build runner watch started');
        logger.info(
          'Watching for changes. Press Ctrl+C to stop.',
        );
      } else {
        buildProgress.complete('Code generation completed successfully');
      }

      return true;
    } catch (e) {
      buildProgress.fail('Build runner failed: $e');
      return false;
    }
  }

  /// Applies Dart fixes to the code.
  ///
  /// [logger] is the logger to use for output.
  /// [cliRunner] is the CLI runner to use for command execution.
  /// [cwd] is the working directory to run in.
  /// [recursive] determines whether to run recursively.
  /// [ignore] is a set of patterns to ignore.
  static Future<void> applyFixes({
    required Logger logger,
    required CliRunner cliRunner,
    String cwd = '.',
    bool recursive = false,
    Set<String> ignore = const {},
  }) async {
    if (!recursive) {
      await _applyFixToDirectory(cwd, logger, cliRunner);
      return;
    }

    final directoriesToFix = _findDirectoriesWithPubspec(cwd, ignore);

    if (directoriesToFix.isEmpty) {
      throw CliException('No directories with pubspec.yaml found.');
    }

    await Future.wait(directoriesToFix
        .map((dir) => _applyFixToDirectory(dir, logger, cliRunner)));
  }

  /// Applies Dart fixes to a specific directory.
  static Future<void> _applyFixToDirectory(
    String directory,
    Logger logger,
    CliRunner cliRunner,
  ) async {
    final pubspec = File(p.join(directory, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw CliException('pubspec.yaml not found in $directory');
    }

    await cliRunner.runCommand(
      'dart',
      ['fix', '--apply'],
      dir: directory,
      log: logger,
    );
  }

  /// Finds directories containing pubspec.yaml files.
  static List<String> _findDirectoriesWithPubspec(
    String cwd,
    Set<String> ignore,
  ) {
    return Directory(cwd)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) =>
            file.path.endsWith('pubspec.yaml') && !_shouldIgnore(file, ignore))
        .map((file) => file.parent.path)
        .toList();
  }

  /// Checks if a file should be ignored.
  static bool _shouldIgnore(File file, Set<String> ignore) {
    return ignore.any((pattern) => file.path.contains(pattern));
  }

  /// Runs a command in specified directories.
  static Future<List<T>> _runCommand<T>({
    required Future<T> Function(String cwd) cmd,
    required String cwd,
    required bool recursive,
    required Set<String> ignore,
  }) async {
    if (!recursive) {
      final pubspec = File(p.join(cwd, 'pubspec.yaml'));
      if (!pubspec.existsSync()) {
        throw CliException(('pubspec.yaml not found in $cwd'));
      }

      return [await cmd(cwd)];
    }

    final processes = CliRunner.runWhere<T>(
      run: (entity) => cmd(entity.parent.path),
      where: (entity) => !ignore.excludesEntity(entity) && _isPubspec(entity),
      cwd: cwd,
    );

    if (processes.isEmpty) {
      throw CliException('No pubspec.yaml files found in $cwd');
    }

    final results = <T>[];
    for (final process in processes) {
      results.add(await process);
    }
    return results;
  }
}
