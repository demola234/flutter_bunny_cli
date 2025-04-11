import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

import '../common/base_command.dart';

class OpenWidgetbookCommand extends Command<int> {
  OpenWidgetbookCommand({
    required Logger logger,
    @visibleForTesting MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting MasonGeneratorFromBrick? generatorFromBrick,
  });

  @override
  String get description => 'Open Widgetbook for your Flutter application';

  @override
  String get name => 'widgetbook';

  @override
  Future<int> run() async {
    print('📦 Launching Widgetbook...');
    try {
      final result = await Process.run(
        'flutter',
        ['run', '-d', 'chrome', '-t', 'lib/widgetbook.dart'],
      );

      stdout.write(result.stdout);
      stderr.write(result.stderr);

      return ExitCode.success.code;
    } catch (e) {
      print('❌ Failed to launch Widgetbook: $e');
      return ExitCode.osError.code;
    }
  }
}
