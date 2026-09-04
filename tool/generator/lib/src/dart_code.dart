/// Helpers for emitting Dart source from generators.
library;

/// Returns [value] as a single-quoted Dart string literal, escaping the
/// characters that are significant inside such a literal.
String dartString(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\n', r'\n');

  return "'$escaped'";
}

/// Returns a Dart list literal of string values, or an empty-list literal.
String dartStringList(Iterable<String> values) {
  final items = values.map(dartString).join(', ');

  return '[$items]';
}

/// The standard header placed at the top of every generated file.
String generatedHeader({required String source, required String fileDate}) =>
    '''
// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Source: $source
// Registry File-Date: $fileDate
//
// Regenerate with: dart run generator:generate
''';
