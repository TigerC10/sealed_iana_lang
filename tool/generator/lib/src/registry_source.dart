import 'dart:io';

import 'package:http/http.dart' as http;

/// Canonical IANA registry download locations and local cache paths.
class RegistrySource {
  const RegistrySource({
    required this.name,
    required this.url,
    required this.cachePath,
  });

  /// Human-readable identifier used in logs.
  final String name;

  /// The IANA URL to download the registry from.
  final String url;

  /// Repo-relative path where the raw registry is cached/committed.
  final String cachePath;

  static const subtags = RegistrySource(
    name: 'language-subtag-registry',
    url: 'https://www.iana.org/assignments/language-subtag-registry/'
        'language-subtag-registry',
    cachePath: 'tool/generator/data/language-subtag-registry.txt',
  );

  static const extensions = RegistrySource(
    name: 'language-tag-extensions-registry',
    url: 'https://www.iana.org/assignments/language-tag-extensions-registry/'
        'language-tag-extensions-registry',
    cachePath: 'tool/generator/data/language-tag-extensions-registry.txt',
  );

  static const all = [subtags, extensions];
}

/// Associates a published package with the registry it is generated from.
class RegistryPackage {
  const RegistryPackage({
    required this.name,
    required this.source,
    required this.pubspecPath,
    required this.changelogPath,
    required this.changelogNote,
  });

  /// The package name (and directory under `packages/`).
  final String name;

  /// The registry this package's data and version are derived from.
  final RegistrySource source;

  /// Repo-relative path to the package's `pubspec.yaml`.
  final String pubspecPath;

  /// Repo-relative path to the package's `CHANGELOG.md`.
  final String changelogPath;

  /// The changelog note recorded for each regenerated release.
  final String changelogNote;

  static const subtags = RegistryPackage(
    name: 'sealed_language_subtags',
    source: RegistrySource.subtags,
    pubspecPath: 'packages/sealed_language_subtags/pubspec.yaml',
    changelogPath: 'packages/sealed_language_subtags/CHANGELOG.md',
    changelogNote: 'Regenerated from the IANA Language Subtag Registry.',
  );

  static const extensions = RegistryPackage(
    name: 'sealed_language_extensions',
    source: RegistrySource.extensions,
    pubspecPath: 'packages/sealed_language_extensions/pubspec.yaml',
    changelogPath: 'packages/sealed_language_extensions/CHANGELOG.md',
    changelogNote:
        'Regenerated from the IANA Language Tag Extensions Registry.',
  );

  static const all = [subtags, extensions];
}

/// Downloads [source] and returns its body as text.
Future<String> downloadRegistry(RegistrySource source) async {
  final response = await http.get(Uri.parse(source.url));
  if (response.statusCode != 200) {
    throw HttpException(
      'Failed to download ${source.name}: HTTP ${response.statusCode}',
      uri: Uri.parse(source.url),
    );
  }

  return response.body;
}
