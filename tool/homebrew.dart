import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:grinder/grinder.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

// Define your repository information
const owner = 'demola234';
const repo = 'flutter_bunny_cli';

Future<void> runHomebrewFormula() async {
  final githubToken = Platform.environment['GITHUB_TOKEN'] ?? '';
  final args = context.invocation.arguments;
  final versionArg = args.getOption('version');
  if (versionArg == null) {
    throw Exception('Version is required');
  }

  log('Generating Homebrew formula for version: $versionArg');
  final versionNoPrefix =
      versionArg.startsWith('v') ? versionArg.substring(1) : versionArg;

  final url = Uri.parse(
    'https://api.github.com/repos/$owner/$repo/releases/tags/$versionArg',
  );

  final headers = {
    if (githubToken.isNotEmpty) 'Authorization': 'token $githubToken',
    'Accept': 'application/vnd.github.v3+json',
  };

  log('Fetching release information from GitHub...');
  final response = await http.get(url, headers: headers);

  if (response.statusCode != 200) {
    log('Failed to fetch release: ${response.statusCode} - ${response.body}');
    log('Generating formula with placeholder values...');

    final sourceTarballUrl =
        'https://github.com/$owner/$repo/archive/refs/tags/$versionArg.tar.gz';

    final templateFile = File('tool/flutter_bunny.template.rb');
    if (!await templateFile.exists()) {
      throw Exception('Template file not found: ${templateFile.path}');
    }

    final template = await templateFile.readAsString();
    final formula = template
        .replaceAll('{{VERSION}}', versionNoPrefix)
        .replaceAll('{{MACOS_X64_URL}}', sourceTarballUrl)
        .replaceAll('{{MACOS_X64_SHA256}}', 'UPDATE_WITH_ACTUAL_HASH')
        .replaceAll('{{MACOS_ARM64_URL}}', sourceTarballUrl)
        .replaceAll('{{MACOS_ARM64_SHA256}}', 'UPDATE_WITH_ACTUAL_HASH');

    final outputFile = File('flutter_bunny.rb');
    await outputFile.writeAsString(formula);
    log('Formula generated with placeholder values at: ${outputFile.absolute.path}');
    return;
  }

  // Process release assets
  final Map<String, dynamic> release = jsonDecode(response.body);
  final List assets = release['assets'];
  log('Found ${assets.length} assets in the release');

  final Map<String, dynamic> assetData = {};
  for (final asset in assets) {
    final assetUrl = Uri.parse(asset['browser_download_url']);
    final filename = path.basename(assetUrl.path);
    log('Processing asset: $filename');

    if (!filename.contains('macos-x64') && !filename.contains('macos-arm64')) {
      log('Skipping non-macOS asset: $filename');
      continue;
    }

    final sha256Hash = await _downloadFile(assetUrl, filename, headers);
    if (sha256Hash.isNotEmpty) {
      assetData[filename] = {
        'url': asset['browser_download_url'],
        'sha256': sha256Hash,
      };
      log('Added asset data for $filename with SHA256: $sha256Hash');
    }
  }

  // Check if we found the required assets
  final macosX64Key = assetData.keys.firstWhere(
    (k) => k.contains('macos-x64'),
    orElse: () => '',
  );

  final macosArm64Key = assetData.keys.firstWhere(
    (k) => k.contains('macos-arm64'),
    orElse: () => '',
  );

  // Generate the formula with real asset data
  final macosX64 = assetData[macosX64Key];
  final macosArm64 = assetData[macosArm64Key];

  if (macosX64Key.isEmpty || macosArm64Key.isEmpty) {
    log('Missing required macOS assets, using fallback...');

    final sourceTarballUrl =
        'https://github.com/$owner/$repo/archive/refs/tags/$versionArg.tar.gz';

    final templateFile = File('tool/flutter_bunny.template.rb');

    if (!await templateFile.exists()) {
      throw Exception('Template file not found: ${templateFile.path}');
    }

    final template = await templateFile.readAsString();
    final formula = template
        .replaceAll('{{VERSION}}', versionNoPrefix)
        .replaceAll('{{MACOS_X64_URL}}', sourceTarballUrl)
        .replaceAll('{{MACOS_X64_SHA256}}', 'UPDATE_WITH_ACTUAL_HASH')
        .replaceAll('{{MACOS_ARM64_URL}}', sourceTarballUrl)
        .replaceAll('{{MACOS_ARM64_SHA256}}', 'UPDATE_WITH_ACTUAL_HASH');

    final outputFile = File('flutter_bunny.rb');
    await outputFile.writeAsString(formula);
    log('Formula generated with placeholder values at: ${outputFile.absolute.path}');
    return;
  }

  log('Generating formula with:\n  Version: $versionNoPrefix\n  x64 URL: ${macosX64['url']}\n  arm64 URL: ${macosArm64['url']}');

  final templateFile = File('tool/flutter_bunny.template.rb');
  if (!await templateFile.exists()) {
    throw Exception('Template file not found: ${templateFile.path}');
  }

  final template = await templateFile.readAsString();
  final formula = template
      .replaceAll('{{VERSION}}', versionNoPrefix)
      .replaceAll('{{MACOS_X64_URL}}', macosX64['url'])
      .replaceAll('{{MACOS_X64_SHA256}}', macosX64['sha256'])
      .replaceAll('{{MACOS_ARM64_URL}}', macosArm64['url'])
      .replaceAll('{{MACOS_ARM64_SHA256}}', macosArm64['sha256']);

  final outputFile = File('flutter_bunny.rb');
  await outputFile.writeAsString(formula);
  log('Formula generated successfully at: ${outputFile.absolute.path}');
}

Future<String> _downloadFile(
  Uri url,
  String filename,
  Map<String, String> headers,
) async {
  log('Downloading file: $url');
  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    await File(filename).writeAsBytes(bytes);
    log('Downloaded: $filename (${bytes.length} bytes)');

    // Calculate SHA-256 hash
    final digest = sha256.convert(bytes);
    final sha256Hash = digest.toString();
    log('SHA-256 Hash: $sha256Hash');
    return sha256Hash;
  }

  log('Failed to download $filename: ${response.statusCode}');
  return '';
}
