import 'dart:io';

import 'dart_code.dart';
import 'registry_parser.dart';
import 'registry_source.dart';

/// Generates the `sealed_language_subtags` package data from the cached
/// subtag registry.
class SubtagGenerator {
  const SubtagGenerator({required this.outputDir});

  /// The `lib/src/generated` directory of the subtags package.
  final String outputDir;

  static const _scopeNames = {
    'macrolanguage': 'LanguageScope.macrolanguage',
    'collection': 'LanguageScope.collection',
    'special': 'LanguageScope.special',
    'private-use': 'LanguageScope.privateUse',
  };

  void generate(ParsedRegistry registry) {
    final byType = <String, List<RegistryRecord>>{};
    for (final record in registry.records) {
      final type = record.first('Type');
      if (type == null) continue;
      (byType[type] ??= []).add(record);
    }

    final header = generatedHeader(
      source: RegistrySource.subtags.url,
      fileDate: registry.fileDate,
    );

    _writeFile('languages.g.dart', header, 'Language', 'languages',
        byType['language'] ?? const [], _language);
    _writeFile('extended_languages.g.dart', header, 'ExtendedLanguage',
        'extendedLanguages', byType['extlang'] ?? const [], _extlang);
    _writeFile('scripts.g.dart', header, 'Script', 'scripts',
        byType['script'] ?? const [], _simple);
    _writeFile('regions.g.dart', header, 'Region', 'regions',
        byType['region'] ?? const [], _simple);
    _writeFile('variants.g.dart', header, 'Variant', 'variants',
        byType['variant'] ?? const [], _variant);
    _writeFile('grandfathered_tags.g.dart', header, 'Grandfathered',
        'grandfatheredTags', byType['grandfathered'] ?? const [], _tag);
    _writeFile('redundant_tags.g.dart', header, 'Redundant', 'redundantTags',
        byType['redundant'] ?? const [], _tag);

    _writeBarrel(header, registry.fileDate);

    stdout.writeln('Generated subtags: '
        '${byType['language']?.length ?? 0} languages, '
        '${byType['extlang']?.length ?? 0} extlangs, '
        '${byType['script']?.length ?? 0} scripts, '
        '${byType['region']?.length ?? 0} regions, '
        '${byType['variant']?.length ?? 0} variants, '
        '${byType['grandfathered']?.length ?? 0} grandfathered, '
        '${byType['redundant']?.length ?? 0} redundant.');
  }

  void _writeFile(
    String fileName,
    String header,
    String className,
    String listName,
    List<RegistryRecord> records,
    String Function(RegistryRecord) toCtor,
  ) {
    final buffer = StringBuffer()
      ..writeln(header)
      ..writeln("part of 'subtags.g.dart';")
      ..writeln()
      ..writeln('const List<$className> $listName = [');
    for (final record in records) {
      buffer.writeln('  ${toCtor(record)},');
    }
    buffer.writeln('];');

    File('$outputDir/$fileName').writeAsStringSync(buffer.toString());
  }

  void _writeBarrel(String header, String fileDate) {
    const parts = [
      'languages.g.dart',
      'extended_languages.g.dart',
      'scripts.g.dart',
      'regions.g.dart',
      'variants.g.dart',
      'grandfathered_tags.g.dart',
      'redundant_tags.g.dart',
    ];
    final buffer = StringBuffer()
      ..writeln(header)
      ..writeln("import '../model/language_scope.dart';")
      ..writeln("import '../model/language_subtag.dart';")
      ..writeln();
    for (final part in parts) {
      buffer.writeln("part '$part';");
    }
    buffer
      ..writeln()
      ..writeln('/// The `File-Date` of the source registry.')
      ..writeln('const String registryFileDate = ${dartString(fileDate)};');

    File('$outputDir/subtags.g.dart').writeAsStringSync(buffer.toString());
  }

  /// Emits the constructor arguments shared by every subtag record.
  void _common(RegistryRecord record, StringBuffer args,
      {String key = 'Subtag'}) {
    args.write('subtag: ${dartString(record.first(key)!)}, ');
    args.write('descriptions: ${dartStringList(record.all('Description'))}, ');
    args.write('added: ${dartString(record.first('Added')!)}');

    final deprecated = record.first('Deprecated');
    if (deprecated != null) {
      args.write(', deprecated: ${dartString(deprecated)}');
    }

    final preferred = record.first('Preferred-Value');
    if (preferred != null) {
      args.write(', preferredValue: ${dartString(preferred)}');
    }

    final comments = record.all('Comments');
    if (comments.isNotEmpty) {
      args.write(', comments: ${dartStringList(comments)}');
    }
  }

  String _simple(RegistryRecord record) {
    final args = StringBuffer();
    _common(record, args);

    return switch (record.first('Type')) {
      'script' => 'Script($args)',
      'region' => 'Region($args)',
      _ => throw StateError('Unexpected type ${record.first('Type')}'),
    };
  }

  String _language(RegistryRecord record) {
    final args = StringBuffer();
    _common(record, args);

    final scope = record.first('Scope');
    if (scope != null) {
      final name = _scopeNames[scope];
      if (name == null) throw StateError('Unknown Scope: $scope');
      args.write(', scope: $name');
    }

    final macro = record.first('Macrolanguage');
    if (macro != null) args.write(', macrolanguage: ${dartString(macro)}');

    final suppress = record.first('Suppress-Script');
    if (suppress != null) {
      args.write(', suppressScript: ${dartString(suppress)}');
    }

    return 'Language($args)';
  }

  String _extlang(RegistryRecord record) {
    final args = StringBuffer();
    _common(record, args);
    args.write(', prefix: ${dartString(record.first('Prefix')!)}');

    final macro = record.first('Macrolanguage');
    if (macro != null) args.write(', macrolanguage: ${dartString(macro)}');

    return 'ExtendedLanguage($args)';
  }

  String _variant(RegistryRecord record) {
    final args = StringBuffer();
    _common(record, args);

    final prefixes = record.all('Prefix');
    if (prefixes.isNotEmpty) {
      args.write(', prefixes: ${dartStringList(prefixes)}');
    }

    return 'Variant($args)';
  }

  String _tag(RegistryRecord record) {
    final args = StringBuffer();
    _common(record, args, key: 'Tag');

    return switch (record.first('Type')) {
      'grandfathered' => 'Grandfathered($args)',
      'redundant' => 'Redundant($args)',
      _ => throw StateError('Unexpected type ${record.first('Type')}'),
    };
  }
}
