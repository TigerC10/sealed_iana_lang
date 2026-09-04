import 'dart:convert';

import '../generated/subtags.g.dart' as g;
import 'language_scope.dart';

/// A single record from the IANA Language Subtag Registry (RFC 5646).
///
/// This is a sealed hierarchy: every registry record is exactly one of the
/// concrete subclasses below, which enables exhaustive `switch` matching over
/// the registry's `Type` dimension.
///
/// All data is exposed as compile-time constant, tree-shakable lists. Lookups
/// are case-insensitive, matching the comparison rules of BCP 47
/// (RFC 5646 §2.1.1).
sealed class LanguageSubtag implements Comparable<LanguageSubtag> {
  const LanguageSubtag({
    required this.subtag,
    required this.descriptions,
    required this.added,
    this.deprecated,
    this.preferredValue,
    this.comments = const [],
  });

  /// The subtag itself (for example `en`, `Latn`, `US`).
  ///
  /// For [Grandfathered] and [Redundant] records this holds the complete tag
  /// (the registry's `Tag` field, for example `art-lojban`).
  final String subtag;

  /// Every `Description` value for the record, in registry order.
  final List<String> descriptions;

  /// The `Added` date in ISO `yyyy-mm-dd` form.
  final String added;

  /// The `Deprecated` date in ISO `yyyy-mm-dd` form, or `null` if not deprecated.
  final String? deprecated;

  /// The `Preferred-Value` used in place of a deprecated subtag, or `null`.
  final String? preferredValue;

  /// Every `Comments` value for the record, in registry order.
  final List<String> comments;

  /// The primary (first) description of the record.
  String get description => descriptions.first;

  /// Whether this record has been deprecated.
  bool get isDeprecated => deprecated != null;

  /// The registry `Type` of this record (for example `language`, `script`).
  String get type;

  // -- Static data --

  /// Every `Type: language` record.
  static const List<Language> languages = g.languages;

  /// Every `Type: extlang` record.
  static const List<ExtendedLanguage> extendedLanguages = g.extendedLanguages;

  /// Every `Type: script` record.
  static const List<Script> scripts = g.scripts;

  /// Every `Type: region` record.
  static const List<Region> regions = g.regions;

  /// Every `Type: variant` record.
  static const List<Variant> variants = g.variants;

  /// Every `Type: grandfathered` record.
  static const List<Grandfathered> grandfatheredTags = g.grandfatheredTags;

  /// Every `Type: redundant` record.
  static const List<Redundant> redundantTags = g.redundantTags;

  /// A constant list of every subtag record, across all types.
  static const List<LanguageSubtag> list = [
    ...languages,
    ...extendedLanguages,
    ...scripts,
    ...regions,
    ...variants,
    ...grandfatheredTags,
    ...redundantTags,
  ];

  /// The `File-Date` header of the registry the data was generated from.
  static const String fileDate = g.registryFileDate;

  /// A map of lowercased subtag to its [Language].
  static final Map<String, Language> languageMap = _index(languages);

  /// A map of lowercased subtag to its [ExtendedLanguage].
  static final Map<String, ExtendedLanguage> extendedLanguageMap =
      _index(extendedLanguages);

  /// A map of lowercased subtag to its [Script].
  static final Map<String, Script> scriptMap = _index(scripts);

  /// A map of lowercased subtag to its [Region].
  static final Map<String, Region> regionMap = _index(regions);

  /// A map of lowercased subtag to its [Variant].
  static final Map<String, Variant> variantMap = _index(variants);

  /// A map of lowercased tag to its [Grandfathered] record.
  static final Map<String, Grandfathered> grandfatheredMap =
      _index(grandfatheredTags);

  /// A map of lowercased tag to its [Redundant] record.
  static final Map<String, Redundant> redundantMap = _index(redundantTags);

  static Map<String, T> _index<T extends LanguageSubtag>(List<T> items) =>
      {for (final item in items) item.subtag.toLowerCase(): item};

