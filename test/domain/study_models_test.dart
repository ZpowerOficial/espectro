import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';

StudySubject subject(
  String key, {
  Map<String, double> axes = const {},
  Map<int, List<double>> triangles = const {},
}) => StudySubject(
  key: key,
  name: key,
  kind: 'current',
  kindLabel: 'Corrente',
  axes: axes,
  triangles: triangles,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StudyCatalog catalog;
  setUpAll(() async {
    catalog = StudyCatalog(await AppData.load());
  });
  test(
    'sparse exact matches remain comparable but cannot lead suggestions',
    () {
      final full = catalog.find('personality:murray_rothbard')!;
      final sparse = subject('one-topic', axes: {'economia': full.axes['economia']!});
      final match = catalog.compare(sparse, full)!;
      expect(match.similarity, 100);
      expect(match.supportsRanking, false);
      expect(catalog.related(sparse, limit: 862), isEmpty);
      final related = catalog.related(full, limit: 862);
      expect(related, isNotEmpty);
      expect(
        related.every(
          (m) => m.sharedAxes + m.sharedTriads >= 8 && m.coverage >= .6,
        ),
        true,
      );
    },
  );

  test('every explicit search alias resolves its actual dataset subject', () {
    for (final entry in StudyCatalog.searchAliases.entries) {
      expect(catalog.find(entry.key), isNotNull, reason: entry.key);
      for (final alias in entry.value) {
        expect(
          catalog.search(alias).any((s) => s.key == entry.key),
          isTrue,
          reason: '${entry.key}: $alias',
        );
      }
    }
    expect(
      catalog.search('EUA', kind: 'country').map((s) => s.key).toSet(),
      containsAll([
        'country:eua_founding',
        'country:eua_new_deal',
        'country:eua_reagan',
      ]),
    );
  });

  test('semantic spectra classify every actual current without duplicating legacy IDs', () {
    expect(studySpectra, hasLength(8));
    final legacy = studySpectra.expand((s) => s.ids).toList();
    expect(legacy.toSet().length, legacy.length);
    final ids = catalog.data.catalog.currents.map((c) => c.id).toSet();
    expect(legacy.toSet().difference(ids), isEmpty);
    for (final current in catalog.data.catalog.currents) {
      expect(
        spectrumOf(StudySubject.fromCurrent(current)),
        isNotNull,
        reason: current.id,
      );
    }
    expect(
      spectrumOf(catalog.find('personality:karl_marx')!)?.id,
      'radical_left',
    );
    expect(
      spectrumOf(catalog.find('personality:robert_nozick')!)?.id,
      'libertarian',
    );
    expect(
      spectrumOf(catalog.find('personality:pierre_joseph_proudhon')!)?.id,
      'anarchist',
    );
  });

  test('perfis classificados como libertários mantêm alta coerência com Mercados e Minarquia', () {
    for (final personality in catalog.data.atlas.personalities) {
      final subject = catalog.find('personality:${personality.id}');
      if (subject == null) continue;
      final spectrum = spectrumOf(subject);
      if (spectrum?.id == 'libertarian') {
        final t0 = personality.triangles[0];
        if (t0 != null) {
          expect(
            t0[2],
            greaterThanOrEqualTo(0.60),
            reason: '${personality.id} no espectro libertário deve ter Mercados >= 0.60 na Tríade 0 (atual: ${t0[2]})',
          );
        }
        final t4 = personality.triangles[4];
        if (t4 != null) {
          expect(
            t4[2],
            greaterThanOrEqualTo(0.48),
            reason: '${personality.id} no espectro libertário deve ter Minarquia >= 0.48 na Tríade 4 (atual: ${t4[2]})',
          );
        }
        final econ = personality.axes['economia'];
        if (econ != null) {
          expect(
            econ,
            greaterThanOrEqualTo(0.40),
            reason: '${personality.id} no espectro libertário deve ter economia >= 0.40 (atual: $econ)',
          );
        }
      }
    }
  });

  test(
    'invalid supplied positions are excluded instead of clipped or neutralized',
    () {
      final good = subject(
        'valid',
        axes: {'economia': 0},
        triangles: {
          0: [1, 0, 0],
        },
      );
      final invalid = subject(
        'invalid',
        axes: {'economia': 2},
        triangles: {
          0: [0.3, 0.3, 0.3],
        },
      );
      expect(catalog.compare(good, invalid), isNull);
      expect(
        catalog.compare(subject('nan', axes: {'economia': double.nan}), good),
        isNull,
      );
    },
  );

  test(
    'global search normalizes accents, indexes every kind and combines terms',
    () {
      expect(
        catalog.search('platao').map((s) => s.kind).toSet(),
        containsAll(['personality', 'book']),
      );
      expect(
        catalog
            .search('SOCIALISMO DEMOCRÁTICO')
            .any((s) => s.key == 'current:socialismo_democratico'),
        isTrue,
      );
      expect(
        catalog
            .search('democratico socialismo')
            .any((s) => s.key == 'current:socialismo_democratico'),
        isTrue,
      );
      expect(
        catalog
            .search('ancap')
            .any((s) => s.key == 'current:anarcocapitalismo'),
        isTrue,
      );
      expect(
        catalog.search('platao', kind: 'book').every((s) => s.kind == 'book'),
        isTrue,
      );
      expect(catalog.search('palavra-inexistente-do-acervo'), isEmpty);
    },
  );

  test(
    'personal subjects exclude undercovered axes and unobserved triad vertices',
    () {
      final record = EvaluationRecord(
        id: 'partial',
        createdAt: DateTime(2026, 11, 3),
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 1,
        engineVersion: 'test',
        bankVersion: 'test',
        rawAnswers: {},
        axes: [
          const BipolarDimensionScore(
            axisId: 'economia',
            label: 'Economia',
            leftPole: 'A',
            rightPole: 'B',
            score: 0,
            standardError: 0,
            coverage: 0.25,
            answeredCount: 1,
            presentedCount: 4,
            tensionScore: 0,
          ),
          const BipolarDimensionScore(
            axisId: 'poder',
            label: 'Poder',
            leftPole: 'A',
            rightPole: 'B',
            score: 0,
            standardError: 0,
            coverage: 1,
            answeredCount: 2,
            presentedCount: 2,
            tensionScore: 0,
          ),
        ],
        triads: [
          TriadDimensionScore(
            categoryId: 0,
            label: 'Economia',
            vertices: ['A', 'B', 'C'],
            vertexScores: [1, 0, 0],
            vertexSupport: [1, 0.5, 0.5],
            composition: [0.5, 0.25, 0.25],
            engagement: 0.66,
            standardError: 0,
            coverage: 1,
            answeredCount: 3,
            presentedCount: 3,
            classification: 'parcial',
            vertexBreakdownAvailable: true,
            vertexObserved: [true, true, false],
          ),
        ],
        quality: const ResponseQualityReport(
          totalPresented: 9,
          totalAnswered: 6,
          totalSkipped: 3,
          acquiescenceIndex: 0,
          extremeResponseRate: 0,
          neutralResponseRate: 0,
          axesInTension: [],
        ),
      );
      final s = StudySubject.fromEvaluation(record);
      expect(s.axes, {'poder': 0});
      expect(s.triangles, isEmpty);
      expect(
        catalog.compare(s, subject('full', axes: {'economia': 0})),
        isNull,
      );
      expect(s.record, same(record));
    },
  );

  test(
    'all subjects keep unique stable keys and reopen through versioned URI',
    () {
      expect(
        catalog.subjects.map((s) => s.key).toSet().length,
        catalog.subjects.length,
      );
      for (final s in catalog.subjects) {
        expect(catalog.find(s.key), same(s));
        expect(catalog.subjectFromUri(catalog.uriFor(s)), same(s));
      }
      expect(
        catalog.subjectFromUri(Uri.parse('/atlas?v=99&subject=current:foo')),
        isNull,
      );
      expect(
        catalog.subjectFromUri(Uri.parse('/atlas?v=1&subject=unknown:x')),
        isNull,
      );
    },
  );

  test(
    'malformed percent-encoded UTF-8 links fail closed without throwing',
    () {
      for (final value in [
        '/atlas?v=%FF',
        '/atlas?v=1&subject=%FF',
        '/atlas?v=1&subject=%E0%A4%A',
        '/atlas?v=1&subject=current:socialismo_democratico&q=%FF',
      ]) {
        final uri = Uri.tryParse(value);
        expect(
          uri,
          isNotNull,
          reason: 'URI parsing alone does not reject this input',
        );
        expect(catalog.subjectFromUri(uri!), isNull);
      }
    },
  );

  test(
    'comparison is symmetric, ignores missing dimensions and reports overlap',
    () {
      final a = subject('a', axes: {'economia': -1, 'poder': 1});
      final b = subject('b', axes: {'economia': 1});
      final ab = catalog.compare(a, b)!;
      final ba = catalog.compare(b, a)!;
      expect(ab.similarity, ba.similarity);
      expect(ab.similarity, 0);
      expect(ab.sharedAxes, 1);
      expect(ab.coverage, 0.5);
      expect(ab.differences, isNotEmpty);
      expect(catalog.compare(a, subject('c', axes: {'moral': 0})), isNull);
    },
  );

  test(
    'triads compare compositional geometry with no invented absolute support',
    () {
      final a = subject(
        'a',
        triangles: {
          0: [1, 0, 0],
        },
      );
      final samePosition = subject(
        'b',
        triangles: {
          0: [1, 0, 0],
        },
      );
      final opposite = subject(
        'c',
        triangles: {
          0: [0, 0, 1],
        },
      );
      expect(catalog.compare(a, samePosition)!.similarity, 100);
      expect(catalog.compare(a, opposite)!.similarity, 0);
      expect(catalog.compare(a, opposite)!.sharedTriads, 1);
      expect(StudyCatalog.methodDescription, contains('apoio absoluto'));
    },
  );

  test('related excludes self, is deterministic and exposes measured affinity only', () {
    final s = catalog.subjects.first;
    final first = catalog.related(s);
    final second = catalog.related(s);
    expect(first, hasLength(6));
    expect(first.every((m) => m.subject.key != s.key), isTrue);
    expect(first.map((m) => m.subject.key), second.map((m) => m.subject.key));
    expect(
      first.every((m) => m.similarity >= 0 && m.similarity <= 100),
      isTrue,
    );
  });
}
