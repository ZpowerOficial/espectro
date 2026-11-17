import '../../data/models.dart';
import '../models/atlas_models.dart';
import '../models/raio_x_diagnostic.dart';
import '../models/study_models.dart';
import 'compatibility_engine.dart';

/// Motor analítico do Raio-X de Convergências e Divergências.
///
/// Não desenvolve uma fórmula paralela de afinidade nem recalcula distâncias
/// independentes: consome estritamente os [DimensionAlignmentDetail] emitidos pelo
/// motor oficial ([EspectroCompatibilityEngine] para correntes e [EspectroAtlasEngine]
/// para entradas do Atlas Político), garantindo identidade matemática absoluta.
abstract final class RaioXEngine {
  /// Limite operacional mínimo de dimensões comparadas para produzir diagnóstico estruturado.
  static const int minDimensionsForOperationalComparison = 4;

  /// Limite de distância padronizada z para considerar proximidade demonstrável.
  static const double approachingZThreshold = 0.80;

  /// Limite de distância bruta Δ para proximidade nos eixos bipolares.
  static const double approachingDeltaThreshold = 0.35;

  /// Limite de distância padronizada z para considerar divergência de impacto.
  static const double divergingZThreshold = 0.65;

  /// Constrói o Raio-X a partir da compatibilidade oficial com uma Corrente Ideológica.
  static RaioXDiagnostic fromCurrentCompatibility({
    required CurrentCompatibility compatibility,
    required TwelveAxesData twelveAxes,
    required SixTrianglesData sixTriangles,
  }) {
    final current = compatibility.current;
    final details = compatibility.details;

    if (details.isEmpty) {
      return RaioXDiagnostic(
        targetId: current.id,
        targetName: current.name,
        targetKindLabel: 'Corrente Ideológica',
        compatibilityPercent: compatibility.compatibilityPercent,
        approachingSection: const RaioXSection(
          title: 'Onde vocês se aproximam',
          description: 'Evidência insuficiente para estimar convergências.',
          items: <RaioXDimensionItem>[],
          hasSufficientEvidence: false,
          insufficientReason:
              'Detalhes analíticos oficiais indisponíveis para esta avaliação.',
        ),
        divergingSection: const RaioXSection(
          title: 'Onde vocês divergem',
          description: 'Evidência insuficiente para estimar divergências.',
          items: <RaioXDimensionItem>[],
          hasSufficientEvidence: false,
          insufficientReason:
              'Detalhes analíticos oficiais indisponíveis para esta avaliação.',
        ),
        conceptualDifferentiation:
            'Não foi possível formular uma diferenciação conceitual fundamentada '
            'porque os detalhes analíticos oficiais não foram fornecidos pelo motor.',
        evaluatedDimensionsCount: 0,
        insufficientEvidence: true,
        insufficientEvidenceReason:
            'Detalhes analíticos oficiais indisponíveis para esta avaliação.',
      );
    }

    return _buildDiagnosticFromDetails(
      targetId: current.id,
      targetName: current.name,
      targetKindLabel: 'Corrente Ideológica',
      compatibilityPercent: compatibility.compatibilityPercent,
      details: details,
      summary: current.summary,
      keyIdeas: current.keyIdeas,
      twelveAxes: twelveAxes,
      sixTriangles: sixTriangles,
    );
  }

  /// Constrói o Raio-X a partir de um [EntityComparisonResult] oficial.
  static RaioXDiagnostic fromEntityComparison({
    required EntityComparisonResult comparison,
    required TwelveAxesData twelveAxes,
    required SixTrianglesData sixTriangles,
    StudySubject? subject,
  }) {
    final details = comparison.alignmentDetails;

    return _buildDiagnosticFromDetails(
      targetId: comparison.targetId,
      targetName: comparison.targetName,
      targetKindLabel: comparison.targetKindLabel,
      compatibilityPercent: comparison.compatibilityPercent,
      details: details,
      summary: comparison.summary,
      keyIdeas: subject?.ideas ?? const <String>[],
      twelveAxes: twelveAxes,
      sixTriangles: sixTriangles,
      subject: subject,
    );
  }

