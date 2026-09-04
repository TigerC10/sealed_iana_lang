# sealed_language_subtags

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A pure Dart package that provides the complete
[IANA Language Subtag Registry](https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry)
(BCP 47 / RFC 5646) as compile-time constant, tree-shakable, **sealed** classes.

The data is regenerated automatically from the canonical IANA source, so it is
always current.

## Features

- Every registry record as a `const` instance: languages, extended languages,
  scripts, regions, variants, grandfathered and redundant tags.
- A sealed [`LanguageSubtag`] hierarchy enabling exhaustive `switch` matching
  over the registry `Type`.
- Static entry points on `LanguageSubtag`: `list`, per-type lists and `…Map`s,
  `from…`/`maybeFrom…` lookups (accepting any `Object` code and an optional
  subset), `maybeFromValue`, `is…` type helpers, `copyWith`, a verbose
  `toString({bool short})`, and `toMap`/`toJson`/`fromJson` — mirroring the
  `sealed_regions`/`sealed_languages` API.
- Case-insensitive lookups per type (BCP 47 comparison rules).
- No third-party dependencies.

| Subclass           | Registry `Type` | Extra fields                               |
| ------------------ | --------------- | ------------------------------------------ |
| `Language`         | `language`      | `scope`, `macrolanguage`, `suppressScript` |
| `ExtendedLanguage` | `extlang`       | `prefix`, `macrolanguage`                  |
| `Script`           | `script`        | —                                          |
| `Region`           | `region`        | —                                          |
| `Variant`          | `variant`       | `prefixes`                                 |
| `Grandfathered`    | `grandfathered` | (`subtag` holds the whole tag)             |
| `Redundant`        | `redundant`     | (`subtag` holds the whole tag)             |

Common fields on every record: `subtag`, `descriptions`, `added`,
`deprecated`, `preferredValue`, `comments`.

## Usage

```dart
import 'package:sealed_language_subtags/sealed_language_subtags.dart';

void main() {
  // Case-insensitive lookup (nullable and throwing variants).
  final english = LanguageSubtag.maybeFromLanguage('en');
  print(english?.description); // English
  print(english?.suppressScript); // Latn

  // Exhaustive pattern matching over the sealed hierarchy.
  final LanguageSubtag subtag = LanguageSubtag.fromScript('Latn');
  final label = switch (subtag) {
    Language(:final description) => 'Language: $description',
    ExtendedLanguage(:final description) => 'Ext. language: $description',
    Script(:final description) => 'Script: $description',
    Region(:final description) => 'Region: $description',
    Variant(:final description) => 'Variant: $description',
    Grandfathered(:final description) => 'Grandfathered: $description',
    Redundant(:final description) => 'Redundant: $description',
  };
  print(label); // Script: Latin

  // All records, and per-type lists.
  print(LanguageSubtag.list.length);
  print(LanguageSubtag.languages.length);
}
```

## Versioning

This package uses a hybrid SemVer/CalVer scheme: `1.<yyyy><mm>.<d>`, derived from
the registry's `File-Date` (the date IANA published the data). For example, the
subtag registry dated 2026-08-08 is published as `1.202608.8`. The major version
stays at `1` while the API is stable, and the day (patch) has no leading zero.

## Data source & license

The package code is © 2026 TigerC10, released under the MIT license (see
`LICENSE`). The embedded data is sourced from the public IANA registry and
remains subject to its terms.
