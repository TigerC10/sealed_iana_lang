import 'package:sealed_language_subtags/sealed_language_subtags.dart';

void main() {
  // Total records and per-type counts.
  print('Total subtags: ${LanguageSubtag.list.length}');
  print('Languages: ${LanguageSubtag.languages.length}');
  print('Scripts: ${LanguageSubtag.scripts.length}');
  print('Generated from registry dated ${LanguageSubtag.fileDate}');

  // Case-insensitive lookups (nullable and throwing variants).
  final english = LanguageSubtag.maybeFromLanguage('en');
  print('en -> ${english?.description}'); // en -> English
  print('en suppress-script -> ${english?.suppressScript}'); // Latn

  // Exhaustive pattern matching over the sealed hierarchy.
  final LanguageSubtag subtag = LanguageSubtag.fromScript('Latn');
  final summary = switch (subtag) {
    Language(:final description) => 'Language: $description',
    ExtendedLanguage(:final description) => 'Ext. language: $description',
    Script(:final description) => 'Script: $description',
    Region(:final description) => 'Region: $description',
    Variant(:final description) => 'Variant: $description',
    Grandfathered(:final description) => 'Grandfathered: $description',
    Redundant(:final description) => 'Redundant: $description',
  };
  print(summary); // Script: Latin

  // Round-trip serialization.
  final restored = LanguageSubtag.fromJson(subtag.toJson());
  print('round-trip equal: ${restored == subtag}'); // true

  // copyWith and a verbose toString.
  final custom = LanguageSubtag.fromLanguage('en').copyWith(subtag: 'xx');
  print(custom.toString(short: false));

  // Filter, for example every macrolanguage.
  final macrolanguages = LanguageSubtag.languages
      .where((l) => l.scope == LanguageScope.macrolanguage)
      .length;
  print('Macrolanguages: $macrolanguages');
}
