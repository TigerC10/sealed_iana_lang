import 'dart:io';

import 'dart_code.dart';
import 'registry_parser.dart';
import 'registry_source.dart';

/// Generates the `sealed_language_extensions` package data from the cached
/// extensions registry.
class ExtensionGenerator {
  const ExtensionGenerator({required this.outputFile});

  /// The `lib/src/extensions.g.dart` part file of the extensions package.
  final String outputFile;

  void generate(ParsedRegistry registry) {
    final header = generatedHeader(
      source: RegistrySource.extensions.url,
      fileDate: registry.fileDate,
    );

    final buffer = StringBuffer()
      ..writeln(header)
      ..writeln("part of 'language_tag_extension.dart';")
      ..writeln();

    final classNames = <String>[];
    for (final record in registry.records) {
      final className = _className(record.first('Description')!);
      classNames.add(className);
      _writeClass(buffer, className, record);
    }

    buffer
      ..writeln(
          '/// Every registered language tag extension, in registry order.')
      ..writeln('const List<LanguageTagExtension> languageTagExtensions = [');
    for (final className in classNames) {
      buffer.writeln('  $className(),');
    }
    buffer
      ..writeln('];')
      ..writeln()
      ..writeln('/// The `File-Date` of the source registry.')
      ..writeln(
          'const String registryFileDate = ${dartString(registry.fileDate)};');

    File(outputFile).writeAsStringSync(buffer.toString());
    stdout.writeln('Generated extensions: ${classNames.length} records.');
  }

  void _writeClass(
    StringBuffer buffer,
    String className,
    RegistryRecord record,
  ) {
    final identifier = record.first('Identifier')!;
    final description = record.first('Description')!;

    buffer
      ..writeln('/// The `$identifier` extension: $description.')
      ..writeln('final class $className extends LanguageTagExtension {')
      ..writeln('  const $className()')
      ..writeln('      : super(')
      ..writeln('          identifier: ${dartString(identifier)},')
      ..writeln('          description: ${dartString(description)},')
      ..writeln('          added: ${dartString(record.first('Added')!)},')
      ..writeln('          rfc: ${dartString(record.first('RFC')!)},')
      ..writeln(
          '          authority: ${dartString(record.first('Authority')!)},')
      ..writeln(
          '          contactEmail: ${dartString(record.first('Contact_Email')!)},')
      ..writeln(
          '          mailingList: ${dartString(record.first('Mailing_List')!)},')
      ..writeln('          url: ${dartString(record.first('URL')!)},');

    final comments = record.all('Comments');
    if (comments.isNotEmpty) {
      buffer.writeln('          comments: const ${dartStringList(comments)},');
    }

    buffer
      ..writeln('        );')
      ..writeln('}')
      ..writeln();
  }

  /// Derives a deterministic PascalCase class name from a description, so new
  /// registry identifiers generate valid classes without manual work.
  String _className(String description) {
    final words = description
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1));
    final name = words.join();

    return '${name}Extension';
  }
}
