import 'package:args/command_runner.dart';
import 'base_commands.dart';
import 'create_flutter_app.dart';
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
      'Creates a new flutter bunny project in the specified directory.';

  @override
  String get name => 'create';

  @override
  String get invocation =>
      'flutter_bunny create <subcommand> <project-name> [arguments]';
}