  static T _orThrow<T extends LanguageSubtag>(T? value, String kind, Object c) {
    if (value == null) {
      throw StateError('No $kind found with subtag "$c".');
    }

    return value;
  }

  /// Normalizes a lookup [code] to a lowercased key, or `null` when absent.
  ///
  /// Accepts any [Object]; its `toString()` is used, so a `String`, `Enum`,
  /// `StringBuffer` and similar all work.
  static String? _key(Object? code) {
    if (code == null) return null;
    final normalized = code.toString().trim();

    return normalized.isEmpty ? null : normalized.toLowerCase();
  }

  static T? _lookup<T extends LanguageSubtag>(
    Object? code,
    Map<String, T> map,
    Iterable<T>? subset,
  ) {
    final key = _key(code);
    if (key == null) return null;
    if (subset == null) return map[key];
    for (final item in subset) {
      if (item.subtag.toLowerCase() == key) return item;
    }

    return null;
  }

  // -- Lookups (throwing + nullable, case-insensitive) --
  //
  // Every lookup accepts any [Object] code (its `toString()` is used) and an
  // optional [subset] to search instead of the full registry.

  /// Returns the [Language] with [code]. Throws if none matches.
  static Language fromLanguage(Object code, [Iterable<Language>? subset]) =>
      _orThrow(maybeFromLanguage(code, subset), 'language', code);

  /// Returns the [Language] with [code], or `null`.
  static Language? maybeFromLanguage(Object? code,
          [Iterable<Language>? subset]) =>
      _lookup(code, languageMap, subset);

  /// Returns the [ExtendedLanguage] with [code]. Throws if none matches.
  static ExtendedLanguage fromExtendedLanguage(
    Object code, [
    Iterable<ExtendedLanguage>? subset,
  ]) =>
      _orThrow(maybeFromExtendedLanguage(code, subset), 'extlang', code);

  /// Returns the [ExtendedLanguage] with [code], or `null`.
  static ExtendedLanguage? maybeFromExtendedLanguage(
    Object? code, [
    Iterable<ExtendedLanguage>? subset,
  ]) =>
      _lookup(code, extendedLanguageMap, subset);

  /// Returns the [Script] with [code]. Throws if none matches.
  static Script fromScript(Object code, [Iterable<Script>? subset]) =>
      _orThrow(maybeFromScript(code, subset), 'script', code);

  /// Returns the [Script] with [code], or `null`.
  static Script? maybeFromScript(Object? code, [Iterable<Script>? subset]) =>
      _lookup(code, scriptMap, subset);

  /// Returns the [Region] with [code]. Throws if none matches.
  static Region fromRegion(Object code, [Iterable<Region>? subset]) =>
      _orThrow(maybeFromRegion(code, subset), 'region', code);

  /// Returns the [Region] with [code], or `null`.
  static Region? maybeFromRegion(Object? code, [Iterable<Region>? subset]) =>
      _lookup(code, regionMap, subset);

  /// Returns the [Variant] with [code]. Throws if none matches.
  static Variant fromVariant(Object code, [Iterable<Variant>? subset]) =>
      _orThrow(maybeFromVariant(code, subset), 'variant', code);

  /// Returns the [Variant] with [code], or `null`.
  static Variant? maybeFromVariant(Object? code, [Iterable<Variant>? subset]) =>
      _lookup(code, variantMap, subset);

  /// Returns the [Grandfathered] tag equal to [code]. Throws if none matches.
  static Grandfathered fromGrandfathered(
    Object code, [
    Iterable<Grandfathered>? subset,
  ]) =>
      _orThrow(maybeFromGrandfathered(code, subset), 'grandfathered', code);

  /// Returns the [Grandfathered] tag equal to [code], or `null`.
  static Grandfathered? maybeFromGrandfathered(
    Object? code, [
    Iterable<Grandfathered>? subset,
  ]) =>
      _lookup(code, grandfatheredMap, subset);

