import 'package:mason/mason.dart';
import 'package:universal_io/io.dart';

abstract class MasonTemplate {
  const MasonTemplate({
    required this.name,
    required this.bundle,
    required this.help,
  });

  /// The name associated with this template.
  final String name;

  /// The [MasonBundle] used to generate this template.
  final MasonBundle bundle;

  /// The help text shown in the usage information for the CLI.
  final String help;

  /// Callback invoked after template generation has completed.
  Future<void> onGenerateComplete(Logger logger, Directory outputDir);
}
