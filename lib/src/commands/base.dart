import 'package:args/args.dart';
import 'package:args/command_runner.dart';

abstract class FlutterBunnyCommand extends Command<int> {
  FlutterBunnyCommand();

  /// Overridden to support line wrapping when printing usage.
  @override
  late final ArgParser argParser = ArgParser();
}
