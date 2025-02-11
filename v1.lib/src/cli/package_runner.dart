
part of 'cli_runner.dart';

class PackageRunner {
  final CliRunner cliRunner;

  PackageRunner({required this.cliRunner});

  static Future<bool> isFlutterInstalled({required Logger logger, required CliRunner cliRunner}) async {
    try {
      await cliRunner.runCommand('flutter', ['--version'], log: logger);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDartInstalled({required Logger logger, required CliRunner cliRunner}) async {
    try {
      await cliRunner.runCommand('dart', ['--version'], log: logger);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> installDependencies({
    required Logger logger,
    required CliRunner cliRunner,
    String cwd = '.',
    bool recursive = false,
    Set<String> ignore = const {},
  }) async {
    final initialCwd = cwd;

    final result = await _runCommand(
      cmd: (cwd) async {
        final relativePath = p.relative(cwd, from: initialCwd);
        final path = relativePath == '.' ? '.' : '.${p.context.separator}$relativePath';

        final installProgress = logger.progress('Running "flutter pub get" in $path');

        try {
          return await cliRunner.runCommand('flutter', ['pub', 'get'], dir: cwd, log: logger);
        } finally {
          installProgress.complete();
        }
      },
      cwd: cwd,
      recursive: recursive,
      ignore: ignore,
    );
    return result.every((e) => e.exitCode == 0);
  }

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
      throw PubException();
    }

    await Future.wait(directoriesToFix.map((dir) => _applyFixToDirectory(dir, logger, cliRunner)));
  }

  static Future<void> _applyFixToDirectory(String directory, Logger logger, CliRunner cliRunner) async {
    final pubspec = File(p.join(directory, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw PubException();
    }

    await cliRunner.runCommand('dart', ['fix', '--apply'], dir: directory, log: logger);
  }

  static List<String> _findDirectoriesWithPubspec(String cwd, Set<String> ignore) {
    return Directory(cwd)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('pubspec.yaml') && !_shouldIgnore(file, ignore))
        .map((file) => file.parent.path)
        .toList();
  }

  static bool _shouldIgnore(File file, Set<String> ignore) {
    return ignore.any((pattern) => file.path.contains(pattern));
  }

  static Future<List<T>> _runCommand<T>({
    required Future<T> Function(String cwd) cmd,
    required String cwd,
    required bool recursive,
    required Set<String> ignore,
  }) async {
    if (!recursive) {
      final pubspec = File(p.join(cwd, 'pubspec.yaml'));
      if (!pubspec.existsSync()) throw PubException();

      return [await cmd(cwd)];
    }

    final processes = CliRunner.runWhere<T>(
      run: (entity) => cmd(entity.parent.path),
      where: (entity) => !ignore.excludesEntity(entity) && _isPubspec(entity),
      cwd: cwd,
    );

    if (processes.isEmpty) throw PubException();

    final results = <T>[];
    for (final process in processes) {
      results.add(await process);
    }
    return results;
  }
}
