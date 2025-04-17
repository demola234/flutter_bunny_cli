import 'string_utils.dart';

/// Utility class for handling JSON data in model generation.
class JsonUtils {
  /// Identifies the nested structure of a JSON object, returning a map of
  /// potential model class names and their types.
  static Map<String, String> identifyNestedStructure(
      Map<String, dynamic> jsonMap) {
    final nestedStructure = <String, String>{};

    void processMap(Map<String, dynamic> map, String prefix) {
      map.forEach((key, value) {
        if (value is Map<String, dynamic> && value.isNotEmpty) {
          final modelName =
              StringUtils.toPascalCase(prefix.isEmpty ? key : '${prefix}_$key');
          nestedStructure[modelName] = 'Object';
          processMap(value, modelName);
        } else if (value is List && value.isNotEmpty && value.first is Map) {
          final singularKey = key.endsWith('s') && !key.endsWith('ss')
              ? key.substring(0, key.length - 1)
              : key;
          final modelName = StringUtils.toPascalCase(
              prefix.isEmpty ? singularKey : '${prefix}_$singularKey');
          nestedStructure[modelName] = 'List Item';
          if (value.first is Map<String, dynamic>) {
            processMap(value.first as Map<String, dynamic>, modelName);
          }
        }
      });
    }

    processMap(jsonMap, '');
    return nestedStructure;
  }

  /// Extracts all nested models from a JSON object, returning a map where:
  /// - Keys are the model class names (in PascalCase)
  /// - Values are the corresponding JSON objects for those models
  static Map<String, Map<String, dynamic>> extractNestedModels(
      Map<String, dynamic> jsonMap) {
    final nestedModels = <String, Map<String, dynamic>>{};

    void extractFromObject(Map<String, dynamic> map, String baseName) {
      map.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Create nested model name
          final className =
              StringUtils.safeDartModelName(StringUtils.toPascalCase(key));

          // Add to our nested models collection
          nestedModels[className] = value;

          // Continue extracting from this nested object
          extractFromObject(value, className);
        } else if (value is List && value.isNotEmpty && value.first is Map) {
          // For lists of objects, extract the item type
          final itemMap = value.first as Map<String, dynamic>;

          // Derive class name for list items - make singular if plural
          String className = key;
          if (className.endsWith('s') && !className.endsWith('ss')) {
            className = className.substring(0, className.length - 1);
          }
          className = StringUtils.safeDartModelName(
              StringUtils.toPascalCase(className));

          // Add to our nested models collection
          nestedModels[className] = itemMap;

          // Continue extracting from this nested object
          extractFromObject(itemMap, className);
        }
      });
    }

    extractFromObject(jsonMap, "");
    return nestedModels;
  }

  /// Extracts the fields and their Dart types from a JSON object.
  /// Returns a map where keys are field names and values are Dart types.
  static Map<String, String> getFieldsFromJson(Map<String, dynamic>? jsonMap) {
    final fields = <String, String>{};

    if (jsonMap == null) {
      // Default fields if no JSON is provided
      fields['id'] = 'int';
      fields['name'] = 'String';
      fields['createdAt'] = 'DateTime';
      return fields;
    }

    jsonMap.forEach((key, value) {
      // Convert key to a valid Dart identifier in camelCase
      final dartFieldName =
          StringUtils.sanitizeDartIdentifier(StringUtils.toCamelCase(key));

      // Determine Dart type based on JSON value
      String dartType = _getDartTypeForJsonValue(value, dartFieldName);

      fields[dartFieldName] = dartType;
    });

    return fields;
  }

  /// Determines the appropriate Dart type for a JSON value.
  static String _getDartTypeForJsonValue(dynamic value, String fieldName) {
    if (value == null) {
      // For null values, make the type nullable
      return 'dynamic?';
    } else if (value is String) {
      // Check if string is a date
      if (_isDateString(value)) {
        return 'DateTime';
      } else {
        return 'String';
      }
    } else if (value is int) {
      return 'int';
    } else if (value is double) {
      return 'double';
    } else if (value is bool) {
      return 'bool';
    } else if (value is List) {
      if (value.isEmpty) {
        return 'List<dynamic>';
      } else {
        final firstItem = value.first;
        if (firstItem is String) {
          return 'List<String>';
        } else if (firstItem is int) {
          return 'List<int>';
        } else if (firstItem is double) {
          return 'List<double>';
        } else if (firstItem is bool) {
          return 'List<bool>';
        } else if (firstItem is Map) {
          // For nested objects in arrays, use a singular name as the type
          String singularName = fieldName;
          if (singularName.endsWith('s') && !singularName.endsWith('ss')) {
            singularName = singularName.substring(0, singularName.length - 1);
          }
          final nestedClassName = StringUtils.safeDartModelName(
              StringUtils.toPascalCase(singularName));
          return 'List<$nestedClassName>';
        } else {
          return 'List<dynamic>';
        }
      }
    } else if (value is Map) {
      // For nested objects, use a PascalCase version of the field name
      final nestedClassName =
          StringUtils.safeDartModelName(StringUtils.toPascalCase(fieldName));
      // Assume nested objects are required (non-nullable)
      return nestedClassName;
    } else {
      return 'dynamic';
    }
  }

  /// Checks if a string appears to be a date format.
  static bool _isDateString(String value) {
    try {
      // Try parsing as ISO 8601 or common date formats
      DateTime.parse(value);
      return true;
    } catch (_) {
      // Check common date patterns
      final datePatterns = [
        // ISO 8601: YYYY-MM-DD
        RegExp(r'^\d{4}-\d{2}-\d{2}$'),
        // Date with time
        RegExp(r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}'),
        // American format: MM/DD/YYYY
        RegExp(r'^\d{2}/\d{2}/\d{4}$'),
        // European format: DD/MM/YYYY
        RegExp(r'^\d{2}\.\d{2}\.\d{4}$'),
      ];

      return datePatterns.any((pattern) => pattern.hasMatch(value));
    }
  }
}
