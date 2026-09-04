import 'package:sealed_language_subtags/sealed_language_subtags.dart';
import 'package:test/test.dart';

void main() {
  group('LanguageSubtag data', () {
    test('exposes non-empty lists for every type', () {
      expect(LanguageSubtag.languages, isNotEmpty);
      expect(LanguageSubtag.extendedLanguages, isNotEmpty);
      expect(LanguageSubtag.scripts, isNotEmpty);
      expect(LanguageSubtag.regions, isNotEmpty);
      expect(LanguageSubtag.variants, isNotEmpty);
      expect(LanguageSubtag.grandfatheredTags, isNotEmpty);
      expect(LanguageSubtag.redundantTags, isNotEmpty);
    });

    test('list is the concatenation of every typed list', () {
      final expected = LanguageSubtag.languages.length +
          LanguageSubtag.extendedLanguages.length +
          LanguageSubtag.scripts.length +
          LanguageSubtag.regions.length +
          LanguageSubtag.variants.length +
          LanguageSubtag.grandfatheredTags.length +
          LanguageSubtag.redundantTags.length;

      expect(LanguageSubtag.list.length, expected);
    });

    test('fileDate is an ISO date', () {
      expect(LanguageSubtag.fileDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });
  });

  group('lookups are case-insensitive', () {
    test('maybeFromLanguage', () {
      final english = LanguageSubtag.maybeFromLanguage('EN');
      expect(english, isNotNull);
      expect(english!.description, 'English');
      expect(english.suppressScript, 'Latn');
    });

    test('maybeFromScript', () {
      expect(LanguageSubtag.maybeFromScript('latn')?.description, 'Latin');
    });

    test('maybeFromRegion', () {
      expect(
          LanguageSubtag.maybeFromRegion('us')?.description, 'United States');
    });

    test('null or empty input returns null', () {
      expect(LanguageSubtag.maybeFromLanguage('not-a-subtag'), isNull);
      expect(LanguageSubtag.maybeFromLanguage(null), isNull);
      expect(LanguageSubtag.maybeFromLanguage(''), isNull);
    });
  });

  group('throwing lookups', () {
    test('return the record for every type', () {
      expect(LanguageSubtag.fromLanguage('en').description, 'English');
      expect(LanguageSubtag.fromScript('Latn').description, 'Latin');
      expect(LanguageSubtag.fromRegion('US').description, 'United States');
      expect(
        LanguageSubtag.fromExtendedLanguage(
          LanguageSubtag.extendedLanguages.first.subtag,
        ),
        LanguageSubtag.extendedLanguages.first,
      );
      expect(
        LanguageSubtag.fromVariant(LanguageSubtag.variants.first.subtag),
        LanguageSubtag.variants.first,
      );
      expect(
        LanguageSubtag.fromGrandfathered(
          LanguageSubtag.grandfatheredTags.first.subtag,
        ),
        LanguageSubtag.grandfatheredTags.first,
      );
      expect(
        LanguageSubtag.fromRedundant(LanguageSubtag.redundantTags.first.subtag),
        LanguageSubtag.redundantTags.first,
      );
    });

    test('throw a StateError when not found', () {
      expect(() => LanguageSubtag.fromLanguage('notacode'), throwsStateError);
      expect(() => LanguageSubtag.fromScript('notacode'), throwsStateError);
      expect(() => LanguageSubtag.fromRegion('notacode'), throwsStateError);
      expect(
        () => LanguageSubtag.fromExtendedLanguage('notacode'),
        throwsStateError,
      );
      expect(() => LanguageSubtag.fromVariant('notacode'), throwsStateError);
      expect(
        () => LanguageSubtag.fromGrandfathered('notacode'),
        throwsStateError,
      );
      expect(() => LanguageSubtag.fromRedundant('notacode'), throwsStateError);
    });
  });

  group('maybe lookups by type', () {
    test('return matches for every type (case-insensitive)', () {
      final extlang = LanguageSubtag.extendedLanguages.first;
      expect(
        LanguageSubtag.maybeFromExtendedLanguage(extlang.subtag.toUpperCase()),
        extlang,
      );

      final variant = LanguageSubtag.variants.first;
      expect(LanguageSubtag.maybeFromVariant(variant.subtag), variant);

      final grandfathered = LanguageSubtag.grandfatheredTags.first;
      expect(
        LanguageSubtag.maybeFromGrandfathered(
          grandfathered.subtag.toUpperCase(),
        ),
        grandfathered,
      );

      final redundant = LanguageSubtag.redundantTags.first;
      expect(LanguageSubtag.maybeFromRedundant(redundant.subtag), redundant);
    });

    test('return null for unknown values', () {
      expect(LanguageSubtag.maybeFromExtendedLanguage('zzzz'), isNull);
      expect(LanguageSubtag.maybeFromVariant('zzzz'), isNull);
      expect(LanguageSubtag.maybeFromGrandfathered('zzzz'), isNull);
      expect(LanguageSubtag.maybeFromRedundant('zzzz'), isNull);
    });
  });

  group('maybeFromValue', () {
    test('matches on a custom selector', () {
      final byPreferred = LanguageSubtag.maybeFromValue(
        'MM',
        where: (subtag) => subtag.preferredValue,
      );
      expect(byPreferred, isNotNull);
      expect(
        LanguageSubtag.maybeFromValue('nope', where: (s) => s.subtag),
        isNull,
      );
    });
  });

  group('type helpers', () {
    test('report the type for each subclass', () {
      expect(LanguageSubtag.languages.first.isLanguage, isTrue);
      expect(LanguageSubtag.extendedLanguages.first.isExtendedLanguage, isTrue);
      expect(LanguageSubtag.scripts.first.isScript, isTrue);
      expect(LanguageSubtag.regions.first.isRegion, isTrue);
      expect(LanguageSubtag.variants.first.isVariant, isTrue);
      expect(LanguageSubtag.grandfatheredTags.first.isGrandfathered, isTrue);
      expect(LanguageSubtag.redundantTags.first.isRedundant, isTrue);
      expect(LanguageSubtag.scripts.first.isLanguage, isFalse);
    });

    test('registry type getter matches every subclass', () {
      expect(LanguageSubtag.languages.first.type, 'language');
      expect(LanguageSubtag.extendedLanguages.first.type, 'extlang');
      expect(LanguageSubtag.scripts.first.type, 'script');
      expect(LanguageSubtag.regions.first.type, 'region');
      expect(LanguageSubtag.variants.first.type, 'variant');
      expect(LanguageSubtag.grandfatheredTags.first.type, 'grandfathered');
      expect(LanguageSubtag.redundantTags.first.type, 'redundant');
    });
  });

  group('sealed hierarchy', () {
    test('supports exhaustive pattern matching', () {
      String label(LanguageSubtag subtag) => switch (subtag) {
            Language() => 'language',
            ExtendedLanguage() => 'extlang',
            Script() => 'script',
            Region() => 'region',
            Variant() => 'variant',
            Grandfathered() => 'grandfathered',
            Redundant() => 'redundant',
          };

      expect(label(LanguageSubtag.languages.first), 'language');
      expect(label(LanguageSubtag.scripts.first), 'script');
    });

    test('deprecated records expose deprecation info', () {
      final deprecated =
          LanguageSubtag.list.where((s) => s.isDeprecated).toList();
      expect(deprecated, isNotEmpty);
      expect(deprecated.first.deprecated, isNotNull);
    });

    test('extended languages carry a required prefix', () {
      for (final extlang in LanguageSubtag.extendedLanguages) {
        expect(extlang.prefix, isNotEmpty);
      }
    });
  });

  group('serialization', () {
    test('toMap includes type-specific fields', () {
      final english = LanguageSubtag.fromLanguage('en');
      final map = english.toMap();
      expect(map['type'], 'language');
      expect(map['subtag'], 'en');
      expect(map['suppressScript'], 'Latn');

      final extlang = LanguageSubtag.extendedLanguages.first;
      expect(extlang.toMap()['prefix'], extlang.prefix);
    });

    test('toJson/fromJson round-trips for every type', () {
      final samples = <LanguageSubtag>[
        LanguageSubtag.languages.first,
        LanguageSubtag.extendedLanguages.first,
        LanguageSubtag.scripts.first,
        LanguageSubtag.regions.first,
        LanguageSubtag.variants.first,
        LanguageSubtag.grandfatheredTags.first,
        LanguageSubtag.redundantTags.first,
      ];

      for (final sample in samples) {
        final restored = LanguageSubtag.fromJson(sample.toJson());
        expect(restored, equals(sample));
        expect(restored.runtimeType, sample.runtimeType);
      }
    });

    test('fromMap rejects an unknown type', () {
      expect(
        () => LanguageSubtag.fromMap({'type': 'nope', 'subtag': 'x'}),
        throwsArgumentError,
      );
    });
  });

  group('LanguageSubtag members', () {
    const english = Language(
      subtag: 'en',
      descriptions: ['English', 'Anglais'],
      added: '2005-10-16',
    );

    test('description returns the first description', () {
      expect(english.description, 'English');
    });

    test('isDeprecated reflects the deprecated field', () {
      expect(english.isDeprecated, isFalse);
      const deprecated = Region(
        subtag: 'BU',
        descriptions: ['Burma'],
        added: '2005-10-16',
        deprecated: '1989-12-05',
        preferredValue: 'MM',
      );
      expect(deprecated.isDeprecated, isTrue);
    });

    test('toString includes subtag and description', () {
      expect(english.toString(), 'Language(en, English)');
    });

    test('compareTo orders by subtag', () {
      const aa =
          Language(subtag: 'aa', descriptions: ['A'], added: '2005-10-16');
      const zz =
          Language(subtag: 'zz', descriptions: ['Z'], added: '2005-10-16');
      final sorted = [zz, aa]..sort();
      expect(sorted.first, aa);
    });

    test('equality is by runtime type and subtag', () {
      expect(english, equals(LanguageSubtag.maybeFromLanguage('en')));
      expect(english.hashCode, LanguageSubtag.maybeFromLanguage('en').hashCode);
      expect(english, isNot(equals(LanguageSubtag.maybeFromLanguage('fr'))));
    });

    test('records of different types are never equal', () {
      const region = Region(
        subtag: 'en',
        descriptions: ['Nowhere'],
        added: '2005-10-16',
      );
      expect(english, isNot(equals(region)));
      const Object notASubtag = 'en';
      expect(english == notASubtag, isFalse);
    });
  });

  group('Object codes and subsets', () {
    test('lookups accept any Object via toString', () {
      final buffer = StringBuffer('EN');
      expect(LanguageSubtag.maybeFromLanguage(buffer)?.subtag, 'en');
      expect(LanguageSubtag.fromScript(StringBuffer('Latn')).subtag, 'Latn');
    });

    test('lookups can search a provided subset', () {
      final english = LanguageSubtag.fromLanguage('en');
      expect(LanguageSubtag.maybeFromLanguage('EN', [english]), english);
      expect(LanguageSubtag.maybeFromLanguage('fr', [english]), isNull);
      expect(
        () => LanguageSubtag.fromLanguage('fr', [english]),
        throwsStateError,
      );
    });
  });

  group('maybeFromValue default selector', () {
    test('matches on subtag when where is omitted', () {
      expect(
        LanguageSubtag.maybeFromValue('en'),
        LanguageSubtag.fromLanguage('en'),
      );
      expect(LanguageSubtag.maybeFromValue('notacode'), isNull);
    });
  });

  group('copyWith', () {
    test('replaces fields for every subtype', () {
      final language = LanguageSubtag.fromLanguage('en');
      expect(language.copyWith(subtag: 'xx').subtag, 'xx');
      expect(language.copyWith(subtag: 'xx').suppressScript, 'Latn');
      expect(
        language.copyWith(scope: LanguageScope.macrolanguage).scope,
        LanguageScope.macrolanguage,
      );

      final extlang = LanguageSubtag.extendedLanguages.first;
      expect(extlang.copyWith(prefix: 'zz').prefix, 'zz');

      final script = LanguageSubtag.scripts.first;
      expect(script.copyWith(added: '2020-01-01').added, '2020-01-01');

      final region = LanguageSubtag.regions.first;
      expect(region.copyWith(added: '2020-01-01').added, '2020-01-01');

      final variant = LanguageSubtag.variants.first;
      expect(variant.copyWith(prefixes: const ['zz']).prefixes, ['zz']);

      final grandfathered = LanguageSubtag.grandfatheredTags.first;
      expect(grandfathered.copyWith(subtag: 'x-test').subtag, 'x-test');

      final redundant = LanguageSubtag.redundantTags.first;
      expect(redundant.copyWith(subtag: 'x-test').subtag, 'x-test');
    });

    test('with no arguments preserves every field', () {
      for (final sample in <LanguageSubtag>[
        LanguageSubtag.languages.first,
        LanguageSubtag.extendedLanguages.first,
        LanguageSubtag.scripts.first,
        LanguageSubtag.regions.first,
        LanguageSubtag.variants.first,
        LanguageSubtag.grandfatheredTags.first,
        LanguageSubtag.redundantTags.first,
      ]) {
        final copy = switch (sample) {
          Language() => sample.copyWith(),
          ExtendedLanguage() => sample.copyWith(),
          Script() => sample.copyWith(),
          Region() => sample.copyWith(),
          Variant() => sample.copyWith(),
          Grandfathered() => sample.copyWith(),
          Redundant() => sample.copyWith(),
        };
        expect(copy, equals(sample));
        expect(copy.toMap(), equals(sample.toMap()));
      }
    });
  });

  group('verbose toString', () {
    test('includes fields when short is false', () {
      final verbose = LanguageSubtag.fromLanguage('en').toString(short: false);
      expect(verbose, contains('subtag'));
      expect(verbose, contains('language'));
      expect(verbose, contains('suppressScript'));
    });
  });

  group('LanguageScope', () {
    test('maybeFromValue resolves registry strings', () {
      expect(LanguageScope.maybeFromValue('macrolanguage'),
          LanguageScope.macrolanguage);
      expect(LanguageScope.maybeFromValue('private-use'),
          LanguageScope.privateUse);
    });

    test('maybeFromValue returns null for null or unknown input', () {
      expect(LanguageScope.maybeFromValue(null), isNull);
      expect(LanguageScope.maybeFromValue('nope'), isNull);
    });
  });
}
