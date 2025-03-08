import 'package:args/command_runner.dart' show Command;

class UpdateAppCommand extends Command {
  @override
  String get description => 'Update the app';

  @override
  String get name => 'update';

  @override
  Future<void> run() async {
    // TODO: Check what version the user is currenntly on
    // TODO: Check if there is a new version on pub.dev
    // TODO: If there is a new version, ask the user if they want to update
    // TODO: If they say yes, update the app
    // TODO: If they say no, do nothing
    // TODO: If they say something else, ask them again
    // TODO: If they say yes, update the app
  }
}
