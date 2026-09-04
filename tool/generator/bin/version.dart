import 'dart:io';

import 'package:generator/src/registry_parser.dart';
import 'package:generator/src/registry_source.dart';

/// Computes the hybrid semver/calver version `1.<yyyy><mm>.<d>` for a package
/// from the `File-Date` of the registry it is generated from, and optionally
/// writes it into the package's `pubspec.yaml` and `CHANGELOG.md`.
///
/// The version therefore tracks when IANA published the data, not when the
/// generator ran, so an unchanged registry always yields the same version.
/// The day (patch) component has no leading zero, e.g. a registry dated
/// 2014-04-02 becomes `1.201404.2`.
///
/// Usage (run from the repository root):
///   dart run generator:version                       # print every version
///   dart run generator:version <package>             # print one version
///   dart run generator:version <package> --write     # update pubspec+changelog
void main(List<String> args) {
  final write = args.contains('--write');
  final names = args.where((arg) => !arg.startsWith('--')).toList();

  final packages =
      names.isEmpty ? RegistryPackage.all : names.map(_packageByName).toList();

  for (final package in packages) {
    final source = File(package.source.cachePath);
    if (!source.existsSync()) {
      throw StateError(
        'Missing ${source.path}. Run `dart run generator:download` first.',
      );
    }

    final registry = parseRegistry(source.readAsStringSync());
    final version = calverVersion(registry.fileDate);

    if (write) {
      final pubspec = File(package.pubspecPath);
      pubspec.writeAsStringSync(
        _replaceVersion(pubspec.readAsStringSync(), version),
      );
      stderr.writeln('Set ${package.pubspecPath} to $version');

      if (_updateChangelog(package, version, registry.fileDate)) {
        stderr.writeln('Added $version to ${package.changelogPath}');
      }
    }

    stdout.writeln(version);
  }
}

/// Ensures [package]'s changelog has an entry for [version], inserting one dated
/// [fileDate] when absent. Returns whether the file was modified (idempotent).
bool _updateChangelog(
    RegistryPackage package, String version, String fileDate) {
  final file = File(package.changelogPath);
  final content = file.existsSync() ? file.readAsStringSync() : '# Changelog\n';

  // Already documented: nothing to do.
  if (RegExp('^## ${RegExp.escape(version)}(\\s|\$)', multiLine: true)
      .hasMatch(content)) {
    return false;
  }

  final entry = '## $version - $fileDate\n\n- ${package.changelogNote}\n';
  final firstHeading = RegExp(r'^## ', multiLine: true).firstMatch(content);
  final updated = firstHeading == null
      // No existing release: append after the preamble.
      ? '${content.trimRight()}\n\n$entry'
      // Insert above the newest existing release.
      : content.replaceRange(
          firstHeading.start,
          firstHeading.start,
          '$entry\n',
        );

  file.writeAsStringSync(updated);

  return true;
}

/// Returns `1.<yyyy><mm>.<d>` for an ISO `yyyy-mm-dd` [fileDate] (day without a
/// leading zero, month zero-padded).
String calverVersion(String fileDate) {
  final parts = fileDate.split('-');
  if (parts.length != 3) {
    throw FormatException('Invalid registry File-Date: "$fileDate"');
  }

  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]).toString().padLeft(2, '0');
  final day = int.parse(parts[2]);

  return '1.$year$month.$day';
}

RegistryPackage _packageByName(String name) => RegistryPackage.all.firstWhere(
      (package) => package.name == name,
      orElse: () => throw ArgumentError('Unknown package: "$name"'),
    );

String _replaceVersion(String pubspec, String version) {
  final pattern = RegExp(r'^version:.*$', multiLine: true);
  if (!pattern.hasMatch(pubspec)) {
    throw StateError('No `version:` field found to update.');
  }

  return pubspec.replaceFirst(pattern, 'version: $version');
}
