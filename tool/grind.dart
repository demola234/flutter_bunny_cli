import 'dart:convert';
import 'dart:io';

import 'package:cli_pkg/cli_pkg.dart' as pkg;
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

import '../utils/http.dart';

const _packageName = 'flutter_bunny';
const owner = 'demola234';
const repo = 'bunny_cli';

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
    print('Release: $tagName, Date: $date');
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

  print('Moved install.sh and uninstall.sh to public directory');
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

@Task('Update Homebrew formula')
Future<void> updateHomebrew() async {
  // First check if the version is available from pkg
  final version = pkg.version.canonicalizedVersion;
  final args = context.invocation.arguments;

  log('Generating Homebrew formula for version $version');

  final versionArg = args.getOption('version');
  if (versionArg == null) {
    throw Exception('Version is required. Use --version=X.Y.Z');
  }

  // Make sure you have the compiled binary
  compile();

  // Create a template for the Homebrew formula
  final template = '''
class FlutterBunny < Formula
  desc "Flutter Bunny: A CLI tool for Flutter development"
  homepage "https://github.com/$owner/$repo"
  version "${versionArg.startsWith('v') ? versionArg.substring(1) : versionArg}"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/$owner/$repo/releases/download/v$version/flutter_bunny-$version-macos-arm64.tar.gz"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    else
      url "https://github.com/$owner/$repo/releases/download/v$version/flutter_bunny-$version-macos-x64.tar.gz"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    end
  end

  def install
    bin.install "flutter_bunny"
  end

  test do
    system "#{bin}/flutter_bunny", "--version"
  end
end
''';

  // Write the formula to a file
  final file = File('flutter_bunny.template.rb');
  file.writeAsStringSync(template);

  log('Generated Homebrew formula: ${file.absolute.path}');
  log('You need to manually update the SHA256 hashes and submit this to your Homebrew tap repository.');
}
