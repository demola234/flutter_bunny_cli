import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/commands/create_flutter_app.dart';
import 'package:flutter_bunny/src/common/base_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';

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
