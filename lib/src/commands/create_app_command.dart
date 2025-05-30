import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

import '../common/base_command.dart';
import 'create_flutter_app.dart';

class CreateAppCommand extends Command<int> {
  CreateAppCommand({
    required Logger logger,
    @visibleForTesting MasonGeneratorFromBundle? generatorFromBundle,
    @visibleForTesting MasonGeneratorFromBrick? generatorFromBrick,
  }) {
    addSubcommand(
      CreateFlutterApp(
        logger: logger,
        generatorFromBundle: generatorFromBundle,
        generatorFromBrick: generatorFromBrick,
      ),
    );
  }

  @override
  String get description => 'Create a new Flutter application interactively 🚀';

  @override
  String get name => 'create';
}
