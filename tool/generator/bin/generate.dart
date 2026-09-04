import 'dart:io';

import 'package:generator/src/extension_generator.dart';
import 'package:generator/src/registry_parser.dart';
import 'package:generator/src/registry_source.dart';
import 'package:generator/src/subtag_generator.dart';

const _subtagsGeneratedDir =
    'packages/sealed_language_subtags/lib/src/generated';
const _extensionsGeneratedFile =
    'packages/sealed_language_extensions/lib/src/extensions.g.dart';

/// Clears previously generated sources and regenerates both packages from the
/// cached registry files. Run from the repository root:
/// `dart run generator:generate`.
void main(List<String> args) {
  _generateSubtags();
  _generateExtensions();
  _format();
  stdout.writeln('Done.');
}

/// Formats the generated sources so committed output matches a fresh run.
void _format() {
  final result = Process.runSync('dart', [
    'format',
    _subtagsGeneratedDir,
    _extensionsGeneratedFile,
  ]);
  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    throw StateError('dart format failed (${result.exitCode}).');
  }
}

void _generateSubtags() {
  final source = File(RegistrySource.subtags.cachePath);
  if (!source.existsSync()) {
    throw StateError(
      'Missing ${source.path}. Run `dart run generator:download` first.',
    );
  }

  // Clear generated files before regenerating.
  final dir = Directory(_subtagsGeneratedDir);
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);

  final registry = parseRegistry(source.readAsStringSync());
  const SubtagGenerator(outputDir: _subtagsGeneratedDir).generate(registry);
}

void _generateExtensions() {
  final source = File(RegistrySource.extensions.cachePath);
  if (!source.existsSync()) {
    throw StateError(
      'Missing ${source.path}. Run `dart run generator:download` first.',
    );
  }

  final output = File(_extensionsGeneratedFile);
  if (output.existsSync()) output.deleteSync();
  output.parent.createSync(recursive: true);

  final registry = parseRegistry(source.readAsStringSync());
  ExtensionGenerator(outputFile: output.path).generate(registry);
}
