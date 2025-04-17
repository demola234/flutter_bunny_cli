/// Generator for Equatable models.
class EquatableGenerator {
  /// Generates an Equatable model class with the given name and fields.
  ///
  /// If [skipHeader] is true, the imports will be omitted.
  static String generate({
    required String modelName,
    required Map<String, String> fields,
    bool skipHeader = false,
  }) {
    final buffer = StringBuffer();

    if (!skipHeader) {
      buffer.writeln('import \'package:equatable/equatable.dart\';');
      buffer.writeln();
    }

    buffer.writeln('class $modelName extends Equatable {');

    // Add field declarations
    for (final field in fields.entries) {
      buffer.writeln('  final ${field.value} ${field.key};');
    }

    buffer.writeln();

    // Constructor
    buffer.writeln('  const $modelName({');
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
      } else if (fieldType.startsWith('List<')) {
        buffer.writeln(
          '      $fieldName: (json[\'$fieldName\'] as List<dynamic>?)?.map((e) => e as dynamic).cast<${fieldType.substring(5, fieldType.length - 1)}>().toList() ?? [],',
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
          fieldType == 'bool' ||
          fieldType.startsWith('List<')) {
        buffer.writeln('      \'$fieldName\': $fieldName,');
      } else if (fieldType == 'DateTime') {
        buffer.writeln('      \'$fieldName\': $fieldName.toIso8601String(),');
      } else {
        buffer.writeln('      \'$fieldName\': $fieldName?.toJson(),');
      }
    }

    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln();

    // props getter for Equatable
    final propsFields = fields.keys.join(', ');
    buffer.writeln('  @override');
    buffer.writeln('  List<Object?> get props => [$propsFields];');

    buffer.writeln('}');

    return buffer.toString();
  }
}
