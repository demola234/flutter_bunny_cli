library;

import 'dart:io';

import 'package:flutter_bunny/src/commands/command_runner.dart';

Future<void> main(List<String> args) async {
await _flushThenExit(await FlutterBunnyCommandRunner().run(args));
}



/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<void> _flushThenExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status));
}




// Future<void> main(List<String> arguments) async {
//   final parser = ArgParser()
//     ..addOption('bundle',
//         abbr: 'b', help: 'Path to the Mason bundle file', mandatory: true)
//     ..addOption('output',
//         abbr: 'o',
//         help: 'Output directory for the unbundled project',
//         mandatory: true)
//     ..addOption('name', abbr: 'n', help: 'Project name', mandatory: true)
//     ..addOption('description',
//         abbr: 'd', help: 'Project description', defaultsTo: '');

//   ArgResults results;
//   try {
//     results = parser.parse(arguments);
//   } catch (e) {
//     print('Error: $e');
//     print(parser.usage);
//     exit(1);
//   }

//   await generateProject();
// }


// Future<void> generateProject() async {
//   final generator = await MasonGenerator.fromBundle(veryGoodCoreBundle);

//   final targetDir = Directory("newCreate");
//   final target = DirectoryGeneratorTarget(targetDir);

//   final vars = <String, dynamic>{
//     'project_name': "name",
//     'org_name': "description",
//     'application_id': "com.starter.com",
//     'description': "new project"

//   };

//   final result = await generator.generate(target, vars: vars);

//   if (result.isNotEmpty) {
//      print('Project "create" created successfully.');
//   } else {
//     print('Failed to create project.');
//     exit(1);
//   }
// }
