import 'dart:math' as math;

import '../models/atlas_models.dart';
import '../models/political_models.dart';
import 'triad_distance.dart';
import 'compatibility_engine.dart';

/// Motor bidimensional do Diagrama de Nolan (1969) e da Bússola Política 2D.
///
/// Projeta de forma ortogonal e transparente as dimensões avaliadas (12 eixos
/// bipolares, 6 tríades ou ambos no Espectro Integrado) em dois índices
/// contínuos `[0, 100]`:
/// - **Liberdade Econômica**: propriedade privada, livre formação de preços,
///   abertura comercial e menor redistribuição/coletivização estatal;
/// - **Liberdade Pessoal / Civil**: garantias individuais, autonomia moral e
///   cultural, laicidade estatal, limites à vigilância e descentralização do poder.
abstract final class EspectroNolanEngine {
  /// Fronteira interna `[30%, 70%] × [30%, 70%]` que define o losango central
  /// centrista do Diagrama de Nolan original.
  static const double centerMinPercent = 30.0;
  static const double centerMaxPercent = 70.0;

  /// Classifica um par `(economicFreedom, personalFreedom)` nas 5 regiões
  /// canônicas do Diagrama de Nolan.
  static ({String label, String description}) classifyCoordinates(
    double economicFreedom,
    double personalFreedom,
  ) {
    final bool inCenterBox =
        economicFreedom >= centerMinPercent &&
        economicFreedom <= centerMaxPercent &&
        personalFreedom >= centerMinPercent &&
        personalFreedom <= centerMaxPercent;
    if (inCenterBox) {
      return (
        label: 'Centrista / Equilíbrio Misto',
        description:
            'Combina economia mista regulada e equilíbrio pragmático entre '
            'liberdades individuais, coesão institucional e proteção social.',
      );
    }
    if (economicFreedom > 50.0 && personalFreedom > 50.0) {
      return (
        label: 'Libertário / Liberal Integral',
        description:
            'Alta defesa simultânea da autonomia civil e moral do indivíduo '
            'e da livre iniciativa econômica com Estado limitado.',
      );
    }
    if (economicFreedom <= 50.0 && personalFreedom > 50.0) {
      return (
        label: 'Progressista / Esquerda Democrática',
        description:
            'Prioriza amplas liberdades civis, laicidade e emancipação cultural '
            'combinadas a regulação, bens públicos e redistribuição econômica.',
      );
    }
    if (economicFreedom > 50.0 && personalFreedom <= 50.0) {
      return (
        label: 'Conservador / Direita de Ordem',
        description:
            'Combina defesa da propriedade privada e da economia de mercado '
            'com valorização da ordem pública, segurança e tradição moral.',
      );
    }
    return (
      label: 'Estatista / Comunitário-Dirigista',
      description:
          'Prioriza coordenação estatal da economia e soberania coletiva '
          'aliadas a autoridade institucional, segurança e coesão normativa.',
    );
  }

