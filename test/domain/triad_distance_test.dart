import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/domain/engine/atlas_and_nolan_engine.dart';
import 'package:politico/domain/engine/compatibility_engine.dart';
import 'package:politico/domain/engine/triad_distance.dart';
import 'package:politico/domain/models/atlas_models.dart';
import 'package:politico/domain/models/political_models.dart';

TriadDimensionScore triad({
  required List<double> composition,
  required double engagement,
  int categoryId = 0,
}) {
  final List<double> support = <double>[
    for (final double p in composition) (p * 3.0 * engagement).clamp(0.0, 1.0),
  ];
  return TriadDimensionScore(
    categoryId: categoryId,
    label: 'Economia',
    vertices: const <String>['Controle', 'Regulação', 'Mercados'],
    vertexScores: <double>[for (final double u in support) u * 2.0 - 1.0],
    vertexSupport: support,
    composition: composition,
    engagement: engagement,
    standardError: 0.05,
    coverage: 1.0,
    answeredCount: 3,
    presentedCount: 3,
    classification: 'Teste',
    vertexBreakdownAvailable: true,
    vertexCoverage: const <double>[1.0, 1.0, 1.0],
    vertexObserved: const <bool>[true, true, true],
    vertexAnsweredCount: const <int>[1, 1, 1],
    vertexPresentedCount: const <int>[1, 1, 1],
  );
}

