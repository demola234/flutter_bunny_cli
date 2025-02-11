import 'dart:async';

import 'package:flutter_bunny/src/common/cli_exception.dart';
import 'package:glob/glob.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

part 'package_runner.dart';

typedef RunProcess = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  bool runInShell,
});

@visibleForTesting
abstract class ProcessOverrides {
  static final _zoneKey = Object();

  /// Retrieves the current [ProcessOverrides] instance from the current [Zone].
  ///
  /// Returns `null` if no [ProcessOverrides] are present in the current [Zone].
  ///
  /// See also:
  /// * [ProcessOverrides.runWithOverrides] to provide [ProcessOverrides]
  /// in a fresh [Zone].
  ///
  static ProcessOverrides? get current {
    return Zone.current[_zoneKey] as ProcessOverrides?;
  }

  /// Executes [body] within a new [Zone] that contains the provided overrides.
  static R runWithOverrides<R>(
    R Function() body, {
    RunProcess? runProcess,
  }) {
    final overrides = _ProcessOverridesImpl(runProcess);
    return runZoned(body, zoneValues: {_zoneKey: overrides});
  }

  /// The method used to run a [Process].
  RunProcess get runProcess => Process.run;
}

class _ProcessOverridesImpl extends ProcessOverrides {
  _ProcessOverridesImpl(this._customRunProcess);

  final RunProcess? _customRunProcess;
  final ProcessOverrides? _previousOverrides = ProcessOverrides.current;

  @override
  RunProcess get runProcess {
    return _customRunProcess ??
        _previousOverrides?.runProcess ??
        super.runProcess;
  }
}

class CliRunner {
  Future<ProcessResult> runCommand(
    String command,
    List<String> arguments, {
    required Logger log,
    bool shouldThrowOnError = true,
    String? dir,
  }) async {
    log.detail('Executing command: $command with arguments: $arguments');

    final processRunner = ProcessOverrides.current?.runProcess ?? Process.run;
    final processResult = await processRunner(
      command,
      arguments,
      workingDirectory: dir,
      runInShell: true,
    );

    log.detail('Standard Output:\n${processResult.stdout}');
    log.detail('Standard Error:\n${processResult.stderr}');

    if (shouldThrowOnError) {
      _validateProcessResult(processResult, command, arguments);
    }

    return processResult;
  }

  _validateProcessResult(
      ProcessResult result, String command, List<String> arguments) {
    if (result.exitCode != 0) {
      throw ProcessException(
          command, arguments, result.stderr as String, result.exitCode);
    }
  }

  // static Future<bool> installFlutterPackages() {}

  static Iterable<Future<T>> runWhere<T>({
    required Future<T> Function(FileSystemEntity) run,
    required bool Function(FileSystemEntity) where,
    String cwd = '.',
  }) {
    List<FileSystemEntity> gatherEntities(String path) {
      var entities =
          Directory(path).listSync(recursive: true).where(where).toList();
      entities.sort((a, b) {
        final aDepth = a.path.split(Platform.pathSeparator).length;
        final bDepth = b.path.split(Platform.pathSeparator).length;
        if (aDepth == bDepth) {
          return a.path.compareTo(b.path);
        }
        return aDepth.compareTo(bDepth);
      });
      return entities;
    }

    var entities = gatherEntities(cwd);
    return entities.map((entity) => run(entity));
  }
}

bool _isPubspec(FileSystemEntity entity) {
  return entity is File &&
      entity.path.endsWith('${Platform.pathSeparator}pubspec.yaml');
}

extension ExclusionSet on Set<String> {
  bool excludesEntity(FileSystemEntity entity) {
    final pathSegments = p.split(entity.path).toSet();

    // Check if any segments are in the ignored directories
    if (_hasIntersection(pathSegments, _ignoredDirectories)) {
      return true;
    }

    // Check if any segments are in this set
    if (_hasIntersection(pathSegments, this)) {
      return true;
    }

    // Check if the entity path matches any of the globs in this set
    return _matchesAnyGlob(entity.path, this);
  }

  bool _hasIntersection(Set<String> set1, Set<String> set2) {
    return set1.intersection(set2).isNotEmpty;
  }

  bool _matchesAnyGlob(String path, Set<String> patterns) {
    for (final pattern in patterns) {
      if (pattern.isNotEmpty && Glob(pattern).matches(path)) {
        return true;
      }
    }
    return false;
  }

  // Assuming _ignoredDirectories is defined somewhere in your code
  static final Set<String> _ignoredDirectories = {'example', 'test', 'build'};
}