  /// Calcula as coordenadas de Nolan e a incerteza propagada a partir de uma
  /// avaliação do usuário (funciona com eixos, tríades ou ambos).
  static NolanCoordinates? fromEvaluation({
    required List<BipolarDimensionScore> axes,
    required List<TriadDimensionScore> triads,
  }) {
    final Map<String, BipolarDimensionScore> axisMap =
        <String, BipolarDimensionScore>{
          for (final BipolarDimensionScore a in axes)
            if (!a.isIndeterminate) a.axisId: a,
        };
    final Map<int, TriadDimensionScore> triadMap = <int, TriadDimensionScore>{
      for (final TriadDimensionScore t in triads)
        if (!t.isIndeterminate) t.categoryId: t,
    };

    if (axisMap.isEmpty && triadMap.isEmpty) {
      return null;
    }

    final List<_WeightedComponent> econ = <_WeightedComponent>[];
    final List<_WeightedComponent> personal = <_WeightedComponent>[];

    void addAxis(
      List<_WeightedComponent> target,
      String id,
      double sign,
      double weight,
    ) {
      final BipolarDimensionScore? a = axisMap[id];
      if (a == null) return;
      target.add(
        _WeightedComponent(
          value: (sign * a.score).clamp(-1.0, 1.0),
          se: a.standardError,
          weight: weight,
        ),
      );
    }

    // Dimensões de Liberdade Econômica (ortogonais às dimensões civis).
    addAxis(econ, 'economia', 1.0, 1.25); // -1 Público -> +1 Privado
    addAxis(econ, 'controle', 1.0, 1.25); // -1 Planejamento -> +1 Livre mercado
    addAxis(econ, 'comercio', 1.0, 0.55); // -1 Protecionismo -> +1 Globalismo

    final TriadDimensionScore? triEcon = triadMap[0];
    if (triEcon != null) {
      // [Controle, Regulação, Mercados]
      final List<double> p = triEcon.composition;
      econ.add(
        _WeightedComponent(
          value: (p[2] - p[0]).clamp(-1.0, 1.0),
          se: (triEcon.standardError * math.sqrt2).clamp(0.02, 1.0),
          weight: 1.15,
        ),
      );
    }
    final TriadDimensionScore? triEq = triadMap[5];
    if (triEq != null) {
      // [Oportunidade, Resultado, Ônus]
      final List<double> p = triEq.composition;
      econ.add(
        _WeightedComponent(
          value: (0.35 * p[0] + 1.0 * p[2] - 1.0 * p[1]).clamp(-1.0, 1.0),
          se: (triEq.standardError * math.sqrt2).clamp(0.02, 1.0),
          weight: 0.70,
        ),
      );
    }

    // Dimensões de Liberdade Pessoal / Civil.
    addAxis(personal, 'poder', 1.0, 1.40); // -1 Segurança -> +1 Liberdade
    addAxis(
      personal,
      'representacao',
      -1.0,
      0.85,
    ); // -1 Democracia -> +1 Autocracia
    addAxis(
      personal,
      'moral',
      -1.0,
      0.75,
    ); // -1 Progressista -> +1 Tradicionalista
    addAxis(personal, 'religiao', -1.0, 0.60); // -1 Irreligioso -> +1 Religioso
    addAxis(
      personal,
      'diplomacia',
      1.0,
      0.45,
    ); // -1 Militarista -> +1 Pacifista
    addAxis(
      personal,
      'imigracao',
      1.0,
      0.40,
    ); // -1 Assimilação -> +1 Multicultura
    addAxis(personal, 'estrutura', -1.0, 0.35); // -1 Federal -> +1 Unitário

    final TriadDimensionScore? triLib = triadMap[1];
    if (triLib != null) {
      // [Liberdade, Segurança, Verdade]
      final List<double> p = triLib.composition;
      personal.add(
        _WeightedComponent(
          value: (p[0] - p[1] - 0.25 * p[2]).clamp(-1.0, 1.0),
          se: (triLib.standardError * math.sqrt2).clamp(0.02, 1.0),
          weight: 1.25,
        ),
      );
    }
    final TriadDimensionScore? triCult = triadMap[2];
    if (triCult != null) {
      // [Tradição, Progresso, Liberdade]
      final List<double> p = triCult.composition;
      personal.add(
        _WeightedComponent(
          value: (p[2] + 0.45 * p[1] - 0.85 * p[0]).clamp(-1.0, 1.0),
          se: (triCult.standardError * math.sqrt2).clamp(0.02, 1.0),
          weight: 0.90,
        ),
      );
    }
    final TriadDimensionScore? triGov = triadMap[4];
    if (triGov != null) {
      // [Democracia, Autoridade, Minarquia]
      final List<double> p = triGov.composition;
      personal.add(
        _WeightedComponent(
          value: (0.85 * p[2] + 0.55 * p[0] - 1.0 * p[1]).clamp(-1.0, 1.0),
          se: (triGov.standardError * math.sqrt2).clamp(0.02, 1.0),
          weight: 0.95,
        ),
      );
    }

    if (econ.isEmpty || personal.isEmpty) {
      return null;
    }

    final ({double percent, double se}) econAgg = _aggregate(econ);
    final ({double percent, double se}) persAgg = _aggregate(personal);
    final ({String label, String description}) quad = classifyCoordinates(
      econAgg.percent,
      persAgg.percent,
    );

    return NolanCoordinates(
      economicFreedom: econAgg.percent,
      personalFreedom: persAgg.percent,
      economicSe: econAgg.se,
      personalSe: persAgg.se,
      quadrantLabel: quad.label,
      quadrantDescription: quad.description,
    );
  }

  /// Calcula as coordenadas exatas de Nolan a partir de mapas brutos de eixos e tríades
  /// (usado para correntes ideológicas e entradas do Atlas Político).
  static NolanCoordinates? fromRawMaps({
    required Map<String, double> axes,
    required Map<int, List<double>> triangles,
  }) {
    final List<BipolarDimensionScore> synthAxes = <BipolarDimensionScore>[
      for (final MapEntry<String, double> e in axes.entries)
        if (e.value.isFinite && e.value >= -1 && e.value <= 1)
          BipolarDimensionScore(
            axisId: e.key,
            label: e.key,
            leftPole: 'L',
            rightPole: 'R',
            score: e.value.clamp(-1.0, 1.0),
            standardError: 0.05,
            coverage: 1.0,
            answeredCount: 4,
            presentedCount: 4,
            tensionScore: 0.0,
          ),
    ];
    final List<TriadDimensionScore> synthTriads = <TriadDimensionScore>[
      for (final MapEntry<int, List<double>> e in triangles.entries)
        if (e.key >= 0 &&
            e.key <= 5 &&
            e.value.length == 3 &&
            e.value.every((v) => v.isFinite && v >= 0 && v <= 1) &&
            (e.value.fold<double>(0, (a, b) => a + b) - 1).abs() < .02)
          TriadDimensionScore(
            categoryId: e.key,
            label: 'T${e.key}',
            vertices: const <String>['A', 'B', 'C'],
            vertexScores: const <double>[0, 0, 0],
            vertexSupport: e.value,
            composition: e.value,
            engagement: 0.5,
            standardError: 0.05,
            coverage: 1.0,
            answeredCount: 6,
            presentedCount: 6,
            classification: '',
          ),
    ];

    return fromEvaluation(axes: synthAxes, triads: synthTriads);
  }

