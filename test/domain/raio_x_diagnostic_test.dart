import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:politico/data/app_data.dart';
import 'package:politico/domain/engine/atlas_and_nolan_engine.dart';
import 'package:politico/domain/engine/compatibility_engine.dart';
import 'package:politico/domain/engine/raio_x_engine.dart';
import 'package:politico/domain/engine/triad_distance.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/domain/models/raio_x_diagnostic.dart';
import 'package:politico/ui/features/compare/raio_x_card.dart';

BipolarDimensionScore _mkAxis(
  String id,
  double score, {
  double se = 0.08,
  String label = '',
  String left = 'Esquerda',
  String right = 'Direita',
}) =>
    BipolarDimensionScore(
      axisId: id,
      label: label.isNotEmpty ? label : id.toUpperCase(),
      leftPole: left,
      rightPole: right,
      score: score,
      standardError: se,
      coverage: 1.0,
      answeredCount: 10,
      presentedCount: 10,
      tensionScore: 0.0,
    );

TriadDimensionScore _mkTriad(
  int categoryId,
  List<double> composition, {
  double engagement = 0.6,
  String label = 'Tríade',
}) {
  final support = <double>[
    for (final double p in composition) (p * 3.0 * engagement).clamp(0.0, 1.0),
  ];
  return TriadDimensionScore(
    categoryId: categoryId,
    label: label,
    vertices: const <String>['V1', 'V2', 'V3'],
    vertexScores: <double>[for (final double u in support) u * 2.0 - 1.0],
    vertexSupport: support,
    composition: composition,
    engagement: engagement,
    standardError: 0.05,
    coverage: 1.0,
    answeredCount: 6,
    presentedCount: 6,
    classification: 'Classificação Teste',
    vertexBreakdownAvailable: true,
    vertexCoverage: const <double>[1.0, 1.0, 1.0],
    vertexObserved: const <bool>[true, true, true],
    vertexAnsweredCount: const <int>[2, 2, 2],
    vertexPresentedCount: const <int>[2, 2, 2],
  );
}

List<BipolarDimensionScore> _allAxes(double Function(String axisId) scoreFn) {
  const ids = [
    'estrutura',
    'representacao',
    'poder',
    'imigracao',
    'diplomacia',
    'intervencao',
    'economia',
    'controle',
    'comercio',
    'religiao',
    'moral',
    'tecnologia',
  ];
  return [
    for (final id in ids)
      _mkAxis(id, scoreFn(id), label: id.toUpperCase()),
  ];
}

