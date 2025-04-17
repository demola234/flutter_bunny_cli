/// Generator for Freezed models.
class FreezedGenerator {
  /// Generates a Freezed model class with the given name and fields.
  ///
  /// If [skipHeader] is true, the imports and part declarations will be omitted.
  static String generate({
    required String modelName,
    required Map<String, String> fields,
    bool skipHeader = false,
  }) {
    final buffer = StringBuffer();

    if (!skipHeader) {
      buffer.writeln('// ignore_for_file: invalid_annotation_target');
      buffer.writeln();
      buffer.writeln(
        'import \'package:freezed_annotation/freezed_annotation.dart\';',
      );
      buffer.writeln();
      buffer.writeln('part \'${_toSnakeCase(modelName)}.freezed.dart\';');
      buffer.writeln('part \'${_toSnakeCase(modelName)}.g.dart\';');
      buffer.writeln();
    }

    buffer.writeln('@freezed');
    buffer.writeln('class $modelName with _\$$modelName {');
    buffer.writeln('  const factory $modelName({');

    // Add fields with JsonKey annotations
    for (final field in fields.entries) {
      buffer.writeln(
        '    @JsonKey(name: "${field.key}") required ${field.value} ${field.key},',
      );
    }

    buffer.writeln('  }) = _$modelName;');
    buffer.writeln();
    buffer.writeln(
      '  factory $modelName.fromJson(Map<String, dynamic> json) => ',
    );
    buffer.writeln('      _\$${modelName}FromJson(json);');
    buffer.writeln('}');

    return buffer.toString();
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