  static NolanReferencePin? fromCurrent(IdeologicalCurrent current) {
    final NolanCoordinates? coords = fromRawMaps(
      axes: <String, double>{
        for (final MapEntry<String, CurrentAxisProfile> e
            in current.axes.entries)
          if (e.value.relevance > 0) e.key: e.value.mu,
      },
      triangles: <int, List<double>>{
        for (final MapEntry<int, CurrentTriadProfile> e
            in current.triangles.entries)
          if (e.value.relevance > 0) e.key: e.value.mu,
      },
    );
    if (coords == null) return null;
    return NolanReferencePin(
      id: current.id,
      label: current.name,
      category: current.family,
      economicFreedom: coords.economicFreedom,
      personalFreedom: coords.personalFreedom,
      quadrantLabel: coords.quadrantLabel,
    );
  }

  static NolanReferencePin? fromAtlasEntry(AtlasEntry entry) {
    final NolanCoordinates? coords = fromRawMaps(
      axes: entry.axes,
      triangles: entry.triangles,
    );
    if (coords == null) return null;
    return NolanReferencePin(
      id: entry.id,
      label: entry.name,
      category: entry.category,
      economicFreedom: coords.economicFreedom,
      personalFreedom: coords.personalFreedom,
      quadrantLabel: coords.quadrantLabel,
    );
  }

  static ({double percent, double se}) _aggregate(
    List<_WeightedComponent> items,
  ) {
    var wSum = 0.0;
    var valSum = 0.0;
    var varSum = 0.0;
    for (final _WeightedComponent c in items) {
      wSum += c.weight;
      valSum += c.weight * c.value;
      final double wSe = c.weight * c.se;
      varSum += wSe * wSe;
    }
    if (wSum <= 0) return (percent: 50.0, se: 15.0);
    final double mean = (valSum / wSum).clamp(-1.0, 1.0);
    final double seMean = math.sqrt(varSum) / wSum;
    return (
      percent: (50.0 * (1.0 + mean)).clamp(0.0, 100.0),
      se: (50.0 * seMean).clamp(1.5, 30.0),
    );
  }
}

class _WeightedComponent {
  const _WeightedComponent({
    required this.value,
    required this.se,
    required this.weight,
  });

  final double value;
  final double se;
  final double weight;
}

/// Motor de afinidade com o Atlas Político (Personalidades, Partidos/Movimentos,
/// História/Regimes e Livros), sínteses temáticas de valores e detecção de
/// combinações doutrinárias singulares.
abstract final class EspectroAtlasEngine {
  /// Tolerância padrão `σ` das entradas do Atlas (personalidades, partidos,
  /// períodos históricos e obras).
  static const double defaultAtlasAxisSigma = 0.32;
  static const double defaultAtlasTriadSigma = 0.24;