List<TriadDimensionScore> _allTriads(List<double> Function(int catId) compFn, {double engagement = 0.6}) {
  return [
    for (var i = 0; i < 6; i++)
      _mkTriad(i, compFn(i), engagement: engagement),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppData appData;

  setUpAll(() async {
    appData = await AppData.load();
  });

  group('RaioXEngine — Auditoria Metodológica e Resolução dos Achados A1-A8', () {
    test('1. Cobertura parcial (< 4 dimensões) ativa status de Evidência Insuficiente (A7)', () {
      final current = appData.catalog.currents.first;
      final partialCompat = CurrentCompatibility(
        current: current,
        compatibilityPercent: 65.0,
        evaluatedDimensions: 2, // < 4
        rmsZ: 0.8,
        details: const <DimensionAlignmentDetail>[
          DimensionAlignmentDetail(
            dimensionId: 'economia',
            dimensionLabel: 'Economia',
            isTriad: false,
            normalizedZ: 0.2,
            relevance: 1.0,
            rawDistance: 0.1,
            userSummary: 'Estatismo',
            currentSummary: 'Estatismo',
            note: 'Nota histórica',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'controle',
            dimensionLabel: 'Controle',
            isTriad: false,
            normalizedZ: 0.3,
            relevance: 1.0,
            rawDistance: 0.15,
            userSummary: 'Planejamento',
            currentSummary: 'Planejamento',
            note: 'Nota histórica',
          ),
        ],
        convergences: const <DimensionAlignmentDetail>[],
        divergences: const <DimensionAlignmentDetail>[],
      );

      final diag = RaioXEngine.fromCurrentCompatibility(
        compatibility: partialCompat,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      expect(diag.insufficientEvidence, isTrue);
      expect(diag.approachingSection.hasSufficientEvidence, isFalse);
      expect(diag.divergingSection.hasSufficientEvidence, isFalse);
      expect(diag.approachingSection.items, isEmpty);
      expect(diag.divergingSection.items, isEmpty);
      expect(diag.conceptualDifferentiation, contains('mínimo operacional de comparação'));
      expect(diag.insufficientEvidenceReason, contains('mínimo operacional'));
    });

    test('2. Dimensões com relevance <= 0.0 são estritamente excluídas da análise (A2)', () {
      final current = appData.catalog.currents.first;
      final dummyCompat = CurrentCompatibility(
        current: current,
        compatibilityPercent: 78.5,
        evaluatedDimensions: 5,
        rmsZ: 0.6,
        details: const <DimensionAlignmentDetail>[
          DimensionAlignmentDetail(
            dimensionId: 'zero_rel_dim',
            dimensionLabel: 'Dimensão Irrelevante',
            isTriad: false,
            normalizedZ: 0.1,
            relevance: 0.0, // Relevância ZERO
            rawDistance: 0.05,
            userSummary: 'Neutro',
            currentSummary: 'Neutro',
            note: '',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'valid_dim_1',
            dimensionLabel: 'Dimensão Relevante 1',
            isTriad: false,
            normalizedZ: 0.2,
            relevance: 0.9,
            rawDistance: 0.10,
            userSummary: 'Convergente',
            currentSummary: 'Convergente',
            note: 'Nota 1',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'valid_dim_2',
            dimensionLabel: 'Dimensão Relevante 2',
            isTriad: false,
            normalizedZ: 0.25,
            relevance: 0.8,
            rawDistance: 0.12,
            userSummary: 'Convergente',
            currentSummary: 'Convergente',
            note: 'Nota 2',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'valid_dim_3',
            dimensionLabel: 'Dimensão Relevante 3',
            isTriad: false,
            normalizedZ: 0.30,
            relevance: 0.85,
            rawDistance: 0.15,
            userSummary: 'Convergente',
            currentSummary: 'Convergente',
            note: 'Nota 3',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'valid_dim_4',
            dimensionLabel: 'Dimensão Relevante 4',
            isTriad: false,
            normalizedZ: 1.5,
            relevance: 0.95,
            rawDistance: 0.80,
            userSummary: 'Divergente',
            currentSummary: 'Oposto',
            note: 'Nota 4',
          ),
        ],
        convergences: const <DimensionAlignmentDetail>[],
        divergences: const <DimensionAlignmentDetail>[],
      );

      final diag = RaioXEngine.fromCurrentCompatibility(
        compatibility: dummyCompat,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      expect(diag.insufficientEvidence, isFalse);
      expect(diag.approachingSection.items.any((i) => i.dimensionId == 'zero_rel_dim'), isFalse);
      expect(diag.divergingSection.items.any((i) => i.dimensionId == 'zero_rel_dim'), isFalse);
      expect(diag.approachingSection.items.any((i) => i.dimensionId == 'valid_dim_1'), isTrue);
    });

    test('3. Identidade de contribuições: elimina constante 0.28 e extrai rawDistance real (A3)', () {
      final userAxes = _allAxes((id) => id == 'economia' ? 0.9 : 0.0);
      final userTriads = _allTriads((id) => [0.333, 0.333, 0.334]);

      final report = EspectroCompatibilityEngine.evaluate(
        catalog: appData.catalog,
        axes: userAxes,
        triads: userTriads,
      );

      final ancapCompat = report.ranked.firstWhere((c) => c.current.id == 'anarcocapitalismo');

      final diag = RaioXEngine.fromCurrentCompatibility(
        compatibility: ancapCompat,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      expect(diag.compatibilityPercent, equals(ancapCompat.compatibilityPercent));

      // Para cada dimensão do Raio-X, o deltaDistance deve coincidir com detail.rawDistance
      for (final item in diag.approachingSection.items.followedBy(diag.divergingSection.items)) {
        final origin = ancapCompat.details.firstWhere((d) => d.dimensionId == item.dimensionId);
        expect(item.deltaDistance, closeTo(origin.rawDistance, 0.01));
        expect(item.normalizedZ, closeTo(origin.normalizedZ, 0.01));
        expect(item.relevance, equals(origin.relevance));
      }
    });

    test('4. Contraexemplo da Auditoria: tríade com d_comp=0 e I=1.0 (d_comb=0.40, z=1.235) é classificada como DIVERGÊNCIA e NÃO como convergência (A1, A4)', () {
      // Contraexemplo exato levantado pelo auditor:
      // Usuário tem mesma composição que o alvo, mas engajamento máximo (I = 1.0)
      const composition = <double>[0.70, 0.20, 0.10];
      final breakdown = measureTriadDistance(
        composition: composition,
        engagement: 1.0,
        target: composition,
      );

      // Verificação da fórmula oficial
      expect(breakdown.compositionDistance, closeTo(0.0, 1e-9));
      expect(breakdown.engagementPenalty, closeTo(1.0, 1e-9));
      expect(breakdown.combinedDistance, closeTo(0.40, 1e-6));

      // 1. Fluxo Atlas Entry Comparison
      final marxEntry = appData.atlas.personalities.firstWhere((p) => p.id == 'karl_marx');
      // Usuário alinhado nos eixos para isolar o efeito da tríade
      final userAxes = marxEntry.axes.entries
          .map((e) => _mkAxis(e.key, e.value))
          .toList();
      final userTriads = <TriadDimensionScore>[
        _mkTriad(0, marxEntry.triangles[0]!, engagement: 1.0),
        _mkTriad(1, marxEntry.triangles[1]!, engagement: 0.5),
        _mkTriad(2, marxEntry.triangles[2]!, engagement: 0.5),
      ];

      final res = EspectroAtlasEngine.compareWithAtlasEntry(
        entry: marxEntry,
        userAxes: userAxes,
        userTriads: userTriads,
      );

      final detail0 = res.alignmentDetails.firstWhere((d) => d.dimensionId == 'tri_0');
      expect(detail0.rawDistance, closeTo(0.0, 1e-9));
      expect(detail0.combinedDistance, closeTo(0.40, 1e-6));
      expect(detail0.engagement, closeTo(1.0, 1e-9));
      expect(detail0.normalizedZ, greaterThan(0.80)); // z > 0.80 devido a d_comb = 0.40!

      // Chama o RaioXEngine oficial
      final diagAtlas = RaioXEngine.fromEntityComparison(
        comparison: res,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      // A tríade tri_0 NÃO PODE estar nas aproximações/convergências (z > 0.80 e d_comb = 0.40)
      expect(
        diagAtlas.approachingSection.items.any((i) => i.dimensionId == 'tri_0'),
        isFalse,
        reason: 'Tríade com d_comb=0.40 e z>0.80 nunca deve ser classificada como aproximação',
      );

      // A tríade tri_0 DEVE constar nas divergências
      expect(
        diagAtlas.divergingSection.items.any((i) => i.dimensionId == 'tri_0'),
        isTrue,
        reason: 'Tríade com d_comb=0.40 e z>0.80 deve constar nas divergências',
      );

      final divItem = diagAtlas.divergingSection.items.firstWhere((i) => i.dimensionId == 'tri_0');
      expect(divItem.deltaDistance, closeTo(0.0, 1e-6));
      expect(divItem.combinedDistance, closeTo(0.40, 1e-6));
      expect(divItem.compositionDistance, closeTo(0.0, 1e-6));
      expect(divItem.engagement, closeTo(1.0, 1e-6));

      // 2. Fluxo Corrente Ideológica (CurrentCompatibility)
      final current = appData.catalog.currents.first;
      final dummyDetails = <DimensionAlignmentDetail>[
        DimensionAlignmentDetail(
          dimensionId: 'tri_0',
          dimensionLabel: 'Economia',
          isTriad: true,
          normalizedZ: 1.235,
          relevance: 1.0,
          userSummary: 'Composição alinhada (engajamento 1.0)',
          currentSummary: 'Composição de referência',
          note: 'Análise de engajamento',
          rawDistance: 0.0,
          compositionDistance: 0.0,
          engagement: 1.0,
          engagementPenalty: 0.40,
          combinedDistance: 0.40,
        ),
        const DimensionAlignmentDetail(
          dimensionId: 'eixo_1',
          dimensionLabel: 'Eixo 1',
          isTriad: false,
          normalizedZ: 0.20,
          relevance: 1.0,
          userSummary: 'U1',
          currentSummary: 'C1',
          note: 'N1',
          rawDistance: 0.05,
          combinedDistance: 0.05,
        ),
        const DimensionAlignmentDetail(
          dimensionId: 'eixo_2',
          dimensionLabel: 'Eixo 2',
          isTriad: false,
          normalizedZ: 0.25,
          relevance: 1.0,
          userSummary: 'U2',
          currentSummary: 'C2',
          note: 'N2',
          rawDistance: 0.06,
          combinedDistance: 0.06,
        ),
        const DimensionAlignmentDetail(
          dimensionId: 'eixo_3',
          dimensionLabel: 'Eixo 3',
          isTriad: false,
          normalizedZ: 0.30,
          relevance: 1.0,
          userSummary: 'U3',
          currentSummary: 'C3',
          note: 'N3',
          rawDistance: 0.08,
          combinedDistance: 0.08,
        ),
      ];

      final currentCompat = CurrentCompatibility(
        current: current,
        compatibilityPercent: 82.0,
        rmsZ: 0.65,
        evaluatedDimensions: 4,
        convergences: const [],
        divergences: const [],
        details: dummyDetails,
      );

      final diagCurrent = RaioXEngine.fromCurrentCompatibility(
        compatibility: currentCompat,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      expect(
        diagCurrent.approachingSection.items.any((i) => i.dimensionId == 'tri_0'),
        isFalse,
      );
      expect(
        diagCurrent.divergingSection.items.any((i) => i.dimensionId == 'tri_0'),
        isTrue,
      );
    });

    test('5. Simetria de engajamento extremo: I=1.0 e I=0.0 produzem a mesma distância escalar (A8)', () {
      const comp = <double>[0.5, 0.3, 0.2];
      final bHigh = measureTriadDistance(composition: comp, engagement: 1.0, target: comp);
      final bLow = measureTriadDistance(composition: comp, engagement: 0.0, target: comp);

      // d_comb é estritamente simétrico em torno de I=0.5
      expect(bHigh.combinedDistance, equals(bLow.combinedDistance));
      expect(bHigh.combinedDistance, closeTo(0.40, 1e-6));

      // Mas as classificações qualitativas e direções de engajamento são opostas
      expect(bHigh.engagementDirection, equals(1));
      expect(bLow.engagementDirection, equals(-1));
    });

    test('6. Pesos e relevâncias variáveis ordenam o ranking de divergências (A2)', () {
      final current = appData.catalog.currents.first;
      final dummyCompat = CurrentCompatibility(
        current: current,
        compatibilityPercent: 60.0,
        evaluatedDimensions: 4,
        rmsZ: 1.2,
        details: const <DimensionAlignmentDetail>[
          DimensionAlignmentDetail(
            dimensionId: 'dim_low_rel',
            dimensionLabel: 'Baixa Relevância',
            isTriad: false,
            normalizedZ: 1.5,
            relevance: 0.3, // Impacto = 0.3 * 1.5² = 0.675
            rawDistance: 0.7,
            userSummary: 'A',
            currentSummary: 'B',
            note: 'Nota',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'dim_high_rel',
            dimensionLabel: 'Alta Relevância',
            isTriad: false,
            normalizedZ: 1.5,
            relevance: 1.0, // Impacto = 1.0 * 1.5² = 2.25
            rawDistance: 0.7,
            userSummary: 'A',
            currentSummary: 'B',
            note: 'Nota',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'dim_conv_1',
            dimensionLabel: 'Conv 1',
            isTriad: false,
            normalizedZ: 0.2,
            relevance: 1.0,
            rawDistance: 0.1,
            userSummary: 'A',
            currentSummary: 'A',
            note: 'Nota',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'dim_conv_2',
            dimensionLabel: 'Conv 2',
            isTriad: false,
            normalizedZ: 0.3,
            relevance: 1.0,
            rawDistance: 0.15,
            userSummary: 'A',
            currentSummary: 'A',
            note: 'Nota',
          ),
        ],
        convergences: const <DimensionAlignmentDetail>[],
        divergences: const <DimensionAlignmentDetail>[],
      );

      final diag = RaioXEngine.fromCurrentCompatibility(
        compatibility: dummyCompat,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      // A dimensão de alta relevância deve estar no topo das divergências
      expect(diag.divergingSection.items.first.dimensionId, equals('dim_high_rel'));
      expect(diag.divergingSection.items.first.weightedImpact, greaterThan(diag.divergingSection.items[1].weightedImpact!));
    });

    test('7. Nenhuma proximidade de fato -> rótulo honesto "Menores afastamentos relativos" (A4)', () {
      final current = appData.catalog.currents.first;
      final distantCompat = CurrentCompatibility(
        current: current,
        compatibilityPercent: 30.0,
        evaluatedDimensions: 4,
        rmsZ: 1.8,
        details: const <DimensionAlignmentDetail>[
          DimensionAlignmentDetail(
            dimensionId: 'dim_1',
            dimensionLabel: 'D1',
            isTriad: false,
            normalizedZ: 1.2, // > 0.80
            relevance: 1.0,
            rawDistance: 0.6, // > 0.35
            userSummary: 'X',
            currentSummary: 'Y',
            note: 'Nota',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'dim_2',
            dimensionLabel: 'D2',
            isTriad: false,
            normalizedZ: 1.4,
            relevance: 1.0,
            rawDistance: 0.7,
            userSummary: 'X',
            currentSummary: 'Y',
            note: 'Nota',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'dim_3',
            dimensionLabel: 'D3',
            isTriad: false,
            normalizedZ: 1.6,
            relevance: 1.0,
            rawDistance: 0.8,
            userSummary: 'X',
            currentSummary: 'Y',
            note: 'Nota',
          ),
          DimensionAlignmentDetail(
            dimensionId: 'dim_4',
            dimensionLabel: 'D4',
            isTriad: false,
            normalizedZ: 1.9,
            relevance: 1.0,
            rawDistance: 0.95,
            userSummary: 'X',
            currentSummary: 'Y',
            note: 'Nota',
          ),
        ],
        convergences: const <DimensionAlignmentDetail>[],
        divergences: const <DimensionAlignmentDetail>[],
      );

      final diag = RaioXEngine.fromCurrentCompatibility(
        compatibility: distantCompat,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      // Não deve alegar convergência forte
      expect(diag.approachingSection.title, equals('Menores afastamentos relativos'));
      expect(diag.approachingSection.description, contains('Nenhuma dimensão apresentou proximidade acentuada'));
      expect(diag.approachingSection.items.first.mathematicalContribution, contains('menor afastamento relativo'));
    });

    test('8. Garantia de não duplicação entre blocos de aproximação e divergência (A4)', () {
      final userAxes = _allAxes((id) => id == 'economia' ? -1.0 : 0.5);
      final userTriads = _allTriads((id) => [0.7, 0.2, 0.1]);

      final report = EspectroCompatibilityEngine.evaluate(
        catalog: appData.catalog,
        axes: userAxes,
        triads: userTriads,
      );

      final diag = RaioXEngine.fromCurrentCompatibility(
        compatibility: report.ranked.first,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      final appIds = diag.approachingSection.items.map((i) => i.dimensionId).toSet();
      final divIds = diag.divergingSection.items.map((i) => i.dimensionId).toSet();

      // Interseção entre aproximações e divergências deve ser estritamente vazia
      final intersection = appIds.intersection(divIds);
      expect(intersection, isEmpty);
    });

    test('9. Fontes primárias verificadas vs. Síntese editorial e links navegáveis (A5, A6)', () {
      final marxEntry = appData.atlas.personalities.firstWhere((p) => p.id == 'karl_marx');
      final userAxes = _allAxes((id) => -0.8);
      final userTriads = _allTriads((id) => [0.7, 0.2, 0.1]);

      final comparison = EspectroAtlasEngine.compareWithAtlasEntry(
        entry: marxEntry,
        userAxes: userAxes,
        userTriads: userTriads,
      );

      final diag = RaioXEngine.fromEntityComparison(
        comparison: comparison,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      expect(diag.insufficientEvidence, isFalse);

      // Procura dimensão com localizador documental
      final itemWithDoc = diag.approachingSection.items
          .followedBy(diag.divergingSection.items)
          .firstWhere((i) => i.locator != null && i.locator!.isNotEmpty);

      expect(itemWithDoc.locator, isNotEmpty);
      // Confirma que a síntese não inventou aspas de transcrição direta
      expect(diag.conceptualDifferentiation.contains('""'), isFalse);
    });

    test('10. Comparação com Atlas Entry popula e consome alignmentDetails diretamente (A1, A2)', () {
      final entry = appData.atlas.personalities.first;
      final userAxes = _allAxes((id) => 0.0);
      final userTriads = _allTriads((id) => [0.333, 0.333, 0.334]);

      final comp = EspectroAtlasEngine.compareWithAtlasEntry(
        entry: entry,
        userAxes: userAxes,
        userTriads: userTriads,
      );

      expect(comp.alignmentDetails, isNotEmpty);
      expect(comp.alignmentDetails.length, greaterThanOrEqualTo(4));

      final diag = RaioXEngine.fromEntityComparison(
        comparison: comp,
        twelveAxes: appData.twelveAxes,
        sixTriangles: appData.sixTriangles,
      );

      expect(diag.evaluatedDimensionsCount, equals(comp.alignmentDetails.length));
      expect(diag.compatibilityPercent, equals(comp.compatibilityPercent));
    });

    test('11. Reconstrução integral da nota compatibilityPercent a partir de todos os pesos e contribuições (A3)', () {
      final userAxes = _allAxes((id) => id == 'economia' ? 0.7 : -0.2);
      final userTriads = _allTriads((id) => [0.4, 0.4, 0.2]);

      final report = EspectroCompatibilityEngine.evaluate(
        catalog: appData.catalog,
        axes: userAxes,
        triads: userTriads,
      );

      for (final compat in report.ranked.take(5)) {
        // Reconstrói matematicamente d² = sum(relevance * z²) / sum(relevance)
        double weightedZ2Sum = 0.0;
        double relevanceSum = 0.0;

        for (final detail in compat.details) {
          weightedZ2Sum += detail.weightedImpact;
          relevanceSum += detail.relevance;
        }

        final d2 = weightedZ2Sum / relevanceSum;
        final expectedCompat = double.parse(
          (100.0 * math.exp(-d2 / 2.0)).clamp(0.0, 100.0).toStringAsFixed(2),
        );

        expect(compat.compatibilityPercent, equals(expectedCompat));
        expect(compat.rmsZ, closeTo(math.sqrt(d2), 1e-6));

        // RaioXDiagnostic preserva exatamente este percentual reconstruído
        final diag = RaioXEngine.fromCurrentCompatibility(
          compatibility: compat,
          twelveAxes: appData.twelveAxes,
          sixTriangles: appData.sixTriangles,
        );
        expect(diag.compatibilityPercent, equals(compat.compatibilityPercent));
      }
    });

    test('12. Síntese conceitual nunca duplica pontuação ao citar notas do catálogo', () {
      final userAxes = _allAxes((id) => id == 'economia' ? 0.7 : -0.2);
      final userTriads = _allTriads((id) => [0.4, 0.4, 0.2]);
      final report = EspectroCompatibilityEngine.evaluate(
        catalog: appData.catalog,
        axes: userAxes,
        triads: userTriads,
      );
      for (final compat in report.ranked) {
        final diag = RaioXEngine.fromCurrentCompatibility(
          compatibility: compat,
          twelveAxes: appData.twelveAxes,
          sixTriangles: appData.sixTriangles,
        );
        final text = diag.conceptualDifferentiation;
        expect(
          RegExp(r'(?<!\.)\.\.(?!\.)|[.!?]\s*\.').hasMatch(text),
          isFalse,
          reason: '${compat.current.name}: $text',
        );
      }
    });
  });

  group('RaioXDiagnosticCard — Widgets, Responsividade e Acessibilidade (A5, A6, A7)', () {
    testWidgets('Renderiza header com contagem exata e expande link de fonte primária', (WidgetTester tester) async {
      const diag = RaioXDiagnostic(
        targetId: 'teste',
        targetName: 'Liberalismo Clássico',
        targetKindLabel: 'Corrente Ideológica',
        compatibilityPercent: 88.0,
        approachingSection: RaioXSection(
          title: 'Onde vocês se aproximam',
          description: 'Dimensões com pequena distância.',
          items: <RaioXDimensionItem>[
            RaioXDimensionItem(
              dimensionId: 'economia',
              dimensionLabel: 'Economia',
              isTriad: false,
              userSummary: 'Livre Mercado',
              targetSummary: 'Livre Mercado',
              deltaDistance: 0.08,
              normalizedZ: 0.22,
              relevance: 1.0,
              weightedImpact: 0.05,
              mathematicalContribution: 'Δ = 0.08 · z = 0.22 · proximidade relativa verificada',
              catalogNote: 'Defesa irrestrita da propriedade privada.',
              locator: 'Capítulo 2, p. 14',
              sourceUrl: 'https://exemplo.org/fonte',
            ),
          ],
        ),
        divergingSection: RaioXSection(
          title: 'Onde vocês divergem',
          description: 'Dimensões com maior afastamento.',
          items: <RaioXDimensionItem>[],
        ),
        conceptualDifferentiation: 'Síntese conceitual de teste.',
        evaluatedDimensionsCount: 8,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RaioXDiagnosticCard(diagnostic: diag),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Confirma terminologia correta: "8 dimensões comparadas" (A5)
      expect(find.text('8 dimensões comparadas'), findsOneWidget);
      expect(find.text('DIAGNÓSTICO ESTRUTURADO'), findsOneWidget);
      expect(find.text('Raio-X: Você e Liberalismo Clássico'), findsOneWidget);

      // Expande a dimensão Economia
      await tester.tap(find.text('Economia'));
      await tester.pumpAndSettle();

      // Verifica exibição de localizador documental, síntese editorial e link externo seguro (A5, A6)
      expect(find.textContaining('Localizador documental: Capítulo 2, p. 14'), findsOneWidget);
      expect(find.textContaining('Síntese editorial: Defesa irrestrita da propriedade privada.'), findsOneWidget);
      expect(find.text('Referência documental catalogada (abrir documento)'), findsOneWidget);
    });

    testWidgets('Segurança de URLs externas: rejeita esquemas inseguros ou não-HTTPS e exibe aviso (A6)', (WidgetTester tester) async {
      const insecureDiag = RaioXDiagnostic(
        targetId: 'teste_inseguro',
        targetName: 'Teste de Segurança',
        targetKindLabel: 'Corrente',
        compatibilityPercent: 80.0,
        approachingSection: RaioXSection(
          title: 'Onde vocês se aproximam',
          description: 'Aproximação',
          items: <RaioXDimensionItem>[
            RaioXDimensionItem(
              dimensionId: 'inseguro',
              dimensionLabel: 'Eixo Inseguro',
              isTriad: false,
              userSummary: 'U',
              targetSummary: 'T',
              deltaDistance: 0.1,
              relevance: 1.0,
              mathematicalContribution: 'Δ = 0.1',
              sourceUrl: 'http://site-inseguro-sem-tls.com/livro.pdf',
            ),
          ],
        ),
        divergingSection: RaioXSection(
          title: 'Onde vocês divergem',
          description: 'Divergência',
          items: <RaioXDimensionItem>[],
        ),
        conceptualDifferentiation: 'Síntese',
        evaluatedDimensionsCount: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RaioXDiagnosticCard(diagnostic: insecureDiag),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eixo Inseguro'));
      await tester.pumpAndSettle();

      final linkFinder = find.text('Referência documental catalogada (abrir documento)');
      expect(linkFinder, findsOneWidget);

      await tester.tap(linkFinder);
      await tester.pumpAndSettle();

      // Confirma que exibe SnackBar de segurança e recusa execução de link HTTP sem TLS
      expect(
        find.text('Link de referência indisponível ou inseguro (exige HTTPS com domínio válido).'),
        findsOneWidget,
      );
    });

    testWidgets('Responsividade em tela estreita (320px) com texto ampliado 2x sem estouro (A9)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;

      const diag = RaioXDiagnostic(
        targetId: 'teste_mobile',
        targetName: 'Social-Democracia Nórdica',
        targetKindLabel: 'Corrente Ideológica',
        compatibilityPercent: 74.0,
        approachingSection: RaioXSection(
          title: 'Onde vocês se aproximam',
          description: 'Pequeno distanciamento.',
          items: <RaioXDimensionItem>[
            RaioXDimensionItem(
              dimensionId: 'intervencao',
              dimensionLabel: 'Intervenção Estatal na Economia e Regulação',
              isTriad: false,
              userSummary: 'Regulação Social Ampla',
              targetSummary: 'Regulação Social Ampla',
              deltaDistance: 0.12,
              normalizedZ: 0.35,
              relevance: 1.0,
              weightedImpact: 0.12,
              mathematicalContribution: 'Δ = 0.12 · z = 0.35',
            ),
          ],
        ),
        divergingSection: RaioXSection(
          title: 'Onde vocês divergem',
          description: 'Maior atrito.',
          items: <RaioXDimensionItem>[],
        ),
        conceptualDifferentiation: 'Diferenciação conceitual em tela estreita.',
        evaluatedDimensionsCount: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: RaioXDiagnosticCard(diagnostic: diag),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('5 dimensões comparadas'), findsOneWidget);
      expect(tester.takeException(), isNull); // ZERO overflows
    });
  });
}
