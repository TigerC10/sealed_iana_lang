# sealed_iana_lang

A fully automated Dart monorepo that turns the canonical
[IANA](https://www.iana.org/) language registries into compile-time constant,
tree-shakable, **sealed** Dart classes.

| Package                                                             | Source registry                                                                                                                                          |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`sealed_language_subtags`](packages/sealed_language_subtags)       | [Language Subtag Registry](https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry) (BCP 47 / RFC 5646)                       |
| [`sealed_language_extensions`](packages/sealed_language_extensions) | [Language Tag Extensions Registry](https://www.iana.org/assignments/language-tag-extensions-registry/language-tag-extensions-registry) (RFC 6497 / 6067) |

## How the automation works

1. **Download** — `dart run generator:download` fetches both registries into
   `tool/generator/data/` and reports whether anything changed.
2. **Generate** — `dart run generator:generate` clears the previously generated
   sources and regenerates each package from the cached registry files.
3. **Version** — `dart run generator:version <package> --write` stamps the
   affected package's `pubspec.yaml` and `CHANGELOG.md` with a hybrid
   SemVer/CalVer version derived from the registry's `File-Date` (idempotent).

A daily [GitHub Actions workflow](.github/workflows/update-registries.yaml) runs
these steps, and opens a release commit only when the registries change.

## Versioning scheme

Both packages are versioned as `1.<yyyy><mm>.<d>`, derived from the `File-Date`
of the IANA registry the package is generated from (the date IANA published the
data), with the day (patch) carrying no leading zero. For example, the
extensions registry dated 2014-04-02 is published as `1.201404.2`, and the
subtag registry dated 2026-08-08 as `1.202608.8`. The major stays at `1` while
the public API is stable, and an unchanged registry always yields the same
version.

## Repository layout

```
packages/
  sealed_language_subtags/      # published package
  sealed_language_extensions/   # published package
tool/generator/                 # internal download + codegen tool (not published)
  bin/download.dart
  bin/generate.dart
  bin/version.dart
  data/                         # committed copies of the raw registries
.github/workflows/              # daily automation
```

## Local development

```bash
dart pub get                 # resolve the pub workspace
dart run generator:download  # refresh cached registries (optional)
dart run generator:generate  # regenerate sources
dart analyze packages
dart test packages/sealed_language_subtags packages/sealed_language_extensions
```

## License

The package code is © 2026 TigerC10, released under the MIT license (see
[LICENSE](LICENSE)). The embedded data is sourced from the public IANA
registries and remains subject to their terms.
