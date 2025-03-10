// import 'package:args/command_runner.dart';
// import '../cli/cli_runner.dart';
// import '../common/cli_exception.dart';
// import 'package:mason_logger/mason_logger.dart';

// /// Command to add dependencies to a Flutter project.
// class AddCommand extends Command<int> {
//   /// Creates a new AddCommand.
//   AddCommand({
//     required Logger logger,
//   }) : _logger = logger {
//     addSubcommand(AddPackageCommand(logger: logger));
//     addSubcommand(AddDevPackageCommand(logger: logger));
//   }

//   /// Logger for console output.
//   final Logger _logger;

//   @override
//   String get description => 'Add dependencies to your project';

//   @override
//   String get name => 'add';
// }

// /// Command to add regular package dependencies.
// class AddPackageCommand extends Command<int> {
//   /// Creates a new AddPackageCommand.
//   AddPackageCommand({
//     required Logger logger,
//   }) : _logger = logger {
//     argParser
//       ..addOption(
//         'directory',
//         abbr: 'C',
//         help: 'Directory containing the pubspec.yaml file',
//         defaultsTo: '.',
//       )
//       ..addFlag(
//         'dev',
//         help: 'Add as a dev dependency',
//         negatable: false,
//       )
//       ..addFlag(
//         'recursive',
//         abbr: 'r',
//         help: 'Recursively add to all packages in the directory',
//         negatable: false,
//       );
//   }

//   /// Logger for console output.
//   final Logger _logger;

//   @override
//   String get description => 'Add dependencies to your project';

//   @override
//   String get name => 'package';

//   @override
//   String get invocation => 'flutter_bunny add package <packages...>';

//   @override
//   Future<int> run() async {
//     final packages = argResults?.rest ?? [];
//     if (packages.isEmpty) {
//       _logger.err('No packages specified');
//       printUsage();
//       return ExitCode.usage.code;
//     }

//     final directory = argResults?['directory'] as String;
//     final isDev = argResults?['dev'] as bool;
//     final isRecursive = argResults?['recursive'] as bool;

//     final cliRunner = CliRunner();
//     final progress = _logger.progress(
//       'Adding ${isDev ? 'dev ' : ''}packages: ${packages.join(', ')}',
//     );

//     try {
//       final args = [
//         'pub',
//         'add',
//         if (isDev) '--dev',
//         ...packages,
//       ];

//       if (isRecursive) {
//         // For recursive mode, we need to find all pubspec.yaml files
//         final directories = _findDirectoriesWithPubspec(directory);
//         if (directories.isEmpty) {
//           progress.fail('No pubspec.yaml files found');
//           return ExitCode.software.code;
//         }

//         for (final dir in directories) {
//           final result = await cliRunner.runCommand(
//             'flutter',
//             args,
//             log: _logger,
//             dir: dir,
//             shouldThrowOnError: false,
//           );

//           if (result.exitCode != 0) {
//             _logger.err('Failed to add packages in $dir');
//             _logger.detail('${result.stderr}');
//           }
//         }
//       } else {
//         final result = await cliRunner.runCommand(
//           'flutter',
//           args,
//           log: _logger,
//           dir: directory,
//         );

//         if (result.exitCode != 0) {
//           progress.fail('Failed to add packages');
//           return ExitCode.software.code;
//         }
//       }

//       progress.complete('Added packages successfully');
//       return ExitCode.success.code;
//     } catch (e) {
//       progress.fail('Failed to add packages: $e');
//       return ExitCode.software.code;
//     }
//   }

//   /// Finds directories containing pubspec.yaml files.
//   List<String> _findDirectoriesWithPubspec(String directory) {
//     try {
//       final entities = Directory(directory)
//           .listSync(recursive: true)
//           .whereType<File>()
//           .where((file) => file.path.endsWith('pubspec.yaml'))
//           .map((file) => file.parent.path)
//           .toList();

//       return entities;
//     } catch (e) {
//       _logger.err('Error finding pubspec files: $e');
//       return [];
//     }
//   }
// }

// /// Command to add dev package dependencies.
// class AddDevPackageCommand extends Command<int> {
//   /// Creates a new AddDevPackageCommand.
//   AddDevPackageCommand({
//     required Logger logger,
//   }) : _logger = logger {
//     argParser
//       ..addOption(
//         'directory',
//         abbr: 'C',
//         help: 'Directory containing the pubspec.yaml file',
//         defaultsTo: '.',
//       )
//       ..addFlag(
//         'recursive',
//         abbr: 'r',
//         help: 'Recursively add to all packages in the directory',
//         negatable: false,
//       );
//   }

//   /// Logger for console output.
//   final Logger _logger;

//   @override
//   String get description => 'Add dev dependencies to your project';

//   @override
//   String get name => 'dev-package';

//   @override
//   String get invocation => 'flutter_bunny add dev-package <packages...>';

//   @override
//   Future<int> run() async {
//     final packages = argResults?.rest ?? [];
//     if (packages.isEmpty) {
//       _logger.err('No packages specified');
//       printUsage();
//       return ExitCode.usage.code;
//     }

//     // Re-use the package command, but with --dev flag
//     final packageCmd = AddPackageCommand(logger: _logger);

//     // Set up arguments for the package command
//     final directory = argResults?['directory'] as String;
//     final isRecursive = argResults?['recursive'] as bool;
//     packageCmd.argResultOverrides = {
//       'directory': directory,
//       'dev': true,
//       'recursive': isRecursive,
//       'rest': packages,
//     };

//     return packageCmd.run();
//   }
// }