void main() {
  group('TriadDistanceBreakdown — propriedades matemáticas', () {
    const List<double> uniform = <double>[1 / 3, 1 / 3, 1 / 3];
    const List<double> skewed = <double>[0.6, 0.3, 0.1];

    test('é zero apenas com composição idêntica e engajamento na faixa neutra', () {
      for (final double i in <double>[0.35, 0.5, 0.65]) {
        final TriadDistanceBreakdown d = measureTriadDistance(
          composition: uniform,
          engagement: i,
          target: uniform,
        );
        expect(d.compositionDistance, closeTo(0.0, 1e-12));
        expect(d.engagementPenalty, closeTo(0.0, 1e-12));
        expect(d.combinedDistance, closeTo(0.0, 1e-12));
      }
      final TriadDistanceBreakdown far = measureTriadDistance(
        composition: uniform,
        engagement: 1.0,
        target: skewed,
      );
      expect(far.combinedDistance, greaterThan(0.0));
    });

    test('nunca aproxima: distância combinada >= distância de composição', () {
      final math.Random random = math.Random(7);
      for (var n = 0; n < 200; n++) {
        final List<double> p = _randomComposition(random);
        final List<double> mu = _randomComposition(random);
        final double i = random.nextDouble();
        final TriadDistanceBreakdown d = measureTriadDistance(
          composition: p,
          engagement: i,
          target: mu,
        );
        expect(d.combinedDistance, greaterThanOrEqualTo(d.compositionDistance - 1e-12));
        expect(d.combinedDistance, lessThanOrEqualTo(1.077));
        expect(d.compositionDistance, lessThanOrEqualTo(1.0));
      }
    });

    test('é monótona no afastamento do engajamento neutro', () {
      double previous = -1.0;
      for (final double i in <double>[0.50, 0.60, 0.70, 0.80, 0.90, 1.0]) {
        final TriadDistanceBreakdown d = measureTriadDistance(
          composition: skewed,
          engagement: i,
          target: skewed,
        );
        expect(d.compositionDistance, closeTo(0.0, 1e-12));
        expect(d.combinedDistance, greaterThanOrEqualTo(previous));
        previous = d.combinedDistance;
      }
    });

    test('é invariante à permutação simultânea dos vértices', () {
      const List<double> a = <double>[0.2, 0.5, 0.3];
      const List<double> b = <double>[0.6, 0.1, 0.3];
      final TriadDistanceBreakdown base = measureTriadDistance(
        composition: a,
        engagement: 0.8,
        target: b,
      );
      final TriadDistanceBreakdown permuted = measureTriadDistance(
        composition: <double>[a[2], a[0], a[1]],
        engagement: 0.8,
        target: <double>[b[2], b[0], b[1]],
      );
      expect(permuted.combinedDistance, closeTo(base.combinedDistance, 1e-12));
    });

    test('é simétrica na troca composição/perfil', () {
      const List<double> a = <double>[0.2, 0.5, 0.3];
      const List<double> b = <double>[0.6, 0.1, 0.3];
      final TriadDistanceBreakdown ab = measureTriadDistance(
        composition: a,
        engagement: 0.75,
        target: b,
      );
      final TriadDistanceBreakdown ba = measureTriadDistance(
        composition: b,
        engagement: 0.75,
        target: a,
      );
      expect(ba.combinedDistance, closeTo(ab.combinedDistance, 1e-12));
    });

    test('apoio e rejeição plenos com a mesma composição têm a mesma distância', () {
      const List<double> p = <double>[0.5, 0.3, 0.2];
      final TriadDistanceBreakdown support = measureTriadDistance(
        composition: p,
        engagement: 1.0,
        target: skewed,
      );
      final TriadDistanceBreakdown reject = measureTriadDistance(
        composition: p,
        engagement: 0.0,
        target: skewed,
      );
      expect(reject.combinedDistance, closeTo(support.combinedDistance, 1e-12));
      expect(support.engagementDirection, 1);
      expect(reject.engagementDirection, -1);
    });

    test('satisfaz a desigualdade triangular entre pontos elevados', () {
      // A métrica é a norma no espaço elevado
      //   E(p, I) = ((p_0, p_1, p_2)/√2, 0.4·g(I))
      // com o perfil fixo em E(μ, 0.5). Aqui medimos a distância entre dois
      // pontos *de usuário* com a mesma geometria e verificamos
      //   d(u1, w) <= d(u1, u2) + d(u2, w).
      double elevatedDistance(
        List<double> p1,
        double i1,
        List<double> p2,
        double i2,
      ) {
        final double g1 = measureTriadDistance(
          composition: p1,
          engagement: i1,
          target: p2,
        ).engagementPenalty;
        final double g2 = measureTriadDistance(
          composition: p2,
          engagement: i2,
          target: p1,
        ).engagementPenalty;
        var sq = 0.0;
        for (var k = 0; k < 3; k++) {
          final double d = p1[k] - p2[k];
          sq += d * d;
        }
        final double dg = g1 - g2;
        return math.sqrt(sq / 2.0 + kTriadEngagementWeight * dg * dg);
      }

      const List<double> target = <double>[0.45, 0.35, 0.2];
      final math.Random random = math.Random(11);
      for (var n = 0; n < 100; n++) {
        final List<double> p1 = _randomComposition(random);
        final List<double> p2 = _randomComposition(random);
        final double i1 = random.nextDouble();
        final double i2 = random.nextDouble();
        final double toProfile = measureTriadDistance(
          composition: p1,
          engagement: i1,
          target: target,
        ).combinedDistance;
        final double toProfile2 = measureTriadDistance(
          composition: p2,
          engagement: i2,
          target: target,
        ).combinedDistance;
        final double between = elevatedDistance(p1, i1, p2, i2);
        expect(toProfile, lessThanOrEqualTo(between + toProfile2 + 1e-9));
      }
    });

    test('rejeita entradas inválidas', () {
      expect(
        () => measureTriadDistance(
          composition: const <double>[0.5, 0.5],
          engagement: 0.5,
          target: uniform,
        ),
        throwsArgumentError,
      );
      expect(
        () => measureTriadDistance(
          composition: const <double>[0.5, 0.5, 0.5],
          engagement: 0.5,
          target: uniform,
        ),
        throwsArgumentError,
      );
      expect(
        () => measureTriadDistance(
          composition: const <double>[-0.1, 0.6, 0.5],
          engagement: 0.5,
          target: uniform,
        ),
        throwsArgumentError,
      );
      expect(
        () => measureTriadDistance(
          composition: uniform,
          engagement: 1.2,
          target: uniform,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Compatibilidade e Atlas incluem o apoio absoluto', () {
    const List<double> profile = <double>[0.5, 0.3, 0.2];
    final IdeologicalCatalog catalog = IdeologicalCatalog(
      schemaVersion: 1,
      catalogVersion: 'test',
      currents: <IdeologicalCurrent>[
        IdeologicalCurrent(
          id: 'c',
          name: 'Corrente de teste',
          family: 'Teste',
          summary: 'Teste',
          keyIdeas: const <String>[],
          axes: const <String, CurrentAxisProfile>{},
          triangles: <int, CurrentTriadProfile>{
            0: CurrentTriadProfile(
              mu: profile,
              sigma: 0.2,
              relevance: 1.0,
              note: 'Teste',
            ),
          },
        ),
      ],
    );

    test('mesma composição com engajamento extremo recebe compatibilidade menor', () {
      final CompatibilityReport neutral = EspectroCompatibilityEngine.evaluate(
        catalog: catalog,
        axes: const <BipolarDimensionScore>[],
        triads: <TriadDimensionScore>[
          triad(composition: profile, engagement: 0.5),
        ],
      );
      final CompatibilityReport extreme = EspectroCompatibilityEngine.evaluate(
        catalog: catalog,
        axes: const <BipolarDimensionScore>[],
        triads: <TriadDimensionScore>[
          triad(composition: profile, engagement: 1.0),
        ],
      );
      expect(
        neutral.ranked.single.compatibilityPercent,
        greaterThan(extreme.ranked.single.compatibilityPercent),
      );
      expect(
        extreme.ranked.single.meanEngagementPenalty,
        greaterThan(neutral.ranked.single.meanEngagementPenalty),
      );
      final DimensionAlignmentDetail neutralDetail =
          neutral.ranked.single.convergences.first;
      final DimensionAlignmentDetail extremeDetail =
          extreme.ranked.single.convergences.first;
      expect(neutralDetail.compositionDistance, closeTo(0.0, 1e-12));
      expect(extremeDetail.compositionDistance, closeTo(0.0, 1e-12));
      expect(
        extremeDetail.engagementPenalty,
        greaterThan(neutralDetail.engagementPenalty),
      );
    });

    test('Atlas aplica a mesma distância elevada', () {
      final AtlasEntry entry = AtlasEntry(
        id: 'e',
        kind: AtlasKind.personality,
        name: 'Entrada de teste',
        subtitle: 'Teste',
        category: 'Teste',
        era: 'Teste',
        origin: 'Teste',
        summary: 'Teste',
        highlights: const <String>[],
        quote: 'Teste',
        axes: const <String, double>{},
        triangles: const <int, List<double>>{0: profile},
      );
      final List<AtlasMatchResult> neutral = EspectroAtlasEngine.rankEntries(
        entries: <AtlasEntry>[entry],
        axes: const <BipolarDimensionScore>[],
        triads: <TriadDimensionScore>[
          triad(composition: profile, engagement: 0.5),
        ],
      );
      final List<AtlasMatchResult> extreme = EspectroAtlasEngine.rankEntries(
        entries: <AtlasEntry>[entry],
        axes: const <BipolarDimensionScore>[],
        triads: <TriadDimensionScore>[
          triad(composition: profile, engagement: 1.0),
        ],
      );
      expect(neutral.single.compatibilityPercent,
          greaterThan(extreme.single.compatibilityPercent));
    });
  });
}

List<double> _randomComposition(math.Random random) {
  final List<double> raw = <double>[
    random.nextDouble() + 0.01,
    random.nextDouble() + 0.01,
    random.nextDouble() + 0.01,
  ];
  final double sum = raw[0] + raw[1] + raw[2];
  return <double>[for (final double v in raw) v / sum];
}
