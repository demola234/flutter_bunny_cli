part of 'cli.dart';



/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef GeneratorBuilder = Future<MasonGenerator> Function(MasonBundle);

/// Flutter CLI
class Flutter {
  /// Determine whether flutter is installed.
  static Future<bool> installed({
    required Logger logger,
  }) async {
    try {
      await _Cmd.run('flutter', ['--version'], logger: logger);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Install dart dependencies (`flutter pub get`).
  static Future<bool> pubGet({
    required Logger logger,
    String cwd = '.',
    bool recursive = false,
    Set<String> ignore = const {},
  }) async {
    final initialCwd = cwd;

    final result = await _runCommand(
      cmd: (cwd) async {
        final relativePath = p.relative(cwd, from: initialCwd);
        final path =
            relativePath == '.' ? '.' : '.${p.context.separator}$relativePath';

        final installProgress = logger.progress(
          'Running "flutter pub get" in $path ',
        );

        try {
          return await _Cmd.run(
            'flutter',
            ['pub', 'get'],
            workingDirectory: cwd,
            logger: logger,
          );
        } finally {
          installProgress.complete();
        }
      },
      cwd: cwd,
      recursive: recursive,
      ignore: ignore,
    );
    return result.every((e) => e.exitCode == ExitCode.success.code);
  }

}

/// Run a command on directories with a `pubspec.yaml`.
Future<List<T>> _runCommand<T>({
  required Future<T> Function(String cwd) cmd,
  required String cwd,
  required bool recursive,
  required Set<String> ignore,
}) async {
  if (!recursive) {
    final pubspec = File(p.join(cwd, 'pubspec.yaml'));
    if (!pubspec.existsSync()) throw PubspecNotFound();

    return [await cmd(cwd)];
  }

  final processes = _Cmd.runWhere<T>(
    run: (entity) => cmd(entity.parent.path),
    where: (entity) => !ignore.excludes(entity) && _isPubspec(entity),
    cwd: cwd,
  );

  if (processes.isEmpty) throw PubspecNotFound();

  final results = <T>[];
  for (final process in processes) {
    results.add(await process);
  }
  return results;

}
