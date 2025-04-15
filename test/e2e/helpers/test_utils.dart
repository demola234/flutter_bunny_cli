import 'dart:io';

/// Checks if Flutter is installed and available.
Future<bool> isFlutterInstalled() async {
  try {
    final result = await Process.run('flutter', ['--version']);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

/// Checks if Dart is installed and available.
Future<bool> isDartInstalled() async {
  try {
    final result = await Process.run('dart', ['--version']);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

/// Creates a simple test file with the given content.
Future<void> createTestFile(String path, String content) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
}

/// Reads a file and returns its contents.
Future<String> readFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return await file.readAsString();
}

/// Checks if a directory exists and contains any files.
Future<bool> directoryHasFiles(String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) {
    return false;
  }

  final entities = await dir.list().toList();
  return entities.isNotEmpty;
}

/// Deletes a directory if it exists.
Future<void> deleteDirectory(String path) async {
  final dir = Directory(path);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

/// Waits for a condition to be true with timeout.
Future<bool> waitForCondition(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 30),
  Duration pollInterval = const Duration(milliseconds: 500),
}) async {
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < timeout) {
    if (await condition()) {
      return true;
    }
    await Future.delayed(pollInterval);
  }

  return false;
}
