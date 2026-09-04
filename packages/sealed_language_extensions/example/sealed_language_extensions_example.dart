import 'package:sealed_language_extensions/sealed_language_extensions.dart';

void main() {
  print('Registered extensions: ${LanguageTagExtension.list.length}');
  print('Generated from registry dated ${LanguageTagExtension.fileDate}');

  for (final extension in LanguageTagExtension.list) {
    print('${extension.identifier}: ${extension.description} '
        '(${extension.rfc}, ${extension.authority})');
  }

  // Case-insensitive lookup.
  final unicode = LanguageTagExtension.maybeFromIdentifier('U');
  print('u -> ${unicode?.description}'); // u -> Unicode Locale

  // Throwing lookup and round-trip serialization.
  final transformed = LanguageTagExtension.fromIdentifier('t');
  final restored = LanguageTagExtension.fromJson(transformed.toJson());
  print('round-trip equal: ${restored == transformed}'); // true

  // Exhaustive pattern matching over the sealed hierarchy.
  final label = switch (transformed) {
    SpecifyingTransformedContentExtension() => 'transform',
    UnicodeLocaleExtension() => 'locale',
  };
  print('t -> $label'); // t -> transform
}