  /// Returns the [Redundant] tag equal to [code]. Throws if none matches.
  static Redundant fromRedundant(Object code, [Iterable<Redundant>? subset]) =>
      _orThrow(maybeFromRedundant(code, subset), 'redundant', code);

  /// Returns the [Redundant] tag equal to [code], or `null`.
  static Redundant? maybeFromRedundant(
    Object? code, [
    Iterable<Redundant>? subset,
  ]) =>
      _lookup(code, redundantMap, subset);

  /// Returns the record whose [where] result (or `subtag`, when [where] is
  /// omitted) equals [value], searching [subtags] (defaults to [list]).
  static LanguageSubtag? maybeFromValue<T extends Object>(
    T value, {
    T? Function(LanguageSubtag subtag)? where,
    Iterable<LanguageSubtag> subtags = list,
  }) {
    for (final subtag in subtags) {
      final expected = where?.call(subtag) ?? subtag.subtag;
      if (expected == value) return subtag;
    }

    return null;
  }

  // -- Type helpers --

  /// Whether this record is a primary language subtag.
  bool get isLanguage => this is Language;

  /// Whether this record is an extended language subtag.
  bool get isExtendedLanguage => this is ExtendedLanguage;

  /// Whether this record is a script subtag.
  bool get isScript => this is Script;

  /// Whether this record is a region subtag.
  bool get isRegion => this is Region;

  /// Whether this record is a variant subtag.
  bool get isVariant => this is Variant;

  /// Whether this record is a grandfathered tag.
  bool get isGrandfathered => this is Grandfathered;

  /// Whether this record is a redundant tag.
  bool get isRedundant => this is Redundant;

  // -- Serialization --

  /// Converts this record to a JSON-encoded string.
  String toJson({JsonCodec codec = const JsonCodec()}) => codec.encode(toMap());

  /// Converts this record to a [Map].
  ///
  /// Subclasses add their type-specific fields (for example `scope`, `prefix`).
  Map<String, Object?> toMap() => {
        'type': type,
        'subtag': subtag,
        'descriptions': descriptions,
        'added': added,
        if (deprecated != null) 'deprecated': deprecated,
        if (preferredValue != null) 'preferredValue': preferredValue,
        if (comments.isNotEmpty) 'comments': comments,
      };

  /// Creates a [LanguageSubtag] from a JSON-encoded string produced by [toJson].
  static LanguageSubtag fromJson(
    String json, {
    JsonCodec codec = const JsonCodec(),
  }) =>
      fromMap(codec.decode(json) as Map<String, Object?>);

  /// Creates a [LanguageSubtag] from a [map] produced by [toMap].
  static LanguageSubtag fromMap(Map<String, Object?> map) {
    final subtag = map['subtag']! as String;

    return switch (map['type']) {
      'language' => fromLanguage(subtag),
      'extlang' => fromExtendedLanguage(subtag),
      'script' => fromScript(subtag),
      'region' => fromRegion(subtag),
      'variant' => fromVariant(subtag),
      'grandfathered' => fromGrandfathered(subtag),
      'redundant' => fromRedundant(subtag),
      final other => throw ArgumentError('Unknown subtag type: "$other"'),
    };
  }

  // -- Object overrides --

  @override
  int compareTo(LanguageSubtag other) => subtag.compareTo(other.subtag);

  /// Returns a string representation of this record.
  ///
  /// When [short] is `false`, every field (including type-specific ones) is
  /// included via [toMap].
  @override
  String toString({bool short = true}) => short
      ? '$runtimeType($subtag, $description)'
      : '$runtimeType(${toMap()})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageSubtag &&
          other.runtimeType == runtimeType &&
          other.subtag == subtag;

  @override
  int get hashCode => Object.hash(runtimeType, subtag);
}

/// A primary language subtag (registry `Type: language`), such as ISO 639 codes.
final class Language extends LanguageSubtag {
  const Language({
    required super.subtag,
    required super.descriptions,
    required super.added,
    super.deprecated,
    super.preferredValue,
    super.comments,
    this.scope,
    this.macrolanguage,
    this.suppressScript,
  });