  /// Ordena as entradas de qualquer acervo do Atlas por compatibilidade contínua
  /// `100 · exp(-D² / 2)` com o perfil avaliado do usuário.
  static List<AtlasMatchResult> rankEntries({
    required List<AtlasEntry> entries,
    required List<BipolarDimensionScore> axes,
    required List<TriadDimensionScore> triads,
  }) {
    final List<BipolarDimensionScore> validAxes = axes
        .where((a) => !a.isIndeterminate)
        .toList();
    final List<TriadDimensionScore> validTriads = triads
        .where((t) => !t.isIndeterminate)
        .toList();

    if (entries.isEmpty || (validAxes.isEmpty && validTriads.isEmpty)) {
      return const <AtlasMatchResult>[];
    }

    final List<AtlasMatchResult> ranked = <AtlasMatchResult>[];

    for (final AtlasEntry entry in entries) {
      var z2Sum = 0.0;
      var count = 0;
      final List<_AtlasDimDelta> deltas = <_AtlasDimDelta>[];

      for (final BipolarDimensionScore axis in validAxes) {
        final double? target = entry.axes[axis.axisId];
        if (target == null) continue;
        final double dist = (axis.score - target).abs();
        final double denom = math.sqrt(
          defaultAtlasAxisSigma * defaultAtlasAxisSigma +
              axis.standardError * axis.standardError,
        );
        final double z = dist / math.max(0.05, denom);
        z2Sum += z * z;
        count++;
        deltas.add(
          _AtlasDimDelta(
            z: z,
            summary:
                '${axis.label}: ${_describeAxisValue(target, axis.leftPole, axis.rightPole)}',
          ),
        );
      }

      for (final TriadDimensionScore triad in validTriads) {
        final List<double>? target = entry.triangles[triad.categoryId];
        if (target == null || target.length != 3) continue;
        final TriadDistanceBreakdown breakdown = measureTriadDistance(
          composition: triad.composition,
          engagement: triad.engagement,
          target: target,
        );
        final double denom = math.sqrt(
          defaultAtlasTriadSigma * defaultAtlasTriadSigma +
              triad.standardError * triad.standardError,
        );
        final double z = breakdown.combinedDistance / math.max(0.05, denom);
        z2Sum += z * z;
        count++;
        deltas.add(
          _AtlasDimDelta(
            z: z,
            summary:
                '${triad.label}: ${_describeTriadValue(target, triad.vertices)}',
          ),
        );
      }

      if (count == 0) continue;
      final double d2 = z2Sum / count;
      final double compat = (100.0 * math.exp(-d2 / 2.0)).clamp(0.0, 100.0);

      final List<_AtlasDimDelta> asc = <_AtlasDimDelta>[...deltas]
        ..sort((a, b) => a.z.compareTo(b.z));
      final List<_AtlasDimDelta> desc = <_AtlasDimDelta>[...deltas]
        ..sort((a, b) => b.z.compareTo(a.z));

      ranked.add(
        AtlasMatchResult(
          entry: entry,
          compatibilityPercent: compat,
          rmsZ: math.sqrt(d2),
          convergences: <String>[for (final d in asc.take(3)) d.summary],
          divergences: <String>[
            for (final d in desc.where((x) => x.z > 0.65).take(3)) d.summary,
          ],
        ),
      );
    }

    ranked.sort((a, b) {
      final int cmp = b.compatibilityPercent.compareTo(a.compatibilityPercent);
      if (cmp != 0) return cmp;
      return a.entry.name.compareTo(b.entry.name);
    });
    return ranked;
  }

  /// Seleciona leituras afins ao perfil do usuário e contrapontos clássicos de
  /// matrizes distintas para estimular pluralismo intelectual.
  static BookRecommendationReport recommendBooks({
    required List<AtlasEntry> books,
    required List<BipolarDimensionScore> axes,
    required List<TriadDimensionScore> triads,
  }) {
    final List<AtlasMatchResult> ranked = rankEntries(
      entries: books,
      axes: axes,
      triads: triads,
    );
    if (ranked.isEmpty) {
      return const BookRecommendationReport(
        affinityBooks: <AtlasMatchResult>[],
        counterpointBooks: <AtlasMatchResult>[],
      );
    }

    final List<AtlasMatchResult> affinity = ranked.take(6).toList();
    final Set<String> usedIds = affinity.map((m) => m.entry.id).toSet();
    final Set<String> usedCategories = <String>{};
    final List<AtlasMatchResult> counterpoints = <AtlasMatchResult>[];

    // Percorre da menor compatibilidade para cima, priorizando diversidade temática.
    for (var i = ranked.length - 1; i >= 0 && counterpoints.length < 4; i--) {
      final AtlasMatchResult candidate = ranked[i];
      if (usedIds.contains(candidate.entry.id)) continue;
      if (candidate.compatibilityPercent > 52.0 && ranked.length > 10) continue;
      if (usedCategories.add(candidate.entry.category)) {
        counterpoints.add(candidate);
        usedIds.add(candidate.entry.id);
      }
    }
    for (var i = ranked.length - 1; i >= 0 && counterpoints.length < 4; i--) {
      final AtlasMatchResult candidate = ranked[i];
      if (usedIds.add(candidate.entry.id)) {
        counterpoints.add(candidate);
      }
    }

    return BookRecommendationReport(
      affinityBooks: affinity,
      counterpointBooks: counterpoints,
    );
  }

