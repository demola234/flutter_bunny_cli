import 'package:args/command_runner.dart';
import 'package:flutter_bunny/src/commands/base.dart';
import 'package:flutter_bunny/src/commands/create_flutter_app.dart';
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
  String get summary => '$invocation\n$description';

  @override
  String get description =>
      'Creates a new very good project in the specified directory.';

  @override
  String get name => 'create';

  @override
  String get invocation =>
      'very_good create <subcommand> <project-name> [arguments]';
}