  /// The `Scope` of the language, or `null` for an individual language.
  final LanguageScope? scope;

  /// The `Macrolanguage` this language belongs to, or `null`.
  final String? macrolanguage;

  /// The `Suppress-Script` subtag, or `null`.
  ///
  /// Identifies a script that should not be used with this language because it
  /// is already implied (for example `Latn` for English).
  final String? suppressScript;

  @override
  String get type => 'language';

  @override
  Map<String, Object?> toMap() => {
        ...super.toMap(),
        if (scope != null) 'scope': scope!.value,
        if (macrolanguage != null) 'macrolanguage': macrolanguage,
        if (suppressScript != null) 'suppressScript': suppressScript,
      };

  /// Returns a copy of this record with the given fields replaced.
  Language copyWith({
    String? subtag,
    List<String>? descriptions,
    String? added,
    String? deprecated,
    String? preferredValue,
    List<String>? comments,
    LanguageScope? scope,
    String? macrolanguage,
    String? suppressScript,
  }) =>
      Language(
        subtag: subtag ?? this.subtag,
        descriptions: descriptions ?? this.descriptions,
        added: added ?? this.added,
        deprecated: deprecated ?? this.deprecated,
        preferredValue: preferredValue ?? this.preferredValue,
        comments: comments ?? this.comments,
        scope: scope ?? this.scope,
        macrolanguage: macrolanguage ?? this.macrolanguage,
        suppressScript: suppressScript ?? this.suppressScript,
      );
}

/// An extended language subtag (registry `Type: extlang`), per RFC 5646 §3.1.3.
final class ExtendedLanguage extends LanguageSubtag {
  const ExtendedLanguage({
    required super.subtag,
    required super.descriptions,
    required super.added,
    required this.prefix,
    super.deprecated,
    super.preferredValue,
    super.comments,
    this.macrolanguage,
  });

  /// The single `Prefix` with which this extended language subtag is used.
  final String prefix;

  /// The `Macrolanguage` this extended language belongs to, or `null`.
  final String? macrolanguage;

  @override
  String get type => 'extlang';

  @override
  Map<String, Object?> toMap() => {
        ...super.toMap(),
        'prefix': prefix,
        if (macrolanguage != null) 'macrolanguage': macrolanguage,
      };

  /// Returns a copy of this record with the given fields replaced.
  ExtendedLanguage copyWith({
    String? subtag,
    List<String>? descriptions,
    String? added,
    String? prefix,
    String? deprecated,
    String? preferredValue,
    List<String>? comments,
    String? macrolanguage,
  }) =>
      ExtendedLanguage(
        subtag: subtag ?? this.subtag,
        descriptions: descriptions ?? this.descriptions,
        added: added ?? this.added,
        prefix: prefix ?? this.prefix,
        deprecated: deprecated ?? this.deprecated,
        preferredValue: preferredValue ?? this.preferredValue,
        comments: comments ?? this.comments,
        macrolanguage: macrolanguage ?? this.macrolanguage,
      );
}

/// A script subtag (registry `Type: script`), an ISO 15924 code such as `Latn`.
final class Script extends LanguageSubtag {
  const Script({
    required super.subtag,
    required super.descriptions,
    required super.added,
    super.deprecated,
    super.preferredValue,
    super.comments,
  });

  @override
  String get type => 'script';

  /// Returns a copy of this record with the given fields replaced.
  Script copyWith({
    String? subtag,
    List<String>? descriptions,
    String? added,
    String? deprecated,
    String? preferredValue,
    List<String>? comments,
  }) =>
      Script(
        subtag: subtag ?? this.subtag,
        descriptions: descriptions ?? this.descriptions,
        added: added ?? this.added,
        deprecated: deprecated ?? this.deprecated,
        preferredValue: preferredValue ?? this.preferredValue,
        comments: comments ?? this.comments,
      );
}

