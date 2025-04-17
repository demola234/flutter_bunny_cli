/// Generator for json_serializable models.
class JsonSerializableGenerator {
  /// Generates a json_serializable model class with the given name and fields.
  ///
  /// If [skipHeader] is true, the imports and part declarations will be omitted.
  static String generate({
    required String modelName,
    required Map<String, String> fields,
    bool skipHeader = false,
  }) {
    final buffer = StringBuffer();

    if (!skipHeader) {
      buffer
          .writeln('import \'package:json_annotation/json_annotation.dart\';');
      buffer.writeln();
      buffer.writeln('part \'${_toSnakeCase(modelName)}.g.dart\';');
      buffer.writeln();
    }

    buffer.writeln('@JsonSerializable()');
    buffer.writeln('class $modelName {');

    // Add field declarations
    for (final field in fields.entries) {
      if (_needsJsonKey(field.key)) {
        buffer.writeln('  @JsonKey(name: "${field.key}")');
      }
      buffer
          .writeln('  final ${field.value} ${_sanitizeFieldName(field.key)};');
    }

    buffer.writeln();

    // Constructor
    buffer.writeln('  $modelName({');
    for (final field in fields.entries) {
      buffer.writeln('    required this.${_sanitizeFieldName(field.key)},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // fromJson factory
    buffer.writeln(
      '  factory $modelName.fromJson(Map<String, dynamic> json) => ',
    );
    buffer.writeln('      _\$${modelName}FromJson(json);');
    buffer.writeln();

    // toJson method
    buffer.writeln(
      '  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);',
    );

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Checks if a field name needs a JsonKey annotation.
  static bool _needsJsonKey(String fieldName) {
    // Fields that contain non-alphanumeric characters or start with numbers
    // need JsonKey annotations
    return RegExp(r'[^a-zA-Z0-9_]|^\d').hasMatch(fieldName);
  }

  /// Sanitizes a field name to be a valid Dart identifier.
  static String _sanitizeFieldName(String fieldName) {
    // Replace invalid characters with underscores
    String sanitized = fieldName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it doesn't start with a number
    if (RegExp(r'^\d').hasMatch(sanitized)) {
      sanitized = '_$sanitized';
    }

    return sanitized;
  }

  /// Converts a PascalCase string to snake_case.
  static String _toSnakeCase(String text) {
    if (text.isEmpty) return text;

    final result = text.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (Match match) => '${match.group(1)}_${match.group(2)?.toLowerCase()}',
    );

    return result.replaceAllMapped(
      RegExp(r'^([A-Z])'),
      (Match match) => '${match.group(1)?.toLowerCase()}',
    );
  }
}
