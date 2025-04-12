import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

import '../common/base_command.dart';

class OpenWidgetbookCommand extends Command<int> {
  OpenWidgetbookCommand({
    required this.logger,
    @visibleForTesting MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting MasonGeneratorFromBrick? generatorFromBrick,
  });

  final Logger logger;

  @override
  String get description => 'Open Widgetbook for your Flutter application';

  @override
  String get name => 'widgetbook';

  @override
  Future<int> run() async {
    logger.info('📦 Launching Widgetbook on desktop...');

    try {
      final result = await Process.start(
        '/usr/bin/env',
        ['flutter', 'run', '-d', 'macos', '-t', 'lib/widgetbook.dart'],
        mode: ProcessStartMode.inheritStdio,
      );
      final exitCode = await result.exitCode;
      return exitCode;
    } catch (e, stack) {
      logger.err('❌ Failed to launch Widgetbook: $e');
      logger.detail('Stack trace:\n$stack');
      return ExitCode.osError.code;
    }
  }
}