/// A region subtag (registry `Type: region`), an ISO 3166-1 or UN M.49 code.
final class Region extends LanguageSubtag {
  const Region({
    required super.subtag,
    required super.descriptions,
    required super.added,
    super.deprecated,
    super.preferredValue,
    super.comments,
  });

  @override
  String get type => 'region';

  /// Returns a copy of this record with the given fields replaced.
  Region copyWith({
    String? subtag,
    List<String>? descriptions,
    String? added,
    String? deprecated,
    String? preferredValue,
    List<String>? comments,
  }) =>
      Region(
        subtag: subtag ?? this.subtag,
        descriptions: descriptions ?? this.descriptions,
        added: added ?? this.added,
        deprecated: deprecated ?? this.deprecated,
        preferredValue: preferredValue ?? this.preferredValue,
        comments: comments ?? this.comments,
      );
}

/// A variant subtag (registry `Type: variant`), per RFC 5646 §3.1.4.
final class Variant extends LanguageSubtag {
  const Variant({
    required super.subtag,
    required super.descriptions,
    required super.added,
    this.prefixes = const [],
    super.deprecated,
    super.preferredValue,
    super.comments,
  });

  /// Every `Prefix` with which this variant is appropriately used.
  final List<String> prefixes;

  @override
  String get type => 'variant';

  @override
  Map<String, Object?> toMap() => {
        ...super.toMap(),
        if (prefixes.isNotEmpty) 'prefixes': prefixes,
      };

  /// Returns a copy of this record with the given fields replaced.
  Variant copyWith({
    String? subtag,
    List<String>? descriptions,
    String? added,
    List<String>? prefixes,
    String? deprecated,
    String? preferredValue,
    List<String>? comments,
  }) =>
      Variant(
        subtag: subtag ?? this.subtag,
        descriptions: descriptions ?? this.descriptions,
        added: added ?? this.added,
        prefixes: prefixes ?? this.prefixes,
        deprecated: deprecated ?? this.deprecated,
        preferredValue: preferredValue ?? this.preferredValue,
        comments: comments ?? this.comments,
      );
}

/// A grandfathered tag (registry `Type: grandfathered`), a whole tag registered
/// before RFC 5646 that does not fit the current syntax.
final class Grandfathered extends LanguageSubtag {
  const Grandfathered({
    required super.subtag,
    required super.descriptions,
    required super.added,
    super.deprecated,
    super.preferredValue,
    super.comments,
  });

  @override
  String get type => 'grandfathered';

  /// Returns a copy of this record with the given fields replaced.
  Grandfathered copyWith({
    String? subtag,
    List<String>? descriptions,
    String? added,
    String? deprecated,
    String? preferredValue,
    List<String>? comments,
  }) =>
      Grandfathered(
        subtag: subtag ?? this.subtag,
        descriptions: descriptions ?? this.descriptions,
        added: added ?? this.added,
        deprecated: deprecated ?? this.deprecated,
        preferredValue: preferredValue ?? this.preferredValue,
        comments: comments ?? this.comments,
      );
}

/// A redundant tag (registry `Type: redundant`), a whole tag that can now be
/// composed from other subtags.
final class Redundant extends LanguageSubtag {
  const Redundant({
    required super.subtag,
    required super.descriptions,
    required super.added,
    super.deprecated,
    super.preferredValue,
    super.comments,
  });

  @override
  String get type => 'redundant';

  /// Returns a copy of this record with the given fields replaced.
  Redundant copyWith({
    String? subtag,
    List<String>? descriptions,
    String? added,
    String? deprecated,
    String? preferredValue,
    List<String>? comments,
  }) =>
      Redundant(
        subtag: subtag ?? this.subtag,
        descriptions: descriptions ?? this.descriptions,
        added: added ?? this.added,
        deprecated: deprecated ?? this.deprecated,
        preferredValue: preferredValue ?? this.preferredValue,
        comments: comments ?? this.comments,
      );
}
