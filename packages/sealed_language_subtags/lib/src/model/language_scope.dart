/// The `Scope` of a language (or extended language) subtag, as defined by
/// RFC 5646 §3.1.5.
enum LanguageScope {
  /// A macrolanguage as defined by ISO 639-3.
  macrolanguage('macrolanguage'),

  /// A collection of languages that share some property.
  collection('collection'),

  /// A special language subtag (for example `zxx`, "no linguistic content").
  special('special'),

  /// A subtag reserved for private use.
  privateUse('private-use');

  const LanguageScope(this.value);

  /// The exact string used in the IANA registry (for example `private-use`).
  final String value;

  /// Returns the [LanguageScope] whose [value] equals [value], or `null`.
  static LanguageScope? maybeFromValue(String? value) {
    if (value == null) return null;
    for (final scope in values) {
      if (scope.value == value) return scope;
    }

    return null;
  }
}