  /// Constrói os três blocos metodológicos a partir da decomposição analítica oficial.
  static RaioXDiagnostic _buildDiagnosticFromDetails({
    required String targetId,
    required String targetName,
    required String targetKindLabel,
    required double? compatibilityPercent,
    required List<DimensionAlignmentDetail> details,
    required String summary,
    List<String> keyIdeas = const <String>[],
    required TwelveAxesData twelveAxes,
    required SixTrianglesData sixTriangles,
    StudySubject? subject,
  }) {
    // Filtra estritamente dimensões com relevância > 0
    final validDetails = details.where((d) => d.relevance > 0.0).toList();
    final totalDimensions = validDetails.length;

    if (totalDimensions < minDimensionsForOperationalComparison) {
      return RaioXDiagnostic(
        targetId: targetId,
        targetName: targetName,
        targetKindLabel: targetKindLabel,
        compatibilityPercent: compatibilityPercent,
        approachingSection: const RaioXSection(
          title: 'Onde vocês se aproximam',
          description: 'Evidência insuficiente para estimar convergências.',
          items: <RaioXDimensionItem>[],
          hasSufficientEvidence: false,
          insufficientReason:
              'Menos de 4 dimensões em comum no catálogo (mínimo operacional de comparação).',
        ),
        divergingSection: const RaioXSection(
          title: 'Onde vocês divergem',
          description: 'Evidência insuficiente para estimar divergências.',
          items: <RaioXDimensionItem>[],
          hasSufficientEvidence: false,
          insufficientReason:
              'Menos de 4 dimensões em comum no catálogo (mínimo operacional de comparação).',
        ),
        conceptualDifferentiation:
            'Não foi possível formular uma diferenciação conceitual fundamentada '
            'porque a sobreposição entre as respostas do questionário e as dimensões '
            'documentadas de $targetName possui menos de 4 dimensões '
            '(mínimo operacional de comparação do sistema).',
        evaluatedDimensionsCount: totalDimensions,
        insufficientEvidence: true,
        insufficientEvidenceReason:
            'Menos de 4 dimensões em comum no catálogo (mínimo operacional de comparação).',
      );
    }

    // Ordena por distância padronizada z crescente
    final sortedByZ = List<DimensionAlignmentDetail>.from(validDetails)
      ..sort((a, b) => a.normalizedZ.compareTo(b.normalizedZ));

    // Identifica itens com proximidade demonstrável em relação à afinidade oficial:
    // Exige TANTO z padronizado baixo (z <= 0.80) QUANTO desvio combinado baixo (dist <= 0.35).
    // Evita falsas convergências onde d_comp é baixo mas a penalidade de engajamento eleva d_comb e z.
    final strictlyApproaching = sortedByZ
        .where(
          (d) =>
              d.normalizedZ <= approachingZThreshold &&
              d.combinedDistance <= approachingDeltaThreshold,
        )
        .take(3)
        .toList();

    final bool hasStrictProximity = strictlyApproaching.isNotEmpty;
    final List<DimensionAlignmentDetail> selectedApproaching =
        hasStrictProximity ? strictlyApproaching : sortedByZ.take(2).toList();

    final approachingItems = <RaioXDimensionItem>[];
    final approachingIds = <String>{};

    for (final d in selectedApproaching) {
      approachingIds.add(d.dimensionId);
      final rawDist = double.parse(d.rawDistance.clamp(0.0, 2.0).toStringAsFixed(2));
      final combDist = double.parse(d.combinedDistance.clamp(0.0, 2.0).toStringAsFixed(2));
      final zVal = double.parse(d.normalizedZ.toStringAsFixed(2));
      final weighted = double.parse(d.weightedImpact.toStringAsFixed(2));

      final String mathContrib;
      if (d.isTriad) {
        final engText = d.engagement != 0.5
            ? ' · engajamento = ${d.engagement.toStringAsFixed(2)}'
            : '';
        mathContrib = hasStrictProximity
            ? 'Δcomp = ${rawDist.toStringAsFixed(2)}$engText · dcomb = ${combDist.toStringAsFixed(2)} · z = ${zVal.toStringAsFixed(2)} · proximidade relativa verificada'
            : 'Δcomp = ${rawDist.toStringAsFixed(2)}$engText · dcomb = ${combDist.toStringAsFixed(2)} · z = ${zVal.toStringAsFixed(2)} · menor afastamento relativo';
      } else {
        mathContrib = hasStrictProximity
            ? 'Δ = ${rawDist.toStringAsFixed(2)} · z = ${zVal.toStringAsFixed(2)} · proximidade relativa verificada'
            : 'Δ = ${rawDist.toStringAsFixed(2)} · z = ${zVal.toStringAsFixed(2)} · menor afastamento relativo';
      }

      approachingItems.add(
        RaioXDimensionItem(
          dimensionId: d.dimensionId,
          dimensionLabel: d.dimensionLabel,
          isTriad: d.isTriad,
          userSummary: d.userSummary,
          targetSummary: d.currentSummary,
          deltaDistance: rawDist,
          combinedDistance: combDist,
          compositionDistance: d.compositionDistance,
          engagement: d.engagement,
          engagementPenalty: d.engagementPenalty,
          normalizedZ: zVal,
          relevance: d.relevance,
          weightedImpact: weighted,
          mathematicalContribution: mathContrib,
          catalogNote: d.note.isNotEmpty ? d.note : null,
          locator: d.locator,
          sourceUrl: d.sourceUrl,
        ),
      );
    }

    // 2. Onde vocês divergem
    // Ordenadas por maior impacto ponderado (rel · z²), considerando z >= 0.65 ou d_comb > 0.35
    // GARANTIA DE NÃO DUPLICAÇÃO: exclui estritamente qualquer dimensão presente no bloco de aproximação
    final candidateDivergences = validDetails
        .where(
          (d) =>
              !approachingIds.contains(d.dimensionId) &&
              (d.normalizedZ >= divergingZThreshold ||
                  d.combinedDistance > approachingDeltaThreshold),
        )
        .toList()
      ..sort((a, b) => b.weightedImpact.compareTo(a.weightedImpact));

    final selectedDivergences = candidateDivergences.take(3).toList();
    final divergingItems = <RaioXDimensionItem>[];

    for (final d in selectedDivergences) {
      final rawDist = double.parse(d.rawDistance.clamp(0.0, 2.0).toStringAsFixed(2));
      final combDist = double.parse(d.combinedDistance.clamp(0.0, 2.0).toStringAsFixed(2));
      final zVal = double.parse(d.normalizedZ.toStringAsFixed(2));
      final weighted = double.parse(d.weightedImpact.toStringAsFixed(2));

      final String mathContrib;
      if (d.isTriad) {
        final engText = d.engagement != 0.5
            ? ' · engajamento = ${d.engagement.toStringAsFixed(2)} (g = ${d.engagementPenalty.toStringAsFixed(2)})'
            : '';
        mathContrib =
            'Δcomp = ${rawDist.toStringAsFixed(2)}$engText · dcomb = ${combDist.toStringAsFixed(2)} · z = ${zVal.toStringAsFixed(2)} · impacto = ${weighted.toStringAsFixed(2)}';
      } else {
        mathContrib =
            'Δ = ${rawDist.toStringAsFixed(2)} · z = ${zVal.toStringAsFixed(2)} · impacto = ${weighted.toStringAsFixed(2)}';
      }

      divergingItems.add(
        RaioXDimensionItem(
          dimensionId: d.dimensionId,
          dimensionLabel: d.dimensionLabel,
          isTriad: d.isTriad,
          userSummary: d.userSummary,
          targetSummary: d.currentSummary,
          deltaDistance: rawDist,
          combinedDistance: combDist,
          compositionDistance: d.compositionDistance,
          engagement: d.engagement,
          engagementPenalty: d.engagementPenalty,
          normalizedZ: zVal,
          relevance: d.relevance,
          weightedImpact: weighted,
          mathematicalContribution: mathContrib,
          catalogNote: d.note.isNotEmpty ? d.note : null,
          locator: d.locator,
          sourceUrl: d.sourceUrl,
        ),
      );
    }

    // 3. O que diferencia essas posições (interpretação conceitual fundamentada)
    final differentiation = _synthesizeDifferentiation(
      targetName: targetName,
      targetKind: targetKindLabel,
      divergences: divergingItems,
      convergences: approachingItems,
      hasStrictProximity: hasStrictProximity,
      summary: summary,
      keyIdeas: keyIdeas,
    );

    final approachingTitle =
        hasStrictProximity ? 'Onde vocês se aproximam' : 'Menores afastamentos relativos';
    final approachingDescription = hasStrictProximity
        ? 'Dimensões observadas em que a distância entre sua resposta e o parâmetro da entidade é pequena.'
        : 'Nenhuma dimensão apresentou proximidade acentuada (todas com z > 0,80 ou afastamento combinado relevante). As dimensões abaixo registram os menores afastamentos relativos apurados no catálogo.';

    return RaioXDiagnostic(
      targetId: targetId,
      targetName: targetName,
      targetKindLabel: targetKindLabel,
      compatibilityPercent: compatibilityPercent,
      approachingSection: RaioXSection(
        title: approachingTitle,
        description: approachingDescription,
        items: List.unmodifiable(approachingItems),
        hasSufficientEvidence: true,
      ),
      divergingSection: RaioXSection(
        title: 'Onde vocês divergem',
        description: divergingItems.isNotEmpty
            ? 'Dimensões com maior afastamento relativo que mais influenciaram a distância total.'
            : 'Nenhuma divergência relevante (z ≥ 0,65) foi observada nas dimensões comparadas.',
        items: List.unmodifiable(divergingItems),
        hasSufficientEvidence: true,
      ),
      conceptualDifferentiation: differentiation,
      evaluatedDimensionsCount: totalDimensions,
    );
  }