  /// Deriva até 6 valores políticos nomeados sintetizando as escolhas do usuário
  /// por grandes arenas temáticas.
  static List<ThematicSynthesis> computeSyntheses({
    required List<BipolarDimensionScore> axes,
    required List<TriadDimensionScore> triads,
  }) {
    final Map<String, BipolarDimensionScore> ax =
        <String, BipolarDimensionScore>{
          for (final BipolarDimensionScore a in axes)
            if (!a.isIndeterminate) a.axisId: a,
        };
    final Map<int, TriadDimensionScore> tr = <int, TriadDimensionScore>{
      for (final TriadDimensionScore t in triads)
        if (!t.isIndeterminate) t.categoryId: t,
    };

    final List<ThematicSynthesis> out = <ThematicSynthesis>[];

    // 1. Ordem Econômica
    final List<double> econVals = <double>[
      if (ax['economia'] != null) ax['economia']!.score,
      if (ax['controle'] != null) ax['controle']!.score,
      if (tr[0] != null) tr[0]!.composition[2] - tr[0]!.composition[0],
    ];
    if (econVals.isNotEmpty) {
      final double m = _mean(econVals);
      final (String title, String summary) = switch (m) {
        <= -0.50 => (
          'Socialização e Planejamento Estratégico',
          'Defende forte direção pública sobre setores-chave, investimento coordenado e primazia de bens coletivos sobre o lucro privado.',
        ),
        <= -0.16 => (
          'Economia Social e Regulação Ativa',
          'Combina iniciativa privada regulada com políticas industriais, serviços públicos universais e correção ativa de falhas de mercado.',
        ),
        < 0.16 => (
          'Economia Mista Pragmática',
          'Equilibra livre concorrência com regulação pública seletiva e provisão estatal onde o mercado não alcança eficiência social.',
        ),
        < 0.52 => (
          'Economia de Mercado e Livre Iniciativa',
          'Prioriza propriedade privada, formação livre de preços e responsabilidade fiscal, reservando ao Estado papel regulatório enxuto.',
        ),
        _ => (
          'Laissez-Faire e Desregulamentação Ampla',
          'Aposta na coordenação espontânea de preços, privatizações amplas e mínima interferência estatal sobre contratos e capital.',
        ),
      };
      out.add(
        ThematicSynthesis(
          arena: 'Ordem Econômica',
          title: title,
          summary: summary,
          intensity: m.abs().clamp(0.18, 1.0),
        ),
      );
    }

    // 2. Arquitetura de Estado e Liberdades Civis
    final List<double> stateVals = <double>[
      if (ax['poder'] != null) ax['poder']!.score,
      if (ax['representacao'] != null) -ax['representacao']!.score,
      if (ax['estrutura'] != null) -0.6 * ax['estrutura']!.score,
      if (tr[1] != null) tr[1]!.composition[0] - tr[1]!.composition[1],
      if (tr[4] != null)
        0.75 * tr[4]!.composition[2] +
            0.55 * tr[4]!.composition[0] -
            tr[4]!.composition[1],
    ];
    if (stateVals.isNotEmpty) {
      final double m = _mean(stateVals);
      final (String title, String summary) = switch (m) {
        <= -0.45 => (
          'Estado Forte de Ordem e Autoridade',
          'Prioriza capacidade decisória concentrada, segurança preventiva e coesão institucional acima de freios descentralizados.',
        ),
        <= -0.14 => (
          'Institucionalismo Securitário',
          'Aceita instrumentos firmes de vigilância, coordenação central e tutela estatal para preservar estabilidade e ordem pública.',
        ),
        < 0.16 => (
          'Constitucionalismo de Freios e Contrapesos',
          'Busca equilíbrio entre eficácia governamental, participação democrática e proteção das garantias fundamentais.',
        ),
        < 0.50 => (
          'Democracia Garantista e Descentralizada',
          'Valoriza privacidade, devido processo legal amplo, controle cidadão sobre governantes e autonomia local/federativa.',
        ),
        _ => (
          'Autonomia Civil Radical e Poder Limitado',
          'Rejeita vigilância estatal e concentração executiva, defendendo máxima liberdade individual, autogoverno e descentralização.',
        ),
      };
      out.add(
        ThematicSynthesis(
          arena: 'Estado, Poder e Garantias',
          title: title,
          summary: summary,
          intensity: m.abs().clamp(0.18, 1.0),
        ),
      );
    }

    // 3. Sociedade, Moral e Laicidade
    final List<double> cultVals = <double>[
      if (ax['moral'] != null) ax['moral']!.score, // +1 Tradicionalista
      if (ax['religiao'] != null) ax['religiao']!.score, // +1 Religioso
      if (tr[2] != null) tr[2]!.composition[0] - tr[2]!.composition[1],
    ];
    if (cultVals.isNotEmpty) {
      final double m = _mean(cultVals);
      final bool highCulturalLiberty =
          tr[2] != null && tr[2]!.composition[2] >= 0.46 && m.abs() < 0.32;
      final (String title, String summary) = highCulturalLiberty
          ? (
              'Pluralismo Civil e Neutralidade Cultural',
              'Prefere que o Estado permaneça neutro diante de escolhas morais e religiosas, garantindo liberdade igual a diferentes modos de vida.',
            )
          : switch (m) {
              <= -0.45 => (
                'Emancipação Progressista e Laicidade Estrita',
                'Defende reforma ativa de costumes, autonomia corporal, pluralidade familiar e separação rigorosa entre igrejas e Estado.',
              ),
              <= -0.15 => (
                'Humanismo Secular e Inclusivo',
                'Inclina-se à ampliação de direitos civis contemporâneos e ao ensino público secular, com respeito à liberdade de crença.',
              ),
              < 0.16 => (
                'Pluralismo Moderado nos Costumes',
                'Combina abertura gradual a mudanças sociais com apreço por vínculos comunitários e convivência entre laicidade e fé.',
              ),
              < 0.48 => (
                'Conservadorismo Cívico e Prudencial',
                'Valoriza continuidade institucional, família tradicional e presença pública da herança moral e religiosa na sociedade.',
              ),
              _ => (
                'Tradicionalismo Moral e Identitário',
                'Prioriza preservação de normas morais clássicas, identidade cultural histórica e reconhecimento público de valores religiosos.',
              ),
            };
      out.add(
        ThematicSynthesis(
          arena: 'Sociedade, Moral e Laicidade',
          title: title,
          summary: summary,
          intensity: highCulturalLiberty
              ? tr[2]!.composition[2].clamp(0.25, 1.0)
              : m.abs().clamp(0.18, 1.0),
        ),
      );
    }

    // 4. Diplomacia, Comércio e Fronteiras
    final List<double> worldVals = <double>[
      if (ax['comercio'] != null) ax['comercio']!.score, // +1 Globalismo
      if (ax['imigracao'] != null) ax['imigracao']!.score, // +1 Multicultura
      if (ax['diplomacia'] != null) ax['diplomacia']!.score, // +1 Pacifista
      if (ax['intervencao'] != null) -ax['intervencao']!.score,
      if (tr[3] != null)
        tr[3]!.composition[2] -
            0.6 * tr[3]!.composition[0] -
            0.5 * tr[3]!.composition[1],
    ];
    if (worldVals.isNotEmpty) {
      final double m = _mean(worldVals);
      final (String title, String summary) = switch (m) {
        <= -0.42 => (
          'Soberanismo Nacional e Dissuasão',
          'Prioriza proteção produtiva doméstica, controle rigoroso de fronteiras, interesse nacional ativo e capacidade militar própria.',
        ),
        <= -0.14 => (
          'Realismo Autonomista',
          'Vê acordos externos com pragmatismo seletivo, preservando margem de política industrial, defesa nacional e integração exigente.',
        ),
        < 0.16 => (
          'Inserção Internacional Equilibrada',
          'Combina cooperação multilateral e comércio externo com salvaguardas estratégicas e defesa proporcional da soberania.',
        ),
        < 0.45 => (
          'Multilateralismo Cooperativo e Aberto',
          'Favorece integração comercial, solução pacífica de controvérsias, acolhimento plural e governança internacional compartilhada.',
        ),
        _ => (
          'Cosmopolitismo Pacifista e Fronteiras Abertas',
          'Aposta em livre circulação, desmilitarização progressiva, multiculturalismo amplo e instituições globais vinculantes.',
        ),
      };
      out.add(
        ThematicSynthesis(
          arena: 'Diplomacia e Inserção Global',
          title: title,
          summary: summary,
          intensity: m.abs().clamp(0.18, 1.0),
        ),
      );
    }

    // 5. Justiça e Igualdade
    if (tr[5] != null || ax['economia'] != null) {
      final List<double>? eq = tr[5]?.composition;
      final String title;
      final String summary;
      final double intensity;
      if (eq != null) {
        if (eq[1] >= eq[0] && eq[1] >= eq[2] && eq[1] > 0.40) {
          title = 'Igualdade Substantiva de Resultados';
          summary = 'Entende que liberdades formais são insuficientes sem redução direta das disparidades materiais de renda, patrimônio e poder.';
          intensity = eq[1];
        } else if (eq[2] >= eq[0] && eq[2] >= eq[1] && eq[2] > 0.40) {
          title = 'Isonomia Formal e Ônus Proporcional';
          summary = 'Prioriza regras universais idênticas e tributação enxuta sem engenharia redistributiva sobre os resultados de mercado.';
          intensity = eq[2];
        } else {
          title = 'Igualdade de Oportunidades e Mérito';
          summary = 'Defende nivelamento robusto do ponto de partida (educação, saúde e acesso) combinado à recompensa pelo esforço individual.';
          intensity = eq[0];
        }
      } else {
        final double s = ax['economia']!.score;
        title = s < -0.2
            ? 'Universalismo Redistributivo'
            : (s > 0.2
                  ? 'Mérito e Responsabilidade Individual'
                  : 'Equidade Mista');
        summary = s < -0.2
            ? 'Prioriza tributação progressiva e serviços públicos universais gratuitos como base da cidadania.'
            : (s > 0.2
                  ? 'Prioriza recompensa à produtividade, menor carga fiscal e escolha privada na provisão de serviços.'
                  : 'Combina rede pública essencial de proteção com estímulo à iniciativa privada.');
        intensity = s.abs().clamp(0.25, 1.0);
      }
      out.add(
        ThematicSynthesis(
          arena: 'Justiça Distributiva',
          title: title,
          summary: summary,
          intensity: intensity.clamp(0.20, 1.0),
        ),
      );
    }

    // 6. Ciência, Tecnologia e Ecologia
    if (ax['tecnologia'] != null) {
      final double s = ax['tecnologia']!.score; // -1 Tecnologia -> +1 Biologia
      final (String title, String summary) = switch (s) {
        <= -0.35 => (
          'Vanguarda Tecnológica e Aceleração Científica',
          'Confia em automação, IA, biotecnologia e inovação energética como vetores centrais de superação da escassez.',
        ),
        >= 0.35 => (
          'Precaução Bioética e Primazia Ecológica',
          'Prioriza limites ecológicos, conservação de ecossistemas e cautela ética diante de manipulação genética e vigilância algorítmica.',
        ),
        _ => (
          'Inovação Sustentável sob Governança Ética',
          'Apoia avanço científico e transição tecnológica desde que submetidos a salvaguardas ambientais e bioéticas claras.',
        ),
      };
      out.add(
        ThematicSynthesis(
          arena: 'Tecnologia e Bioética',
          title: title,
          summary: summary,
          intensity: s.abs().clamp(0.22, 1.0),
        ),
      );
    }

    return out;
  }

