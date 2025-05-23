import 'dart:convert';
import 'dart:io';

import 'package:cli_pkg/cli_pkg.dart' as pkg;
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

import '../utils/http.dart';
import 'homebrew.dart';

const _packageName = 'flutter_bunny';
const owner = 'demola234';
const repo = 'flutter_bunny_cli';

void main(List<String> args) {
  pkg.name.value = _packageName;
  pkg.humanName.value = _packageName;
  pkg.githubUser.value = owner;
  pkg.githubRepo.value = '$owner/$_packageName';
  pkg.homebrewRepo.value = '$owner/homebrew-$_packageName';
  pkg.githubBearerToken.value = Platform.environment['GITHUB_TOKEN'];

  if (args.contains('--versioned-formula')) {
    pkg.homebrewCreateVersionedFormula.value = true;
  }

  pkg.addAllTasks();
  grind(args);
}

@Task('Compile')
void compile() {
  run(
    'dart',
    arguments: [
      'compile',
      'exe',
      'bin/flutter_bunny.dart',
      '-o',
      'flutter_bunny',
    ],
  );
}

@Task('Get all releases')
Future<void> getReleases() async {
  String owner = 'demola234';
  String repo = 'bunny_cli';

  final response = await fetch(
    'https://api.github.com/repos/$owner/$repo/releases?per_page=100',
    headers: {'Accept': 'application/vnd.github.v3+json'},
  );

  final stringBuffer = StringBuffer();

  List releases = jsonDecode(response);
  for (var release in releases) {
    String tagName = release['tag_name'];
    String date = release['published_at'];
    log('Release: $tagName, Date: $date');
    stringBuffer.writeln('Release: $tagName, Date: $date');
  }

  final file = File(path.join(Directory.current.path, 'releases.txt'));

  file.writeAsStringSync(stringBuffer.toString());
}

String getTempTestDir() {
  return path.join(Directory.systemTemp.path, 'flutter_bunny_test');
}

@Task('Prepare test environment')
void testSetup() {
  final testDir = Directory(getTempTestDir());
  if (testDir.existsSync()) {
    testDir.deleteSync(recursive: true);
  }

  runDartScript('bin/flutter_bunny.dart', arguments: ['install', 'stable']);
}

@Task('Move install.sh and uninstall.sh to public directory')
void moveScripts() {
  final installScript = File('scripts/install.sh');
  final uninstallScript = File('scripts/uninstall.sh');

  if (!installScript.existsSync() || !uninstallScript.existsSync()) {
    throw Exception('Install or uninstall script does not exist');
  }

  final publicDir = Directory('docs/public');

  if (!publicDir.existsSync()) {
    throw Exception('Public directory does not exist');
  }

  installScript.copySync(path.join(publicDir.path, 'install.sh'));
  uninstallScript.copySync(path.join(publicDir.path, 'uninstall.sh'));

  log('Moved install.sh and uninstall.sh to public directory');
}

@Task('Run tests')
@Depends(testSetup)
Future<void> test() async {
  await runAsync('dart', arguments: ['test', '--coverage=coverage']);
}

@Task('Get coverage')
Future<void> coverage() async {
  await runAsync('dart', arguments: ['pub', 'global', 'activate', 'coverage']);

  // Format coverage
  await runAsync(
    'dart',
    arguments: [
      'pub',
      'global',
      'run',
      'coverage:format_coverage',
      '--lcov',
      '--packages=.dart_tool/package_config.json',
      '--report-on=lib/',
      '--in=coverage',
      '--out=coverage/lcov.info',
    ],
  );
}

@Task('Generate Homebrew formula')
Future<void> homebrewFormula() async {
  await runHomebrewFormula();
}

@Task('Generate Homebrew formula for GitHub Actions')
Future<void> homebrewDashFormula() async {
  await runHomebrewFormula();
}
