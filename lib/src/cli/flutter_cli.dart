part of 'cli.dart';

const _testOptimizerFileName = '.test_optimizer.dart';

/// Thrown when `flutter pub get` is executed without a `pubspec.yaml`.
class PubspecNotFound implements Exception {}

/// {@template coverage_not_met}
/// Thrown when `flutter test ---coverage --min-coverage`
/// does not meet the provided minimum coverage threshold.
/// {@endtemplate}
class MinCoverageNotMet implements Exception {
  /// {@macro coverage_not_met}
  const MinCoverageNotMet(this.coverage);

  /// The measured coverage percentage (total hits / total found * 100).
  final double coverage;
}

class _CoverageMetrics {
  const _CoverageMetrics._({this.totalHits = 0, this.totalFound = 0});

  /// Generate coverage metrics from a list of lcov records.
  factory _CoverageMetrics.fromLcovRecords(
    List<Record> records,
    String? excludeFromCoverage,
  ) {
    final glob = excludeFromCoverage != null ? Glob(excludeFromCoverage) : null;
    return records.fold<_CoverageMetrics>(
      const _CoverageMetrics._(),
      (current, record) {
        final found = record.lines?.found ?? 0;
        final hit = record.lines?.hit ?? 0;
        if (glob != null && record.file != null) {
          if (glob.matches(record.file!)) {
            return current;
          }
        }
        return _CoverageMetrics._(
          totalFound: current.totalFound + found,
          totalHits: current.totalHits + hit,
        );
      },
    );
  }

  final int totalHits;
  final int totalFound;

  double get percentage => totalFound < 1 ? 0 : (totalHits / totalFound * 100);
}

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

  /// Run tests (`flutter test`).
  /// Returns a list of exit codes for each test process.
  static Future<List<int>> test({
    required Logger logger,
    String cwd = '.',
    bool recursive = false,
    bool collectCoverage = false,
    bool optimizePerformance = false,
    Set<String> ignore = const {},
    double? minCoverage,
    String? excludeFromCoverage,
    String? randomSeed,
    bool? forceAnsi,
    List<String>? arguments,
    void Function(String)? stdout,
    void Function(String)? stderr,
    GeneratorBuilder buildGenerator = MasonGenerator.fromBundle,
  }) async {
    final initialCwd = cwd;

    return _runCommand<int>(
      cmd: (cwd) async {
        final relativePath = p.relative(cwd, from: initialCwd);
        final path =
            relativePath == '.' ? '.' : '.${p.context.separator}$relativePath';

        final installProgress = logger.progress(
          'Running "flutter pub get" in $path ',
        );

        try {
          final processResult = await _Cmd.run(
            'flutter',
            ['pub', 'get'],
            workingDirectory: cwd,
            logger: logger,
          );
          return processResult.exitCode;
        } finally {
          installProgress.complete();
        }
      },
      cwd: cwd,
      recursive: recursive,
      ignore: ignore,
    );
    // return result.every((e) => e.exitCode == ExitCode.success.code);
  }

  static T _overrideAnsiOutput<T>(bool? enableAnsiOutput, T Function() body) =>
      enableAnsiOutput == null
          ? body.call()
          : overrideAnsiOutput(enableAnsiOutput, body);
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

extension on Duration {
  String formatted() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return darkGray.wrap('$twoDigitMinutes:$twoDigitSeconds')!;
  }
}

extension on int {
  String formatSuccess() {
    return this > 0 ? lightGreen.wrap('+$this')! : '';
  }

  String formatFailure() {
    return this > 0 ? lightRed.wrap('-$this')! : '';
  }

  String formatSkipped() {
    return this > 0 ? lightYellow.wrap('~$this')! : '';
  }
}

extension on String {
  String truncated(int maxLength) {
    if (length <= maxLength) return this;
    final truncated = substring(length - maxLength, length).trim();
    return '...$truncated';
  }

  String toSingleLine() {
    return replaceAll('\n', '').replaceAll(RegExp(r'\s\s+'), ' ');
  }
}