  /// Identifica combinações cruzadas pouco convencionais no perfil do usuário
  /// (mostrando por que o Espectro evita rótulos unidimensionais).
  static List<DoctrinalTension> detectDoctrinalTensions({
    required List<BipolarDimensionScore> axes,
    required List<TriadDimensionScore> triads,
  }) {
    final Map<String, double> ax = <String, double>{
      for (final BipolarDimensionScore a in axes)
        if (!a.isIndeterminate) a.axisId: a.score,
    };
    final Map<int, List<double>> tr = <int, List<double>>{
      for (final TriadDimensionScore t in triads)
        if (!t.isIndeterminate) t.categoryId: t.composition,
    };

    final List<DoctrinalTension> out = <DoctrinalTension>[];

    final double? econ =
        ax['economia'] ?? (tr[0] != null ? tr[0]![2] - tr[0]![0] : null);
    final double? ctrl = ax['controle'];
    final double? moral =
        ax['moral'] ?? (tr[2] != null ? tr[2]![0] - tr[2]![1] : null);
    final double? poder =
        ax['poder'] ?? (tr[1] != null ? tr[1]![0] - tr[1]![1] : null);
    final double? comercio = ax['comercio'];
    final double? estrutura = ax['estrutura'];
    final double? tech = ax['tecnologia'];

    // 1. Economia pública/social + costumes tradicionais
    if (econ != null && moral != null && econ < -0.28 && moral > 0.28) {
      out.add(
        const DoctrinalTension(
          title: 'Solidariedade Econômica com Tradição Moral',
          description:
              'Você combina preferência por presença pública/redistribuição na '
              'economia com valorização de costumes e instituições tradicionais — '
              'síntese típica do trabalhismo cristão, distributismo ou conservadorismo social.',
        ),
      );
    }

    // 2. Livre mercado + protecionismo comercial
    if ((ctrl ?? econ ?? 0) > 0.28 && comercio != null && comercio < -0.28) {
      out.add(
        const DoctrinalTension(
          title: 'Capitalismo Doméstico com Soberania Comercial',
          description:
              'Suas respostas favorecem propriedade privada e livre iniciativa '
              'interna, mas rejeitam abertura comercial irrestrita — perfil '
              'próximo do nacionalismo econômico de mercado.',
        ),
      );
    }

    // 3. Liberdade econômica alta + segurança/autoridade forte
    if (econ != null && poder != null && econ > 0.30 && poder < -0.30) {
      out.add(
        const DoctrinalTension(
          title: 'Ordem Securitária com Economia Privada',
          description:
              'Você separa claramente desregulamentação econômica de permissividade '
              'penal/civil, combinando mercado privado com Estado firme na segurança pública.',
        ),
      );
    }

    // 4. Economia socialista/pública + alta liberdade civil e federalismo
    if (econ != null &&
        poder != null &&
        econ < -0.30 &&
        poder > 0.35 &&
        (estrutura == null || estrutura < -0.20)) {
      out.add(
        const DoctrinalTension(
          title: 'Anticapitalismo Libertário e Descentralizado',
          description:
              'Você apoia socialização econômica, mas rejeita concentração burocrática '
              'e vigilância estatal — convergindo com tradições autogestionárias, '
              'municipalistas ou libertárias de esquerda.',
        ),
      );
    }

    // 5. Progressismo moral + cautela ecológica/bioconservadora forte
    if (moral != null && tech != null && moral < -0.28 && tech > 0.35) {
      out.add(
        const DoctrinalTension(
          title: 'Emancipação Social com Precaução Ecológica',
          description:
              'Você apoia reformas progressistas nos direitos civis, mas adota '
              'forte princípio da precaução diante de biotecnologia, IA e pressão '
              'industrial sobre ecossistemas.',
        ),
      );
    }

    // 6. Tradicionalismo moral + aceleração tecnológica
    if (moral != null && tech != null && moral > 0.28 && tech < -0.35) {
      out.add(
        const DoctrinalTension(
          title: 'Conservadorismo Moral Pró-Aceleração Tecnológica',
          description:
              'Suas escolhas unem preservação de valores morais clássicos a forte '
              'entusiasmo por fronteiras tecnológicas, energia avançada e automação.',
        ),
      );
    }

    return out;
  }

