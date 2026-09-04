// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Source: https://www.iana.org/assignments/language-tag-extensions-registry/language-tag-extensions-registry
// Registry File-Date: 2014-04-02
//
// Regenerate with: dart run generator:generate

part of 'language_tag_extension.dart';

/// The `t` extension: Specifying Transformed Content.
final class SpecifyingTransformedContentExtension extends LanguageTagExtension {
  const SpecifyingTransformedContentExtension()
      : super(
          identifier: 't',
          description: 'Specifying Transformed Content',
          added: '2011-12-16',
          rfc: '[RFC6497]',
          authority: 'Unicode Consortium',
          contactEmail: 'cldr-contact&unicode.org',
          mailingList: 'cldr-users&unicode.org',
          url: 'http://www.unicode.org/Public/cldr/latest/core.zip',
          comments: const [
            'Subtags for the identification of content that has been transformed, including but not limited to: transliteration, transcription, and translation.'
          ],
        );
}

/// The `u` extension: Unicode Locale.
final class UnicodeLocaleExtension extends LanguageTagExtension {
  const UnicodeLocaleExtension()
      : super(
          identifier: 'u',
          description: 'Unicode Locale',
          added: '2010-09-02',
          rfc: '[RFC6067]',
          authority: 'Unicode Consortium',
          contactEmail: 'cldr-contact&unicode.org',
          mailingList: 'cldr-users&unicode.org',
          url: 'http://www.unicode.org/Public/cldr/latest/core.zip',
          comments: const [
            'Subtags for the identification of language and cultural variations. Used to set behavior in locale APIs. Data is located in the "common/bcp47" directory inside the referenced URL. Unicode Technical Standard #35 (LDML) provides additional reference material defining the keys and values. For more details please see <http://cldr.unicode.org/index/bcp47-extension>.'
          ],
        );
}

/// Every registered language tag extension, in registry order.
const List<LanguageTagExtension> languageTagExtensions = [
  SpecifyingTransformedContentExtension(),
  UnicodeLocaleExtension(),
];

/// The `File-Date` of the source registry.
const String registryFileDate = '2014-04-02';
