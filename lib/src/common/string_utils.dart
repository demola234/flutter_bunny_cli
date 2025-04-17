/// Utility class for string manipulations used in model generation.
class StringUtils {
  /// Converts a string to camelCase.
  ///
  /// Examples:
  /// - "user_name" → "userName"
  /// - "api-response" → "apiResponse"
  /// - "First Name" → "firstName"
  static String toCamelCase(String text) {
    if (text.isEmpty) return text;

    // Handle snake_case, kebab-case or spaces
    final words = text.split(RegExp(r'[_\- ]'));

    return words.first.toLowerCase() + words.skip(1).map(capitalize).join();
  }

  /// Converts a string to PascalCase.
  ///
  /// Examples:
  /// - "user_name" → "UserName"
  /// - "api-response" → "ApiResponse"
  /// - "first name" → "FirstName"
  static String toPascalCase(String text) {
    if (text.isEmpty) return text;

    // Handle snake_case, kebab-case or spaces
    final words = text.split(RegExp(r'[_\- ]'));

    return words.map(capitalize).join();
  }

  /// Converts a string to snake_case.
  ///
  /// Examples:
  /// - "UserName" → "user_name"
  /// - "APIResponse" → "api_response"
  /// - "firstName" → "first_name"
  static String toSnakeCase(String text) {
    if (text.isEmpty) return text;

    // Convert camelCase or PascalCase to snake_case
    // First, insert underscore between lowercase and uppercase letters
    String result = text.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (Match match) => '${match.group(1)}_${match.group(2)?.toLowerCase()}',
    );

    // Handle the first character if it's uppercase (PascalCase)
    result = result.replaceAllMapped(
      RegExp(r'^([A-Z])'),
      (Match match) => '${match.group(1)?.toLowerCase()}',
    );

    // Handle consecutive uppercase letters (e.g., APIResponse → api_response)
    result = result.replaceAllMapped(
      RegExp(r'([A-Z])([A-Z][a-z])'),
      (Match match) =>
          '${match.group(1)?.toLowerCase()}_${match.group(2)?.toLowerCase()}',
    );

    return result;
  }

  /// Capitalizes the first letter of a word.
  ///
  /// Example: "name" → "Name"
  static String capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Checks if a string represents a valid Dart identifier.
  static bool isValidDartIdentifier(String text) {
    if (text.isEmpty) return false;

    // Dart identifiers must start with a letter or underscore
    if (!RegExp(r'^[a-zA-Z_]').hasMatch(text)) {
      return false;
    }

    // The rest can be letters, digits, or underscores
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(text)) {
      return false;
    }

    // Check if it's a Dart keyword
    final dartKeywords = {
      'abstract',
      'as',
      'assert',
      'async',
      'await',
      'break',
      'case',
      'catch',
      'class',
      'const',
      'continue',
      'covariant',
      'default',
      'deferred',
      'do',
      'dynamic',
      'else',
      'enum',
      'export',
      'extends',
      'extension',
      'external',
      'factory',
      'false',
      'final',
      'finally',
      'for',
      'Function',
      'get',
      'hide',
      'if',
      'implements',
      'import',
      'in',
      'interface',
      'is',
      'late',
      'library',
      'mixin',
      'new',
      'null',
      'on',
      'operator',
      'part',
      'required',
      'rethrow',
      'return',
      'set',
      'show',
      'static',
      'super',
      'switch',
      'sync',
      'this',
      'throw',
      'true',
      'try',
      'typedef',
      'var',
      'void',
      'while',
      'with',
      'yield',
    };

    return !dartKeywords.contains(text);
  }

  /// Sanitizes a string to be a valid Dart identifier.
  static String sanitizeDartIdentifier(String text) {
    if (text.isEmpty) return '_empty';

    // Replace invalid characters with underscores
    String sanitized = text.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    // Ensure it starts with a letter or underscore
    if (RegExp(r'^[0-9]').hasMatch(sanitized)) {
      sanitized = '_$sanitized';
    }

    // Check if it's a Dart keyword
    final dartKeywords = {
      'abstract',
      'as',
      'assert',
      'async',
      'await',
      'break',
      'case',
      'catch',
      'class',
      'const',
      'continue',
      'covariant',
      'default',
      'deferred',
      'do',
      'dynamic',
      'else',
      'enum',
      'export',
      'extends',
      'extension',
      'external',
      'factory',
      'false',
      'final',
      'finally',
      'for',
      'Function',
      'get',
      'hide',
      'if',
      'implements',
      'import',
      'in',
      'interface',
      'is',
      'late',
      'library',
      'mixin',
      'new',
      'null',
      'on',
      'operator',
      'part',
      'required',
      'rethrow',
      'return',
      'set',
      'show',
      'static',
      'super',
      'switch',
      'sync',
      'this',
      'throw',
      'true',
      'try',
      'typedef',
      'var',
      'void',
      'while',
      'with',
      'yield',
    };

    if (dartKeywords.contains(sanitized)) {
      sanitized = '${sanitized}_';
    }

    return sanitized;
  }

  /// Ensures a model name doesn't conflict with Dart reserved types.
  /// Appends "Model" to the name if needed.
  static String safeDartModelName(String name) {
    // List of Dart/Flutter types and classes that could cause conflicts
    final reservedTypeNames = {
      'List',
      'Map',
      'Set',
      'Future',
      'Stream',
      'Iterable',
      'Iterator',
      'String',
      'Bool',
      'Null',
      'Num',
      'Int',
      'Double',
      'Dynamic',
      'Object',
      'Class',
      'Enum',
      'Exception',
      'Error',
      'Widget',
      'State',
      'BuildContext',
      'Key',
      'Text',
      'Image',
      'Icon',
      'Button',
      'Data',
      'View',
      'File',
      'Color',
      'Style',
      'Route',
      'Navigator',
      'Row',
      'Column',
      'Padding',
      'Container',
      'Center',
      'Main',
    };

    // If the name conflicts with a reserved type, append "Model"
    if (reservedTypeNames.contains(name)) {
      return '${name}Model';
    }

    // Otherwise, return the original name
    return name;
  }
}
