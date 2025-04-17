/// Generator for manual serialization models (no external packages).
class ManualGenerator {
  /// Generates a model class with manual serialization with the given name and fields.
  ///
  /// If [skipHeader] is true, any imports will be omitted.
  static String generate({
    required String modelName,
    required Map<String, String> fields,
    bool skipHeader = false,
  }) {
    final buffer = StringBuffer();

    // No imports needed for manual serialization
    if (!skipHeader) {
      buffer.writeln();
    }

    buffer.writeln('class $modelName {');

    // Add field declarations
    for (final field in fields.entries) {
      buffer.writeln('  final ${field.value} ${field.key};');
    }

    buffer.writeln();

    // Constructor
    buffer.writeln('  $modelName({');
    for (final field in fields.entries) {
      buffer.writeln('    required this.${field.key},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // fromJson factory
    buffer
        .writeln('  factory $modelName.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return $modelName(');

    for (final field in fields.entries) {
      final fieldName = field.key;
      final fieldType = field.value;

      if (fieldType == 'String' ||
          fieldType == 'int' ||
          fieldType == 'double' ||
          fieldType == 'bool') {
        buffer.writeln('      $fieldName: json[\'$fieldName\'] as $fieldType,');
      } else if (fieldType == 'List<String>' ||
          fieldType == 'List<int>' ||
          fieldType == 'List<double>' ||
          fieldType == 'List<bool>') {
        final innerType = fieldType.substring(5, fieldType.length - 1);
        buffer.writeln(
          '      $fieldName: (json[\'$fieldName\'] as List<dynamic>?)?.map((e) => e as $innerType).toList() ?? [],',
        );
      } else if (fieldType.startsWith('List<')) {
        final innerType = fieldType.substring(5, fieldType.length - 1);
        buffer.writeln(
          '      $fieldName: (json[\'$fieldName\'] as List<dynamic>?)?.map((e) => $innerType.fromJson(e as Map<String, dynamic>)).toList() ?? [],',
        );
      } else if (fieldType == 'DateTime') {
        buffer.writeln(
          '      $fieldName: json[\'$fieldName\'] != null ? DateTime.parse(json[\'$fieldName\'] as String) : DateTime.now(),',
        );
      } else {
        // For nested objects, assume they're required unless the type ends with "?"
        if (fieldType.endsWith('?')) {
          final nonNullableType = fieldType.substring(0, fieldType.length - 1);
          buffer.writeln(
            '      $fieldName: json[\'$fieldName\'] != null ? $nonNullableType.fromJson(json[\'$fieldName\'] as Map<String, dynamic>) : null,',
          );
        } else {
          buffer.writeln(
            '      $fieldName: $fieldType.fromJson(json[\'$fieldName\'] as Map<String, dynamic>),',
          );
        }
      }
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // toJson method
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');

    for (final field in fields.entries) {
      final fieldName = field.key;
      final fieldType = field.value;

      if (fieldType == 'String' ||
          fieldType == 'int' ||
          fieldType == 'double' ||
          fieldType == 'bool') {
        buffer.writeln('      \'$fieldName\': $fieldName,');
      } else if (fieldType.startsWith('List<')) {
        final innerType = fieldType.substring(5, fieldType.length - 1);
        if (innerType == 'String' ||
            innerType == 'int' ||
            innerType == 'double' ||
            innerType == 'bool') {
          buffer.writeln('      \'$fieldName\': $fieldName,');
        } else {
          buffer.writeln(
            '      \'$fieldName\': $fieldName.map((e) => e.toJson()).toList(),',
          );
        }
      } else if (fieldType == 'DateTime') {
        buffer.writeln('      \'$fieldName\': $fieldName.toIso8601String(),');
      } else {
        buffer.writeln('      \'$fieldName\': $fieldName?.toJson(),');
      }
    }

    buffer.writeln('    };');
    buffer.writeln('  }');

    buffer.writeln('}');

    return buffer.toString();
  }
}
