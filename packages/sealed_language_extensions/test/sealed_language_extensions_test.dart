import 'package:sealed_language_extensions/sealed_language_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('LanguageTagExtension data', () {
    test('exposes the registered extensions', () {
      expect(LanguageTagExtension.list, isNotEmpty);
      final identifiers =
          LanguageTagExtension.list.map((e) => e.identifier).toSet();
      expect(identifiers, containsAll(<String>{'t', 'u'}));
    });

    test('map is keyed by identifier', () {
      expect(LanguageTagExtension.map.keys, containsAll(<String>{'t', 'u'}));
      expect(LanguageTagExtension.map['t']!.identifier, 't');
    });

    test('fileDate is an ISO date', () {
      expect(
        LanguageTagExtension.fileDate,
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
      );
    });
  });

  group('lookup', () {
    test('maybeFromIdentifier is case-insensitive', () {
      final transformed = LanguageTagExtension.maybeFromIdentifier('T');
      expect(transformed, isNotNull);
      expect(transformed!.identifier, 't');
      expect(transformed.rfc, '[RFC6497]');
    });

    test('maybeFromIdentifier returns null for null or unknown input', () {
      expect(LanguageTagExtension.maybeFromIdentifier(null), isNull);
      expect(LanguageTagExtension.maybeFromIdentifier(''), isNull);
      expect(LanguageTagExtension.maybeFromIdentifier('z'), isNull);
    });

    test('fromIdentifier returns the extension or throws', () {
      expect(LanguageTagExtension.fromIdentifier('U').identifier, 'u');
      expect(() => LanguageTagExtension.fromIdentifier('z'), throwsStateError);
    });

    test('maybeFromValue matches on a custom selector', () {
      final byUrl = LanguageTagExtension.maybeFromValue(
        'http://www.unicode.org/Public/cldr/latest/core.zip',
        where: (extension) => extension.url,
      );
      expect(byUrl, isNotNull);
      expect(
        LanguageTagExtension.maybeFromValue('nope', where: (e) => e.authority),
        isNull,
      );
    });

    test('maybeFromValue matches identifier when where is omitted', () {
      expect(
        LanguageTagExtension.maybeFromValue('t'),
        LanguageTagExtension.fromIdentifier('t'),
      );
      expect(LanguageTagExtension.maybeFromValue('z'), isNull);
    });

    test('accepts any Object identifier via toString', () {
      final buffer = StringBuffer('T');
      expect(LanguageTagExtension.maybeFromIdentifier(buffer)?.identifier, 't');
    });

    test('can search a provided subset', () {
      final transformed = LanguageTagExtension.fromIdentifier('t');
      expect(
        LanguageTagExtension.maybeFromIdentifier('t', [transformed]),
        transformed,
      );
      expect(
        LanguageTagExtension.maybeFromIdentifier('u', [transformed]),
        isNull,
      );
      expect(
        () => LanguageTagExtension.fromIdentifier('u', [transformed]),
        throwsStateError,
      );
    });
  });

  group('serialization', () {
    test('toMap contains every field', () {
      final map = LanguageTagExtension.fromIdentifier('t').toMap();
      expect(map['identifier'], 't');
      expect(map['description'], 'Specifying Transformed Content');
      expect(map['rfc'], '[RFC6497]');
    });

    test('toJson/fromJson round-trips', () {
      for (final extension in LanguageTagExtension.list) {
        final restored = LanguageTagExtension.fromJson(extension.toJson());
        expect(restored, equals(extension));
        expect(restored.runtimeType, extension.runtimeType);
      }
    });
  });

  group('sealed hierarchy', () {
    test('every record has required metadata', () {
      for (final extension in LanguageTagExtension.list) {
        expect(extension.identifier, isNotEmpty);
        expect(extension.description, isNotEmpty);
        expect(extension.authority, isNotEmpty);
        expect(extension.url, isNotEmpty);
      }
    });
  });

  group('value semantics', () {
    test('toString includes identifier and description', () {
      final transformed = LanguageTagExtension.fromIdentifier('t');
      expect(
        transformed.toString(),
        'SpecifyingTransformedContentExtension(t, Specifying Transformed Content)',
      );
    });

    test('compareTo orders by identifier', () {
      final sorted = LanguageTagExtension.list.toList()..sort();
      expect(sorted.first.identifier, 't');
      expect(sorted.last.identifier, 'u');
    });

    test('verbose toString includes fields when short is false', () {
      final verbose =
          LanguageTagExtension.fromIdentifier('t').toString(short: false);
      expect(verbose, contains('identifier'));
      expect(verbose, contains('rfc'));
    });

    test('equality is by runtime type and identifier', () {
      const transformed = SpecifyingTransformedContentExtension();
      expect(
          transformed, equals(LanguageTagExtension.maybeFromIdentifier('t')));
      expect(
        transformed.hashCode,
        LanguageTagExtension.maybeFromIdentifier('t').hashCode,
      );
      expect(
        transformed,
        isNot(equals(LanguageTagExtension.maybeFromIdentifier('u'))),
      );
      const Object notAnExtension = 't';
      expect(transformed == notAnExtension, isFalse);
    });

    test('equal identifiers of the same type compare equal', () {
      // A non-const instance is not canonicalized, so `==` must fall through
      // to the identifier comparison instead of the identity short-circuit.
      // ignore: prefer_const_constructors
      final fresh = SpecifyingTransformedContentExtension();
      expect(fresh, equals(LanguageTagExtension.list.first));
    });
  });
}
