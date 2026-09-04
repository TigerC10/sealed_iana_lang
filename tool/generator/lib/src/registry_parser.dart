/// Parser for the IANA registry record-jar text format used by both the
/// language-subtag-registry and the language-tag-extensions-registry.
///
/// The format is defined in RFC 5646 (and RFC 6497/6067 for extensions):
/// records are separated by a line containing only `%%`, each record is a set
/// of `Field: value` lines, and a field body may be folded across several
/// lines by indenting the continuation lines with whitespace.
library;

/// A single parsed registry record.
///
/// Field names map to the list of values encountered for that field, because
/// some fields (for example `Description`, `Prefix` and `Comments`) may appear
/// more than once within a single record.
class RegistryRecord {
  RegistryRecord(this.fields);

  final Map<String, List<String>> fields;

  /// Returns the first value of [field], or `null` when absent.
  String? first(String field) {
    final values = fields[field];
    if (values == null || values.isEmpty) return null;

    return values.first;
  }

  /// Returns every value of [field] in registry order (never `null`).
  List<String> all(String field) => fields[field] ?? const [];
}

/// The result of parsing a registry file: its `File-Date` header plus records.
class ParsedRegistry {
  ParsedRegistry({required this.fileDate, required this.records});

  /// The `File-Date` value from the leading header record (ISO `yyyy-mm-dd`).
  final String fileDate;

  /// Every non-header record, in the order they appear in the source.
  final List<RegistryRecord> records;
}

/// Parses [source] (the raw registry text) into a [ParsedRegistry].
ParsedRegistry parseRegistry(String source) {
  final normalized = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final blocks = normalized.split('\n%%\n');

  var fileDate = '';
  final records = <RegistryRecord>[];

  for (var i = 0; i < blocks.length; i++) {
    final block = blocks[i].trim();
    if (block.isEmpty) continue;

    final record = _parseBlock(block);

    // The first block is the file header; it only carries `File-Date`.
    final date = record.first('File-Date');
    if (i == 0 && date != null) {
      fileDate = date;
      continue;
    }

    if (record.fields.isNotEmpty) records.add(record);
  }

  return ParsedRegistry(fileDate: fileDate, records: records);
}

RegistryRecord _parseBlock(String block) {
  final fields = <String, List<String>>{};
  final lines = block.split('\n');

  String? currentField;
  final buffer = StringBuffer();

  void flush() {
    final field = currentField;
    if (field == null) return;
    (fields[field] ??= <String>[]).add(buffer.toString());
    buffer.clear();
  }

  for (final line in lines) {
    final isContinuation = line.startsWith(' ') || line.startsWith('\t');
    final colon = line.indexOf(':');

    if (!isContinuation && colon > 0) {
      flush();
      currentField = line.substring(0, colon).trim();
      buffer.write(line.substring(colon + 1).trim());
    } else if (currentField != null) {
      // Folded continuation line: join with a single space.
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(line.trim());
    }
  }
  flush();

  return RegistryRecord(fields);
}
