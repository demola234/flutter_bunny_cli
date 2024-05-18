library;

import 'dart:io';

import 'package:args/args.dart';
import 'package:mason/mason.dart';

import '../bin/example_bundle.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('bundle',
        abbr: 'b', help: 'Path to the Mason bundle file', mandatory: true)
    ..addOption('output',
        abbr: 'o',
        help: 'Output directory for the unbundled project',
        mandatory: true)
    ..addOption('name', abbr: 'n', help: 'Project name', mandatory: true)
    ..addOption('description',
        abbr: 'd', help: 'Project description', defaultsTo: '');

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    print(parser.usage);
    exit(1);
  }

  await generateProject();
}


Future<void> generateProject() async {
  final generator = await MasonGenerator.fromBundle(exampleBundle);

  final targetDir = Directory("newCreate");
  final target = DirectoryGeneratorTarget(targetDir);

  final vars = <String, dynamic>{
    'name': "name",
    'description': "description",
  };

  final result = await generator.generate(target, vars: vars);

  if (result.isNotEmpty) {
     print('Project "create" created successfully.');
  } else {
    print('Failed to create project.');
    exit(1);
  }
}
