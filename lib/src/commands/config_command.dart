import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../common/config_manager.dart';

/// Command to manage Flutter Bunny CLI configuration.
class ConfigCommand extends Command<int> {
  /// Creates a new ConfigCommand.
  ///
  /// [logger] is used for console output.
  ConfigCommand({
    required Logger logger,
  })  : _configManager = ConfigManager(logger: logger) {
    addSubcommand(
        ConfigShowCommand(logger: logger, configManager: _configManager));
    addSubcommand(
        ConfigSetCommand(logger: logger, configManager: _configManager));
    addSubcommand(
        ConfigResetCommand(logger: logger, configManager: _configManager));
  }


  /// The configuration manager.
  final ConfigManager _configManager;

  @override
  String get description => 'Manage Flutter Bunny CLI configuration';

  @override
  String get name => 'config';
}

/// Command to show the current configuration.
class ConfigShowCommand extends Command<int> {
  /// Creates a new ConfigShowCommand.
  ///
  /// [logger] is used for console output.
  /// [configManager] is used to access configuration values.
  ConfigShowCommand({
    required Logger logger,
    required ConfigManager configManager,
  })  : _logger = logger,
        _configManager = configManager {
    argParser.addOption(
      'key',
      help: 'Show only the specified configuration key',
      abbr: 'k',
    );
  }

  /// The logger instance.
  final Logger _logger;

  /// The configuration manager.
  final ConfigManager _configManager;

  @override
  String get description => 'Show the current configuration';

  @override
  String get name => 'show';

  @override
  Future<int> run() async {
    final key = argResults?['key'] as String?;

    if (key != null) {
      final value = _configManager.getValue(key);
      if (value == null) {
        _logger.warn('Configuration key not found: $key');
        return ExitCode.usage.code;
      }

      _logger.info('$key: $value');
      return ExitCode.success.code;
    }

    final config = _configManager.config;
    _logger.info('Flutter Bunny CLI Configuration:');
    _printConfig('', config);

    return ExitCode.success.code;
  }

  /// Prints a configuration section recursively.
  void _printConfig(String prefix, Map<String, dynamic> config) {
    for (final entry in config.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        _logger.info('$prefix$key:');
        _printConfig('$prefix  ', value);
      } else if (value is List) {
        _logger.info('$prefix$key: $value');
      } else {
        _logger.info('$prefix$key: $value');
      }
    }
  }
}

/// Command to set a configuration value.
class ConfigSetCommand extends Command<int> {
  /// Creates a new ConfigSetCommand.
  ///
  /// [logger] is used for console output.
  /// [configManager] is used to access configuration values.
  ConfigSetCommand({
    required Logger logger,
    required ConfigManager configManager,
  })  : _logger = logger,
        _configManager = configManager;

  /// The logger instance.
  final Logger _logger;

  /// The configuration manager.
  final ConfigManager _configManager;

  @override
  String get description => 'Set a configuration value';

  @override
  String get name => 'set';

  @override
  String get invocation => 'flutter_bunny config set <key> <value>';

  @override
  Future<int> run() async {
    final args = argResults?.rest ?? [];

    if (args.length != 2) {
      _logger.err('Invalid arguments. Expected: <key> <value>');
      printUsage();
      return ExitCode.usage.code;
    }

    final key = args[0];
    final value = _parseValue(args[1]);

    final success = await _configManager.setValue(key, value);
    if (!success) {
      _logger.err('Failed to set configuration value');
      return ExitCode.software.code;
    }

    _logger.success('Configuration updated:');
    _logger.info('$key: $value');

    return ExitCode.success.code;
  }

  /// Parses a string value into the appropriate type.
  dynamic _parseValue(String value) {
    // Try to parse as boolean
    if (value.toLowerCase() == 'true') {
      return true;
    } else if (value.toLowerCase() == 'false') {
      return false;
    }

    // Try to parse as number
    final num = int.tryParse(value) ?? double.tryParse(value);
    if (num != null) {
      return num;
    }

    // Try to parse as list
    if (value.startsWith('[') && value.endsWith(']')) {
      final items = value.substring(1, value.length - 1).split(',');
      return items
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    // Otherwise, return as string
    return value;
  }
}

/// Command to reset the configuration to defaults.
class ConfigResetCommand extends Command<int> {
  /// Creates a new ConfigResetCommand.
  ///
  /// [logger] is used for console output.
  /// [configManager] is used to access configuration values.
  ConfigResetCommand({
    required Logger logger,
    required ConfigManager configManager,
  })  : _logger = logger,
        _configManager = configManager {
    argParser.addFlag(
      'confirm',
      abbr: 'y',
      help: 'Confirm reset without prompting',
      negatable: false,
    );
  }

  /// The logger instance.
  final Logger _logger;

  /// The configuration manager.
  final ConfigManager _configManager;

  @override
  String get description => 'Reset configuration to defaults';

  @override
  String get name => 'reset';

  @override
  Future<int> run() async {
    final confirm = argResults?['confirm'] as bool? ?? false;

    if (!confirm) {
      final shouldReset = _logger.confirm(
        'Are you sure you want to reset all configuration to defaults?',
      );

      if (!shouldReset) {
        _logger.info('Reset cancelled');
        return ExitCode.success.code;
      }
    }

    final success = await _configManager.reset();
    if (!success) {
      _logger.err('Failed to reset configuration');
      return ExitCode.software.code;
    }

    _logger.success('Configuration reset to defaults');

    return ExitCode.success.code;
  }
}
