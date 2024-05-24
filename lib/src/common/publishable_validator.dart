import 'package:args/args.dart';

class PublishableValidator {
  static bool isPublishable(ArgResults argResults) {
    return argResults['publishable'] as bool? ?? false;
  }
}