  static String _synthesizeDifferentiation({
    required String targetName,
    required String targetKind,
    required List<RaioXDimensionItem> divergences,
    required List<RaioXDimensionItem> convergences,
    required bool hasStrictProximity,
    required String summary,
    required List<String> keyIdeas,
  }) {
    final buffer = StringBuffer();

    if (convergences.isNotEmpty) {
      final topConv = convergences.first;
      if (hasStrictProximity) {
        buffer.write(
          'O maior alinhamento relativo com $targetName concentra-se em ${topConv.dimensionLabel}, '
          'onde suas respostas indicam ${topConv.userSummary} e o catálogo registra ${topConv.targetSummary}. ',
        );
      } else {
        buffer.write(
          'O menor distanciamento relativo em relação a $targetName ocorre em ${topConv.dimensionLabel} '
          '(${topConv.userSummary} vs. ${topConv.targetSummary}), embora ainda sem convergência estrita. ',
        );
      }
    }

    if (divergences.isNotEmpty) {
      final topDiv = divergences.first;
      if (topDiv.isTriad &&
          (topDiv.compositionDistance ?? 0.0) <= 0.20 &&
          (topDiv.engagementPenalty ?? 0.0) >= 0.20) {
        buffer.write(
          'Em ${topDiv.dimensionLabel}, a composição relativa entre os vértices apresenta proximidade '
          '(${topDiv.userSummary} vs. ${topDiv.targetSummary}), porém o distanciamento total decorre '
          'da intensidade de engajamento absoluto (d_comb = ${topDiv.combinedDistance?.toStringAsFixed(2)}, z = ${topDiv.normalizedZ?.toStringAsFixed(2)}). ',
        );
      } else {
        buffer.write(
          'Por outro lado, o distanciamento mais relevante decorre de ${topDiv.dimensionLabel}: '
          'seu perfil aponta para ${topDiv.userSummary}, enquanto a entidade registra ${topDiv.targetSummary}. ',
        );
      }
      if (topDiv.locator != null && topDiv.locator!.isNotEmpty) {
        buffer.write('Fundamentação documental: ${_sentence(topDiv.locator!)} ');
      }
      if (topDiv.catalogNote != null && topDiv.catalogNote!.isNotEmpty) {
        buffer.write('Síntese editorial: ${_sentence(topDiv.catalogNote!)} ');
      }
      if (divergences.length > 1) {
        final secDiv = divergences[1];
        buffer.write(
          'Outro afastamento ponderado aparece em ${secDiv.dimensionLabel} '
          '(${secDiv.userSummary} vs. ${secDiv.targetSummary}). ',
        );
      }
    } else {
      buffer.write(
        'Nas dimensões observadas, não foram identificados afastamentos relativos '
        'expressivos com os parâmetros de $targetName. ',
      );
    }

    if (keyIdeas.isNotEmpty) {
      buffer.write(
        'Em síntese conceitual, a tradição de $targetName fundamenta-se em: '
        '${_sentence(keyIdeas.first)} ',
      );
    } else if (summary.isNotEmpty) {
      buffer.write('Síntese do catálogo: ${_sentence(summary)} ');
    }

    return buffer.toString().trim();
  }

  /// Encerra um trecho do catálogo com exatamente um ponto final, evitando
  /// pontuação duplicada quando o texto de origem já termina em `.`, `!` ou `?`.
  static String _sentence(String raw) {
    final String t = raw.trim();
    if (t.isEmpty) return t;
    return RegExp(r'[.!?…]$').hasMatch(t) ? t : '$t.';
  }
}
