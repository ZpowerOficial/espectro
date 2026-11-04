import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/domain/models/study_sources.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StudyCatalog catalog;
  setUpAll(() async {
    catalog = StudyCatalog(await AppData.load());
  });

  test('curated readings reference existing keys across currents, authors and books', () {
    final keys = studySources.expand((source) => source.keys).toSet();
    for (final key in keys) {
      expect(catalog.find(key), isNotNull, reason: key);
      expect(sourcesForStudy(key), isNotEmpty);
    }
    expect(
      keys.where((key) => key.startsWith('current:')).length,
      greaterThanOrEqualTo(12),
    );
    expect(
      keys.where((key) => key.startsWith('personality:')).length,
      greaterThanOrEqualTo(10),
    );
    expect(
      keys.where((key) => key.startsWith('book:')).length,
      greaterThanOrEqualTo(10),
    );
    expect(sourcesForStudy('unknown:missing'), isEmpty);
  });

  test('reading evidence never claims numerical calibration is justified', () {
    for (final source in studySources) {
      expect(source.relation, 'Leitura primária');
      expect(source.note, isNotEmpty);
      expect(source.verifiedOn, matches(RegExp(r'^2026-11-0[34]$')));
      final url = Uri.parse(source.url);
      expect(url.scheme, 'https');
      expect(url.host, isNotEmpty);
      expect(url.userInfo, isEmpty);
    }
    for (final key in catalog.subjects.map((s) => s.key)) {
      final evidence = evidenceForStudy(key);
      expect(evidence.coordinatesJustified, isFalse);
      expect(evidence.coordinateNote, contains('Não justificam'));
      expect(evidence.coordinateNote, contains('continua pendente'));
    }
  });

  test(
    'reading lists have no duplicate URLs and cannot mutate the curation',
    () {
      expect(
        studySources.map((s) => s.url).toSet().length,
        studySources.length,
      );
      final readings = sourcesForStudy('current:liberalismo_classico');
      expect(readings, hasLength(2));
      expect(() => readings.clear(), throwsUnsupportedError);
    },
  );
}
