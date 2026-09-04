# sealed_language_extensions

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A pure Dart package that provides the
[IANA Language Tag Extensions Registry](https://www.iana.org/assignments/language-tag-extensions-registry/language-tag-extensions-registry)
(BCP 47 / RFC 5646 §3.7) as compile-time constant, tree-shakable, **sealed**
classes.

The data is regenerated automatically from the canonical IANA source.

## Features

- Every registered extension as a `const` instance (currently `t` and `u`).
- A sealed [`LanguageTagExtension`] hierarchy with one concrete subclass per
  extension, enabling exhaustive `switch` matching.
- Static entry points on `LanguageTagExtension`: `list`, `map`,
  `fromIdentifier`/`maybeFromIdentifier` (accepting any `Object` and an optional
  subset), `maybeFromValue`, a verbose `toString({bool short})`, and
  `toMap`/`toJson`/`fromJson` — mirroring the `sealed_regions`/`sealed_languages`
  API.
- Case-insensitive lookup by identifier.
- No third-party dependencies.

## Usage

```dart
import 'package:sealed_language_extensions/sealed_language_extensions.dart';

void main() {
  for (final extension in LanguageTagExtension.list) {
    print('${extension.identifier}: ${extension.description}');
  }

  // Case-insensitive lookup (nullable and throwing variants).
  final unicode = LanguageTagExtension.maybeFromIdentifier('U');
  print(unicode?.description); // Unicode Locale
  final transformed = LanguageTagExtension.fromIdentifier('t');

  // Exhaustive pattern matching over the sealed hierarchy.
  final label = switch (transformed) {
    SpecifyingTransformedContentExtension() => 'transform',
    UnicodeLocaleExtension() => 'locale',
  };
  print(label); // transform
}
```

## Versioning

This package uses a hybrid SemVer/CalVer scheme: `1.<yyyy><mm>.<d>`, derived from
the registry's `File-Date` (the date IANA published the data). For example, the
extensions registry dated 2014-04-02 is published as `1.201404.2`.

## Data source & license

The package code is © 2026 TigerC10, released under the MIT license (see
`LICENSE`). The embedded data is sourced from the public IANA registry and
remains subject to its terms.
