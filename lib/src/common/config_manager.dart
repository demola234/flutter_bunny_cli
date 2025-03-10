import 'dart:convert';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// Manages configuration settings for Flutter Bunny CLI.
///
/// This class handles loading, saving, and accessing user preferences
/// stored in a configuration file.
class ConfigManager {
  /// The logger instance.
  final Logger _logger;
  
  /// The path to the configuration file.
  final String _configPath;
  
  /// The loaded configuration map.
  Map<String, dynamic> _config = {};
  
  /// Whether the configuration has been loaded.
  bool _isLoaded = false;

  /// Creates a new ConfigManager.
  ///
  /// [logger] is used for console output.
  ConfigManager({
    required Logger logger,
  }) : _logger = logger,
       _configPath = _getConfigPath();
       
  /// Gets the configuration values.
  Map<String, dynamic> get config {
    if (!_isLoaded) {
      _load();
    }
    return _config;
  }
  
  /// Gets a configuration value.
  ///
  /// If the key doesn't exist, returns the default value.
  T? getValue<T>(String key, {T? defaultValue}) {
    if (!_isLoaded) {
      _load();
    }
    
    final parts = key.split('.');
    Map<String, dynamic> current = _config;
    
    for (int i = 0; i < parts.length - 1; i++) {
      if (current[parts[i]] is! Map<String, dynamic>) {
        return defaultValue;
      }
      current = current[parts[i]] as Map<String, dynamic>;
    }
    
    final value = current[parts.last];
    if (value == null) {
      return defaultValue;
    }
    
    return value as T?;
  }
  
  /// Sets a configuration value.
  ///
  /// Returns true if the value was set successfully.
  Future<bool> setValue(String key, dynamic value) async {
    if (!_isLoaded) {
      _load();
    }
    
    final parts = key.split('.');
    Map<String, dynamic> current = _config;
    
    for (int i = 0; i < parts.length - 1; i++) {
      if (current[parts[i]] is! Map<String, dynamic>) {
        current[parts[i]] = <String, dynamic>{};
      }
      current = current[parts[i]] as Map<String, dynamic>;
    }
    
    current[parts.last] = value;
    return await _save();
  }
  
  /// Loads the configuration from disk.
  void _load() {
    final file = File(_configPath);
    if (!file.existsSync()) {
      _config = _getDefaultConfig();
      _isLoaded = true;
      return;
    }
    
    try {
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      _config = json;
      _isLoaded = true;
    } catch (e) {
      _logger.err('Failed to load configuration: $e');
      _config = _getDefaultConfig();
      _isLoaded = true;
    }
  }
  
  /// Saves the configuration to disk.
  Future<bool> _save() async {
    final file = File(_configPath);
    
    try {
      // Ensure the directory exists
      final dir = file.parent;
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      
      // Write the configuration
      final content = const JsonEncoder.withIndent('  ').convert(_config);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      _logger.err('Failed to save configuration: $e');
      return false;
    }
  }
  
  /// Gets the path to the configuration file.
  static String _getConfigPath() {
    final home = _getHomeDirectory();
    return path.join(home, '.flutter_bunny', 'config.json');
  }
  
  /// Gets the user's home directory.
  static String _getHomeDirectory() {
    if (Platform.isWindows) {
      return Platform.environment['USERPROFILE'] ?? '';
    }
    return Platform.environment['HOME'] ?? '';
  }
  
  /// Gets the default configuration.
  Map<String, dynamic> _getDefaultConfig() {
    return {
      'templates': {
        'path': path.join(_getHomeDirectory(), '.flutter_bunny', 'templates'),
      },
      'defaults': {
        'architecture': 'clean_architecture',
        'state_management': 'provider',
        'features': ['authentication', 'settings'],
        'modules': ['network_layer'],
      },
      'generation': {
        'with_tests': true,
        'with_comments': true,
      },
    };
  }
  
  /// Gets the path to the templates directory.
  String getTemplatesPath() {
    return getValue<String>(
      'templates.path',
      defaultValue: path.join(_getHomeDirectory(), '.flutter_bunny', 'templates'),
    )!;
  }
  
  /// Resets the configuration to defaults.
  Future<bool> reset() async {
    _config = _getDefaultConfig();
    return await _save();
  }
}