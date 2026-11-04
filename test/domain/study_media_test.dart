import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_media.dart';
import 'package:politico/domain/models/study_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late List<Map<String, Object?>> rows;
  setUpAll(() async {
    data = await AppData.load();
    final Map<String, Object?> json = jsonDecode(
      await rootBundle.loadString('assets/data/study_media.json'),
    ) as Map<String, Object?>;
    rows = <Map<String, Object?>>[
      for (final Object? value in json['portraits']! as List<Object?>)
        value! as Map<String, Object?>,
    ];
  });

  test('cada retrato pertence a uma personalidade existente do catálogo final', () {
    final catalog = StudyCatalog(data);
    for(final key in data.portraits.keys) {
      final subject = catalog.find(key);
      expect(subject, isNotNull, reason: key);
      expect(subject!.kind, 'personality', reason: key);
    }
  });

  test('manifesto e AppData preservam atribuição, licença HTTPS e fonte Commons por retrato', () {
    expect(rows, isNotEmpty);
    expect(data.portraits.length, rows.length);
    expect(rows.map((row) => row['key']).toSet().length, rows.length);
    for (final Map<String, Object?> row in rows) {
      final String key = row['key']! as String;
      final StudyPortrait portrait = data.portraits[key]!;
      expect(portrait.assetPath, row['assetPath'], reason: key);
      expect(portrait.author.trim(), isNotEmpty, reason: key);
      expect(portrait.caption.trim(), isNotEmpty, reason: key);
      expect(portrait.licenseName.trim(), isNotEmpty, reason: key);
      expect(portrait.changes.trim(), isNotEmpty, reason: key);
      expect(DateTime.tryParse(portrait.verifiedOn), isNotNull, reason: key);
      expect(portrait.sha256, matches(RegExp(r'^[a-f0-9]{64}$')), reason: key);
      final Uri source = Uri.parse(portrait.sourceUrl);
      final Uri license = Uri.parse(portrait.licenseUrl);
      expect(source.scheme, 'https', reason: key);
      expect(source.host, 'commons.wikimedia.org', reason: key);
      expect(source.path, startsWith('/wiki/File:'), reason: key);
      expect(source.userInfo, isEmpty, reason: key);
      expect(license.scheme, 'https', reason: key);
      expect(license.host, isNotEmpty, reason: key);
      expect(license.userInfo, isEmpty, reason: key);
    }
    expect(() => data.portraits.clear(), throwsUnsupportedError);
  });

  test('todos os retratos embarcados carregam bytes declarados e decodificam como imagem real', () async {
    for (final Map<String, Object?> row in rows) {
      final String path = row['assetPath']! as String;
      final ByteData bytes = await rootBundle.load(path);
      expect(bytes.lengthInBytes, row['bytes'], reason: path);
      expect(bytes.lengthInBytes, greaterThan(100), reason: path);
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0), reason: path);
      expect(frame.image.height, greaterThan(0), reason: path);
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('caminhos externos, traversal, extensões ativas e nomes excessivos são rejeitados', () {
    for (final String path in <String>[
      '../private.jpg',
      'assets/portraits/../private.jpg',
      'assets/portraits/a.svg',
      'assets/portraits/a.html',
      'assets/portraits/a.jpg?remote=true',
      'https://example.test/a.jpg',
      '/assets/portraits/a.jpg',
      'assets/portraits/A.jpg',
      'assets/portraits/${'a' * 1000}.jpg',
    ]) {
      expect(
        () => StudyPortrait.fromJson(<String, Object?>{
          ...rows.first,
          'assetPath': path,
        }),
        throwsFormatException,
        reason: path.substring(0, path.length.clamp(0, 80)),
      );
    }
  });

  test(
    'proveniência recusa esquemas ativos, host ausente e credenciais embutidas',
    () {
      for (final (String, String) invalid in <(String, String)>[
        ('sourceUrl', 'javascript:alert(1)'),
        ('sourceUrl', 'https://example.test/a.jpg'),
        ('sourceUrl', 'http://commons.wikimedia.org/wiki/File:Example.jpg'),
        (
          'sourceUrl',
          'https://user:password@commons.wikimedia.org/wiki/File:Example.jpg',
        ),
        ('licenseUrl', 'javascript:alert(1)'),
        ('licenseUrl', 'https:/missing-host'),
        (
          'licenseUrl',
          'https://user:password@creativecommons.org/licenses/by-sa/4.0/',
        ),
      ]) {
        expect(
          () => StudyPortrait.fromJson(<String, Object?>{
            ...rows.first,
            invalid.$1: invalid.$2,
          }),
          throwsFormatException,
          reason: invalid.toString(),
        );
      }
    },
  );

  test('metadados de autor são texto literal, sem interpretação de HTML', () {
    const String author =
        '<img src="x" onerror="alert(1)"> Autor & colaborador';
    final StudyPortrait portrait = StudyPortrait.fromJson(<String, Object?>{
      ...rows.first,
      'author': author,
    });
    expect(portrait.author, author);
  });
}
