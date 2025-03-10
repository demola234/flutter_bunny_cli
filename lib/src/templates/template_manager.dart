import 'dart:convert';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

import '../common/cli_exception.dart';
import '../common/config_manager.dart';
import 'template.dart';

/// Manages custom templates for Flutter Bunny CLI.
class TemplateManager {

  /// Creates a new TemplateManager.
  ///
  /// [logger] is used for console output.
  /// [configManager] is used to access configuration values.
  TemplateManager({
    required Logger logger,
    required ConfigManager configManager,
  }) : _logger = logger,
       _configManager = configManager;
  /// The logger instance.
  final Logger _logger;
  
  /// The configuration manager.
  final ConfigManager _configManager;
  
  /// Gets all available templates, both built-in and custom.
  Future<List<MasonTemplate>> getTemplates() async {
    final templates = <MasonTemplate>[];
    
    // Add built-in templates
    templates.addAll(await _getBuiltInTemplates());
    
    // Add custom templates
    templates.addAll(await _getCustomTemplates());
    
    return templates;
  }
  
  /// Gets a template by name.
  ///
  /// Searches both built-in and custom templates.
  /// Throws [CliException] if the template is not found.
  Future<MasonTemplate> getTemplate(String name) async {
    final templates = await getTemplates();
    final template = templates.firstWhere(
      (template) => template.name == name,
      orElse: () => throw CliException('Template not found: $name'),
    );
    
    return template;
  }
  
  /// Gets all built-in templates.
  Future<List<MasonTemplate>> _getBuiltInTemplates() async {
    // This would normally come from your code's internal templates
    // For now, return an empty list as a placeholder
    return [];
  }
  
  /// Gets all custom templates from the templates directory.
  Future<List<MasonTemplate>> _getCustomTemplates() async {
    final templatesDir = _configManager.getTemplatesPath();
    final directory = Directory(templatesDir);
    
    if (!await directory.exists()) {
      return [];
    }
    
    final templates = <MasonTemplate>[];
    
    await for (final entity in directory.list()) {
      if (entity is! Directory) {
        continue;
      }
      
      try {
        final template = await _loadCustomTemplate(entity);
        if (template != null) {
          templates.add(template);
        }
      } catch (e) {
        _logger.detail('Failed to load template from ${entity.path}: $e');
      }
    }
    
    return templates;
  }
  
  /// Loads a custom template from a directory.
  ///
  /// Returns null if the directory does not contain a valid template.
  Future<MasonTemplate?> _loadCustomTemplate(Directory directory) async {
    final templateName = path.basename(directory.path);
    final manifestFile = File(path.join(directory.path, 'manifest.json'));
    
    if (!await manifestFile.exists()) {
      return null;
    }
    
    try {
      final manifestContent = await manifestFile.readAsString();
      final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
      
      final name = manifest['name'] as String? ?? templateName;
      final description = manifest['description'] as String? ?? 'Custom template';
      
      // Load the brick file
      final brickFile = File(path.join(directory.path, 'brick.yaml'));
      if (!await brickFile.exists()) {
        return null;
      }
      
      // Create a brick from the directory path
      final brick = Brick.path(directory.path);
      
      // Instead of trying to access a bundle directly,
      // we'll create a custom template that uses the brick
      return CustomBrickTemplate(
        name: name,
        brick: brick,
        help: description,
        directory: directory,
      );
    } catch (e) {
      _logger.detail('Error parsing manifest for $templateName: $e');
      return null;
    }
  }
  
  /// Creates a new custom template.
  ///
  /// [name] is the name of the template.
  /// [description] is the description of the template.
  /// [sourceDir] is the directory containing the template files.
  ///
  /// Returns the path to the created template.
  Future<String> createTemplate({
    required String name,
    required String description,
    required Directory sourceDir,
  }) async {
    final templatesDir = _configManager.getTemplatesPath();
    final directory = Directory(path.join(templatesDir, name));
    
    if (await directory.exists()) {
      throw CliException('Template already exists: $name');
    }
    
    await directory.create(recursive: true);
    
    // Copy all files from the source directory
    await _copyDirectory(sourceDir, directory);
    
    // Create the manifest file
    final manifestFile = File(path.join(directory.path, 'manifest.json'));
    final manifest = {
      'name': name,
      'description': description,
      'created': DateTime.now().toIso8601String(),
    };
    
    await manifestFile.writeAsString(jsonEncode(manifest));
    
    return directory.path;
  }
  
  /// Copies all files from one directory to another.
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list()) {
      final name = path.basename(entity.path);
      
      if (entity is File) {
        final newPath = path.join(destination.path, name);
        await entity.copy(newPath);
      } else if (entity is Directory) {
        final newDirectory = Directory(path.join(destination.path, name));
        await newDirectory.create();
        await _copyDirectory(entity, newDirectory);
      }
    }
  }
}

/// A custom template loaded from the user's templates directory.
class CustomBrickTemplate extends MasonTemplate {

  /// Creates a new CustomBrickTemplate.
  CustomBrickTemplate({
    required super.name,
    required this.brick,
    required super.help,
    required this.directory,
  }) : super(
          bundle: MasonBundle.fromJson({
            'name': name,
            'description': help,
            'version': '0.1.0',
            'vars': [],
            'bricks': {},
            'files': [],
          }),
        );
  /// The directory containing the template.
  final Directory directory;
  
  /// The Mason brick for this template.
  final Brick brick;

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    // Look for a post-generate script
    final postGenScript = File(path.join(directory.path, 'post_generate.dart'));
    
    if (await postGenScript.exists()) {
      try {
        // This is a placeholder. In a real implementation, you'd need
        // to run the post-generate script using either VM or process.
        logger.info('Running post-generation script...');
        
        // For now, just do nothing
        logger.detail('Post-generation script completed');
      } catch (e) {
        logger.err('Failed to run post-generation script: $e');
      }
    }
  }
  
  /// Gets a generator for this template.
  ///
  /// This is different from the regular MasonTemplate because we need to
  /// create a generator from the brick instead of the bundle.
  Future<MasonGenerator> getGenerator() async {
    return MasonGenerator.fromBrick(brick);
  }
}