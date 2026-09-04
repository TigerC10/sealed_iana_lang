import 'package:generator/src/registry_parser.dart';
import 'package:test/test.dart';

void main() {
  group('parseRegistry', () {
    test('reads the File-Date header and skips it as a record', () {
      final parsed = parseRegistry('File-Date: 2026-08-08\n%%\n'
          'Type: language\nSubtag: aa\nDescription: Afar\nAdded: 2005-10-16\n');

      expect(parsed.fileDate, '2026-08-08');
      expect(parsed.records, hasLength(1));
      expect(parsed.records.single.first('Subtag'), 'aa');
    });

    test('joins folded continuation lines with a single space', () {
      final parsed = parseRegistry('File-Date: 2026-01-01\n%%\n'
          'Type: variant\nSubtag: x\n'
          'Comments: first line\n  second line\n  third line\n'
          'Added: 2020-01-01\n');

      expect(
        parsed.records.single.first('Comments'),
        'first line second line third line',
      );
    });

    test('collects repeated fields in order', () {
      final parsed = parseRegistry('File-Date: 2026-01-01\n%%\n'
          'Type: extlang\nSubtag: x\n'
          'Description: One\nDescription: Two\n'
          'Prefix: a\nPrefix: b\nAdded: 2020-01-01\n');

      final record = parsed.records.single;
      expect(record.all('Description'), ['One', 'Two']);
      expect(record.all('Prefix'), ['a', 'b']);
    });

    test('handles CRLF line endings', () {
      final parsed = parseRegistry('File-Date: 2026-01-01\r\n%%\r\n'
          'Type: script\r\nSubtag: Latn\r\nDescription: Latin\r\n'
          'Added: 2005-10-16\r\n');

      expect(parsed.records.single.first('Description'), 'Latin');
    });
  });
}
