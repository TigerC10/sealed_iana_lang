import 'dart:io';

import 'package:generator/src/registry_source.dart';

/// Downloads the IANA registries into their committed cache files.
///
/// Prints `changed` when at least one registry differs from the cached copy,
/// otherwise prints `unchanged`. The exit code is always 0 on success so the
/// CI workflow can branch on stdout.
///
/// Run from the repository root: `dart run generator:download`.
Future<void> main(List<String> args) async {
  var anyChanged = false;

  for (final source in RegistrySource.all) {
    stdout.writeln('Downloading ${source.name}...');
    final body = await downloadRegistry(source);

    final file = File(source.cachePath);
    final previous = file.existsSync() ? file.readAsStringSync() : null;

    if (previous == body) {
      stdout.writeln('  ${source.name}: unchanged');
      continue;
    }

    file.parent.createSync(recursive: true);
    file.writeAsStringSync(body);
    stdout.writeln('  ${source.name}: updated (${body.length} bytes)');
    anyChanged = true;
  }

  stdout.writeln(anyChanged ? 'changed' : 'unchanged');
}
