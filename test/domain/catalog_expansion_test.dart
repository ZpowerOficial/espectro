import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/domain/models/study_relations.dart';
import 'package:politico/domain/models/study_sources.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late StudyCatalog catalog;
  late Map<String, dynamic> rawCurrents;
  late Map<String, dynamic> rawPeople;
  setUpAll(() async {
    data = await AppData.load();
    catalog = StudyCatalog(data);
    rawCurrents = jsonDecode(
      await rootBundle.loadString('assets/data/ideological_currents.json'),
    ) as Map<String, dynamic>;
    rawPeople = jsonDecode(
      await rootBundle.loadString('assets/data/personalities.json'),
    ) as Map<String, dynamic>;
  });

  test('40 distinct currents and 40 absent personalities expand the native catalog', () {
    expect(data.catalog.currents.length, greaterThanOrEqualTo(124));
    expect(data.atlas.personalities.length, greaterThanOrEqualTo(124));
    expect(data.atlas.books.length, greaterThanOrEqualTo(80));
    expect(
      data.catalog.currents.map((c) => c.id).toSet().length,
      data.catalog.currents.length,
    );
    expect(
      data.atlas.personalities.map((p) => p.id).toSet().length,
      data.atlas.personalities.length,
    );
    for (final key in [
      'current:comunismo',
      'current:socialismo_marxista',
      'current:luxemburguismo',
      'current:marxismo_ocidental',
      'current:comunismo_de_esquerda',
      'current:anarcocomunismo',
      'personality:murray_rothbard',
      'personality:hans_hermann_hoppe',
      'personality:ludwig_von_mises',
      'personality:friedrich_engels',
      'personality:alexandra_kollontai',
      'personality:william_godwin',
    ]) {
      expect(catalog.find(key), isNotNull, reason: key);
      expect(sourcesForStudy(key), isNotEmpty, reason: key);
      expect(relationsForStudy(key), isNotEmpty, reason: key);
    }
  });

  test(
    'new current positions all carry provisional scope, sources and notes',
    () {
      final added = (rawCurrents['currents'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .where(
            (r) =>
                (r['editorialBasis'] as Map<String, dynamic>?)?['reviewedAt'] ==
                '2026-11-04',
          )
          .toList();
      expect(added.length, greaterThanOrEqualTo(40));
      final signatures = <String>{};
      for (final row in added) {
        final basis = row['editorialBasis'] as Map<String, dynamic>;
        expect(basis['empiricallyValidated'], false);
        expect(basis['scope'], isNotEmpty);
        expect(basis['sourceUrls'] as List<dynamic>, isNotEmpty);
        expect(basis['limitations'] as List<dynamic>, isNotEmpty);
        final axes = row['axes'] as Map<String, dynamic>;
        final triangles = row['triangles'] as Map<String, dynamic>;
        expect(axes, hasLength(12));
        expect(triangles, hasLength(6));
        final positions = <String, dynamic>{};
        for (final axis in axes.entries) {
          final value = axis.value as Map<String, dynamic>;
          expect(value['note'], isNotEmpty);
          positions[axis.key] = value['relevance'] == 0 ? null : value['mu'];
          if (value['relevance'] == 0) {
            expect(value['note'], contains('Lacuna explícita'));
            expect(
              catalog.find('current:${row['id']}')!.axes.containsKey(axis.key),
              isFalse,
            );
          }
        }
        for (final triad in triangles.entries) {
          final value = triad.value as Map<String, dynamic>;
          expect(value['note'], isNotEmpty);
          if (value['relevance'] == 0) {
            expect(value['note'], contains('Lacuna explícita'));
            expect(
              catalog
                  .find('current:${row['id']}')!
                  .triangles
                  .containsKey(int.parse(triad.key)),
              isFalse,
            );
          }
        }
        expect(
          signatures.add(jsonEncode(positions)),
          isTrue,
          reason: 'current ${row['id']} must not be an exact vector clone',
        );
      }
    },
  );

  test('new personality profiles have real evidence gaps and are not numerical clones', () {
    final revised = (rawPeople['entries'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where(
          (r) =>
              (r['editorialBasis'] as Map<String, dynamic>?)?['reviewedAt'] ==
              '2026-11-04',
        )
        .toList();
    // Forty added writers and the specifically documented revision of Marx.
    expect(revised.length, greaterThanOrEqualTo(41));
    final signatures = <String>{};
    for (final row in revised) {
      final basis = row['editorialBasis'] as Map<String, dynamic>;
      expect(basis['sourceUrls'], isNotEmpty);
      expect(basis['empiricallyValidated'], false);
      expect(row['coordinateNotes'], isNotEmpty);
      expect(
        signatures.add(jsonEncode(row['axes'])),
        isTrue,
        reason: 'personality ${row['id']} must not be an exact vector clone',
      );
    }
    expect(
      catalog.find('personality:max_stirner')!.axes.containsKey('economia'),
      isFalse,
    );
    expect(
      catalog.find('personality:theodor_adorno')!.axes.containsKey('imigracao'),
      isFalse,
    );
  });

  test('Marx has documentary links to communism and classical Marxism before later reception', () {
    final links = relationsForStudy('personality:karl_marx');
    expect(
      links.map((r) => r.targetKey),
      containsAll([
        'current:comunismo',
        'current:socialismo_marxista',
        'current:marxismo_leninismo',
        'book:critica_programa_gotha_marx',
      ]),
    );
    final leninism = links.firstWhere(
      (r) => r.targetKey == 'current:marxismo_leninismo',
    );
    expect(leninism.kind, StudyRelationKind.reception);
    expect(leninism.note, contains('não permite atribuir'));
    final classical = links.firstWhere(
      (r) => r.targetKey == 'current:socialismo_marxista',
    );
    expect(classical.kind, StudyRelationKind.tradition);
    expect(classical.sourceUrl, contains('/1875/gotha/'));
    final marx = catalog.find('personality:karl_marx')!;
    expect(marx.axes['comercio'], greaterThan(0));
    expect(marx.axes['intervencao'], lessThan(0));
    // Editorial sanity for the declared 1848–1875 recorte, not scientific proof
    // that an author equals a label and not a change to either scoring engine.
    expect(
      catalog
          .compare(marx, catalog.find('current:socialismo_marxista')!)!
          .similarity,
      greaterThan(
        catalog
            .compare(
              marx,
              catalog.find('current:trabalhismo_desenvolvimentista')!,
            )!
            .similarity,
      ),
    );
  });

  test('every documentary edge resolves both keys, has a source and works in reverse', () {
    final signatures = <String>{};
    expect(studyRelations.length, greaterThanOrEqualTo(60));
    for (final relation in studyRelations) {
      expect(
        catalog.find(relation.sourceKey),
        isNotNull,
        reason: relation.sourceKey,
      );
      expect(
        catalog.find(relation.targetKey),
        isNotNull,
        reason: relation.targetKey,
      );
      expect(relation.note, isNotEmpty);
      expect(Uri.parse(relation.sourceUrl).scheme, 'https');
      expect(
        signatures.add(
          '${relation.sourceKey}|${relation.targetKey}|${relation.kind.name}',
        ),
        isTrue,
      );
      expect(
        relationsForStudy(relation.targetKey).any(
          (r) =>
              r.targetKey == relation.sourceKey &&
              r.sourceUrl == relation.sourceUrl,
        ),
        isTrue,
      );
    }
    expect(relationsForStudy('unknown:missing'), isEmpty);
  });
}