  static double _mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    var sum = 0.0;
    for (final double v in values) {
      sum += v;
    }
    return sum / values.length;
  }

  static String _describeAxisValue(
    double val,
    String leftPole,
    String rightPole,
  ) {
    final int rightPct = (50.0 * (1.0 + val)).round().clamp(0, 100);
    final int leftPct = 100 - rightPct;
    if (val.abs() < 0.15) return 'Equilíbrio ($leftPct/$rightPct)';
    return val < 0 ? '$leftPct% $leftPole' : '$rightPct% $rightPole';
  }

  static String _describeTriadValue(List<double> shares, List<String> verts) {
    var top = 0;
    for (var i = 1; i < 3; i++) {
      if (shares[i] > shares[top]) top = i;
    }
    return '${verts[top]} ${(shares[top] * 100).round()}%';
  }

  /// Realiza a comparação analítica entre o resultado do usuário e uma entrada
  /// do Atlas (País, Personalidade, Partido, Era Histórica ou Livro).
  static EntityComparisonResult compareWithAtlasEntry({
    required AtlasEntry entry,
    required List<BipolarDimensionScore> userAxes,
    required List<TriadDimensionScore> userTriads,
  }) {
    final match = rankEntries(
      entries: [entry],
      axes: userAxes,
      triads: userTriads,
    ).firstOrNull;
    return _entityComparison(
      targetId: entry.id,
      name: entry.name,
      subtitle: entry.subtitle,
      kind: entry.kind.singularLabel,
      summary: entry.summary,
      targetAxes: entry.axes,
      targetTriads: entry.triangles,
      userAxes: userAxes,
      userTriads: userTriads,
      compatibility: match?.compatibilityPercent,
    );
  }

  static EntityComparisonResult compareWithCurrent({
    required IdeologicalCurrent current,
    required List<BipolarDimensionScore> userAxes,
    required List<TriadDimensionScore> userTriads,
  }) {
    final match = EspectroCompatibilityEngine.evaluate(
      catalog: IdeologicalCatalog(
        schemaVersion: 1,
        catalogVersion: 'comparison',
        currents: [current],
      ),
      axes: userAxes,
      triads: userTriads,
    ).ranked.firstOrNull;
    return _entityComparison(
      targetId: current.id,
      name: current.name,
      subtitle: current.family,
      kind: 'Corrente Ideológica',
      summary: current.summary,
      targetAxes: {
        for (final e in current.axes.entries)
          if (e.value.relevance > 0) e.key: e.value.mu,
      },
      targetTriads: {
        for (final e in current.triangles.entries)
          if (e.value.relevance > 0) e.key: e.value.mu,
      },
      userAxes: userAxes,
      userTriads: userTriads,
      compatibility: match?.compatibilityPercent,
    );
  }

  static EntityComparisonResult _entityComparison({
    required String targetId,
    required String name,
    required String subtitle,
    required String kind,
    required String summary,
    required Map<String, double> targetAxes,
    required Map<int, List<double>> targetTriads,
    required List<BipolarDimensionScore> userAxes,
    required List<TriadDimensionScore> userTriads,
    required double? compatibility,
  }) {
    final axisDeltas = <String, double>{
      for (final axis in userAxes)
        if (!axis.isIndeterminate && targetAxes.containsKey(axis.axisId))
          axis.axisId: axis.score - targetAxes[axis.axisId]!,
    };
    final triadDeltas = <int, double>{
      for (final triad in userTriads)
        if (!triad.isIndeterminate &&
            targetTriads.containsKey(triad.categoryId))
          triad.categoryId: measureTriadDistance(
            composition: triad.composition,
            engagement: triad.engagement,
            target: targetTriads[triad.categoryId]!,
          ).combinedDistance,
    };
    final ordered = axisDeltas.entries.toList()
      ..sort((a, b) => a.value.abs().compareTo(b.value.abs()));
    final distances = [...axisDeltas.values, ...triadDeltas.values];
    return EntityComparisonResult(
      targetId: targetId,
      targetName: name,
      targetSubtitle: subtitle,
      targetKindLabel: kind,
      compatibilityPercent: distances.isEmpty ? null : compatibility,
      rmsd: distances.isEmpty
          ? null
          : math.sqrt(
              distances.fold<double>(0, (sum, v) => sum + v * v) /
                  distances.length,
            ),
      nolanUser: EspectroNolanEngine.fromEvaluation(
        axes: userAxes,
        triads: userTriads,
      ),
      nolanTarget: EspectroNolanEngine.fromRawMaps(
        axes: targetAxes,
        triangles: targetTriads,
      ),
      axisDeltas: Map.unmodifiable(axisDeltas),
      triadDeltas: Map.unmodifiable(triadDeltas),
      convergentAxes: ordered
          .where((d) => d.value.abs() <= .5)
          .take(3)
          .map((d) => d.key)
          .toList(),
      divergentAxes: ordered.reversed
          .where((d) => d.value.abs() > .5)
          .take(3)
          .map((d) => d.key)
          .toList(),
      summary: summary,
    );
  }
}

class _AtlasDimDelta {
  const _AtlasDimDelta({required this.z, required this.summary});

  final double z;
  final String summary;
}
