import 'dart:convert';

part 'extensions.g.dart';

/// A single record from the IANA Language Tag Extensions Registry.
///
/// Extensions are defined by RFC 5646 §3.7 and registered per RFC 6497 (`t`)
/// and RFC 6067 (`u`). This is a sealed hierarchy with one concrete subclass
/// per registered extension, enabling exhaustive `switch` matching.
sealed class LanguageTagExtension implements Comparable<LanguageTagExtension> {
  const LanguageTagExtension({
    required this.identifier,
    required this.description,
    required this.added,
    required this.rfc,
    required this.authority,
    required this.contactEmail,
    required this.mailingList,
    required this.url,
    this.comments = const [],
  });

  /// The single-character extension identifier (for example `t` or `u`).
  final String identifier;

  /// The `Description` of the extension.
  final String description;

  /// The `Added` date in ISO `yyyy-mm-dd` form.
  final String added;

  /// The `RFC` reference that defines the extension (for example `[RFC6497]`).
  final String rfc;

  /// The `Authority` responsible for the extension.
  final String authority;

  /// The `Contact_Email` for the extension's authority (registry obfuscation
  /// with `&` in place of `@` is preserved as published).
  final String contactEmail;

  /// The `Mailing_List` for the extension.
  final String mailingList;

  /// The `URL` where the extension's data/specification is published.
  final String url;

  /// Every `Comments` value for the record, in registry order.
  final List<String> comments;

  // -- Static members --

  /// A constant list of every registered language tag extension.
  static const List<LanguageTagExtension> list = languageTagExtensions;

  /// A map of every extension identifier to its [LanguageTagExtension].
  ///
  /// Keys are the single-character identifiers (for example `t`). Use
  /// [LanguageTagExtension.fromIdentifier] or [maybeFromIdentifier] for lookups.
  static final Map<String, LanguageTagExtension> map = {
    for (final extension in list) extension.identifier: extension,
  };

  /// The `File-Date` header of the registry the data was generated from.
  static const String fileDate = registryFileDate;

  // -- Factory methods --

  /// Returns the extension with [identifier] (case-insensitive).
  ///
  /// [identifier] may be any [Object]; its `toString()` is used. An optional
  /// [subset] can be searched instead of the full registry. Throws a
  /// [StateError] if no such extension is registered.
  factory LanguageTagExtension.fromIdentifier(
    Object identifier, [
    Iterable<LanguageTagExtension>? subset,
  ]) {
    final result = maybeFromIdentifier(identifier, subset);
    if (result == null) {
      throw StateError(
        'No LanguageTagExtension found with identifier "$identifier".',
      );
    }

    return result;
  }

  /// Returns the extension with [identifier] (case-insensitive), or `null`.
  ///
  /// [identifier] may be any [Object]; its `toString()` is used. An optional
  /// [subset] can be searched instead of the full registry.
  static LanguageTagExtension? maybeFromIdentifier(
    Object? identifier, [
    Iterable<LanguageTagExtension>? subset,
  ]) {
    if (identifier == null) return null;
    final key = identifier.toString().trim().toLowerCase();
    if (key.isEmpty) return null;
    if (subset == null) return map[key];
    for (final extension in subset) {
      if (extension.identifier == key) return extension;
    }

    return null;
  }

  /// Returns the extension whose [where] result (or `identifier`, when [where]
  /// is omitted) equals [value], searching [extensions] (defaults to [list]).
  static LanguageTagExtension? maybeFromValue<T extends Object>(
    T value, {
    T? Function(LanguageTagExtension extension)? where,
    Iterable<LanguageTagExtension> extensions = list,
  }) {
    for (final extension in extensions) {
      final expected = where?.call(extension) ?? extension.identifier;
      if (expected == value) return extension;
    }

    return null;
  }

  // -- Serialization --

  /// Converts this extension to a JSON-encoded string.
  String toJson({JsonCodec codec = const JsonCodec()}) => codec.encode(toMap());

  /// Converts this extension to a [Map].
  Map<String, Object?> toMap() => {
        'identifier': identifier,
        'description': description,
        'added': added,
        'rfc': rfc,
        'authority': authority,
        'contactEmail': contactEmail,
        'mailingList': mailingList,
        'url': url,
        'comments': comments,
      };

  /// Creates a [LanguageTagExtension] from a JSON-encoded string.
  static LanguageTagExtension fromJson(
    String json, {
    JsonCodec codec = const JsonCodec(),
  }) {
    final decoded = codec.decode(json) as Map<String, Object?>;

    return LanguageTagExtension.fromIdentifier(
        decoded['identifier']! as String);
  }

  // -- Object overrides --

  @override
  int compareTo(LanguageTagExtension other) =>
      identifier.compareTo(other.identifier);

  /// Returns a string representation of this extension.
  ///
  /// When [short] is `false`, every field is included via [toMap].
  @override
  String toString({bool short = true}) => short
      ? '$runtimeType($identifier, $description)'
      : '$runtimeType(${toMap()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageTagExtension &&
          other.runtimeType == runtimeType &&
          other.identifier == identifier;

  @override
  int get hashCode => Object.hash(runtimeType, identifier);
}
