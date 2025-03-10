import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'generators/generate_model.dart';
import 'generators/generate_screen.dart';
import 'generators/generate_widget.dart';

/// Command to generate common Flutter application components.
///
/// This command provides subcommands for generating different types of
/// components like screens, widgets, models, etc.
class GenerateCommand extends Command<int> {
  GenerateCommand({
    required Logger logger,
  }) : _logger = logger {
    addSubcommand(GenerateScreenCommand(logger: _logger));
    addSubcommand(GenerateWidgetCommand(logger: _logger));
    addSubcommand(GenerateModelCommand(logger: _logger));
  }

  /// Logger for console output.
  final Logger _logger;

  @override
  String get description => 'Generate Flutter application components 🧩';

  @override
  String get name => 'generate';

  @override
  List<String> get aliases => ['g'];

  @override
  String get summary =>
      'Creates various Flutter components with best practices';

  @override
  String get invocation => 'flutter_bunny generate <component> [arguments]';
}
