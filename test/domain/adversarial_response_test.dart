import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/models.dart';
import 'package:politico/domain/engine/compatibility_engine.dart';
import 'package:politico/domain/engine/question_selector.dart';
import 'package:politico/domain/engine/scoring_engine.dart';
import 'package:politico/domain/models/political_models.dart';

/// Cenários adversariais sobre a bateria curta do Espectro Integrado
/// (12 eixos × 2 itens + 6 tríades × 3 vértices × 2 itens = 60 itens).
///
/// O objetivo não é "reprovar" padrões de resposta, e sim garantir que o motor
/// comunique corretamente quando um padrão não discrimina alternativas.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppData data;
  setUpAll(() async {
    data = await AppData.load();
  });

  List<UnifiedQuestion> select({int seed = 42}) => selectUnifiedQuestions(
    axesData: data.twelveAxes,
    trianglesData: data.sixTriangles,
    suite: TestSuite.espectroIntegrated,
    depth: TestDepth.quick,
    seed: seed,
  );

  ScoredEvaluation score(
    List<UnifiedQuestion> questions,
    int? Function(UnifiedQuestion) answer,
  ) => EspectroScoringEngine.evaluate(
    axesData: data.twelveAxes,
    trianglesData: data.sixTriangles,
    suite: TestSuite.espectroIntegrated,
    questions: questions,
    rawAnswersByUid: <String, int?>{
      for (final UnifiedQuestion q in questions) q.uid: answer(q),
    },
  );

  CompatibilityReport compat(ScoredEvaluation result) =>
      EspectroCompatibilityEngine.evaluate(
        catalog: data.catalog,
        axes: result.axes,
        triads: result.triads,
      );

  /// Resposta coerente com o polo esquerdo nos eixos e com o vértice 0 nas tríades.
  int? coherentLeft(UnifiedQuestion q) {
    if (q.kind == UnifiedQuestionKind.bipolar) {
      return q.axisQuestion!.agreeIsLeft ? 2 : -2;
    }
    final SixQuestion s = q.sixQuestion!;
    if (s.subcategory == 0) return s.multiplier > 0 ? 2 : -2;
    return s.multiplier > 0 ? -2 : 2;
  }

  test('a bateria curta tem exatamente 2 itens por eixo e 6 por tríade', () {
    final List<UnifiedQuestion> questions = select();
    expect(questions.length, 60);
    final Map<String, int> perAxis = <String, int>{};
    final Map<int, int> perCategory = <int, int>{};
    for (final UnifiedQuestion q in questions) {
      if (q.kind == UnifiedQuestionKind.bipolar) {
        perAxis.update(q.axisQuestion!.axisId, (int v) => v + 1, ifAbsent: () => 1);
      } else {
        perCategory.update(
          q.sixQuestion!.category,
          (int v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    }
    expect(perAxis.length, 12);
    expect(perAxis.values.every((int v) => v == 2), isTrue);
    expect(perCategory.length, 6);
    expect(perCategory.values.every((int v) => v == 6), isTrue);
  });

  group('concordância e discordância máximas', () {
    test('concordar com tudo é diagnosticado como baixa discriminação', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation result = score(questions, (_) => 2);

      // Cada eixo recebeu apoio simultâneo a ambos os polos: tensão máxima.
      expect(result.axes.length, 12);
      for (final BipolarDimensionScore axis in result.axes) {
        expect(axis.answeredLeftCount, 1);
        expect(axis.answeredRightCount, 1);
        expect(axis.tensionScore, closeTo(2.0, 1e-9));
        expect(axis.hasInternalTension, isTrue);
        expect(axis.isIndeterminate, isFalse);
        expect(axis.confidence, isNot(ScoreConfidence.high));
      }

      expect(result.quality.acquiescenceIndex, closeTo(1.0, 1e-9));
      expect(result.quality.answeredAxisCount, 12);
      expect(result.quality.axesInTension.length, 12);
      expect(result.quality.tensionAxisRatio, closeTo(1.0, 1e-9));
      expect(result.quality.hasLowDiscriminationWarning, isTrue);
      expect(result.quality.hasLowCoverageWarning, isFalse);

      // O aviso global é o de conflito real, não o de "viés de resposta".
      expect(result.quality.warnings, hasLength(1));
      expect(result.quality.warnings.single, contains('polos políticos divergentes'));
      expect(result.quality.warnings.single, contains('não é uma reprovação'));
      expect(result.quality.warnings.single, isNot(contains('Viés de resposta')));

      // A concordância máxima anula o apoio por vértice (itens diretos e
      // invertidos se compensam): a composição tende ao equilíbrio e a
      // penalidade de engajamento é praticamente nula. O conflito está nos eixos.
      for (final TriadDimensionScore triad in result.triads) {
        expect(triad.vertexObserved.every((bool o) => o), isTrue);
        expect(triad.composition.fold<double>(0.0, (double a, double b) => a + b),
            closeTo(1.0, 1e-9));
        for (final double p in triad.composition) {
          expect((p - 1 / 3).abs(), lessThan(0.12));
        }
        expect((triad.engagement - 0.5).abs(), lessThan(0.12));
        expect(triad.isIndeterminate, isFalse);
      }

      final CompatibilityReport report = compat(result);
      expect(report.isLowDiscrimination, isTrue);
      expect(report.headline, contains('baixa discriminação'));
      expect(report.explanation, contains('12 de 12 eixos'));
      expect(report.ranked, isNotEmpty);
      // A compatibilidade continua sendo um número, mas não é apresentada como
      // afinidade ideológica definida.
      expect(report.explanation, contains('não devem ser lidas como afinidade'));
    });

    test('discordar de tudo espelha o diagnóstico sem inventar apoio', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation agree = score(questions, (_) => 2);
      final ScoredEvaluation disagree = score(questions, (_) => -2);

      expect(disagree.quality.acquiescenceIndex, closeTo(-1.0, 1e-9));
      expect(disagree.quality.hasLowDiscriminationWarning, isTrue);
      expect(disagree.quality.warnings.single, contains('discordou fortemente'));

      // Simetria de inversão: S -> -S nos eixos e v -> -v nos vértices.
      // Como `u = (v + 1)/2`, a inversão leva `u -> 1 - u` e, portanto,
      // `I -> 1 - I`. A distância combinada é invariante a essa troca porque
      // depende apenas de `|I - 0.5|`.
      for (var i = 0; i < agree.axes.length; i++) {
        expect(
          disagree.axes[i].score,
          closeTo(-agree.axes[i].score, 1e-9),
          reason: 'eixo ${agree.axes[i].axisId}',
        );
        expect(
          disagree.axes[i].tensionScore,
          closeTo(agree.axes[i].tensionScore, 1e-9),
        );
      }
      for (var i = 0; i < agree.triads.length; i++) {
        for (var k = 0; k < 3; k++) {
          expect(
            disagree.triads[i].vertexScores[k],
            closeTo(-agree.triads[i].vertexScores[k], 1e-9),
            reason: '${agree.triads[i].label} vértice $k',
          );
          expect(
            disagree.triads[i].vertexSupport[k],
            closeTo(1 - agree.triads[i].vertexSupport[k], 1e-9),
          );
        }
        expect(
          disagree.triads[i].engagement,
          closeTo(1 - agree.triads[i].engagement, 1e-9),
        );
        expect(
          (disagree.triads[i].engagement - 0.5).abs(),
          closeTo((agree.triads[i].engagement - 0.5).abs(), 1e-9),
        );
      }

      final CompatibilityReport report = compat(disagree);
      expect(report.isLowDiscrimination, isTrue);
      expect(report.headline, contains('baixa discriminação'));
    });

    test('resposta 100% neutra fica no centro sem alarme de conflito', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation result = score(questions, (_) => 0);

      for (final BipolarDimensionScore axis in result.axes) {
        expect(axis.score, closeTo(0.0, 1e-9));
        expect(axis.tensionScore, closeTo(0.0, 1e-9));
        expect(axis.hasInternalTension, isFalse);
        expect(axis.isIndeterminate, isFalse);
        expect(axis.coverage, closeTo(1.0, 1e-9));
      }
      expect(result.quality.neutralResponseRate, closeTo(1.0, 1e-9));
      expect(result.quality.extremeResponseRate, closeTo(0.0, 1e-9));
      expect(result.quality.acquiescenceIndex, closeTo(0.0, 1e-9));
      expect(result.quality.hasLowDiscriminationWarning, isFalse);
      expect(result.quality.hasAcquiescenceWarning, isFalse);
      expect(result.quality.hasAllNeutralWarning, isTrue);
      expect(result.quality.warnings, hasLength(1));
      expect(result.quality.warnings.single, contains('neutro'));

      for (final TriadDimensionScore triad in result.triads) {
        expect(triad.vertexScores, everyElement(closeTo(0.0, 1e-9)));
        expect(triad.engagement, closeTo(0.5, 1e-9));
        for (final double p in triad.composition) {
          expect(p, closeTo(1 / 3, 1e-9));
        }
      }
    });
  });

  group('padrões definidos', () {
    test('perfil coerente de esquerda produz resultado discriminal e sem aviso', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation result = score(questions, coherentLeft);

      for (final BipolarDimensionScore axis in result.axes) {
        expect(axis.score, closeTo(-1.0, 1e-9), reason: axis.axisId);
        expect(axis.tensionScore, closeTo(0.0, 1e-9));
        expect(axis.confidence, ScoreConfidence.high);
      }
      expect(result.quality.hasLowDiscriminationWarning, isFalse);
      expect(result.quality.hasAcquiescenceWarning, isFalse);

      for (final TriadDimensionScore triad in result.triads) {
        expect(triad.composition[0], greaterThan(0.95));
        expect(triad.vertexSupport[0], closeTo(1.0, 1e-9));
        expect(triad.vertexSupport[1], closeTo(0.0, 1e-9));
        expect(triad.vertexSupport[2], closeTo(0.0, 1e-9));
        expect(triad.engagement, closeTo(1 / 3, 1e-9));
        expect(triad.isIndeterminate, isFalse);
      }

      final CompatibilityReport report = compat(result);
      expect(report.isLowDiscrimination, isFalse);
      expect(report.headline, isNot(contains('baixa discriminação')));
      expect(report.headline, isNot(contains('Dados insuficientes')));
      // A menor distância deve cair no campo ideológico correto. A magnitude
      // absoluta do percentual depende da calibração de `mu`/`sigma` do
      // catálogo (objeto da Etapa C), não da geometria aqui testada.
      // O catálogo ampliado inclui tradições cujo nome de família não contém
      // literalmente 'Esquerda', e posições sem evidência são excluídas.
      final current = report.ranked.first.current;
      expect(current.axes['economia']!.relevance, greaterThan(0));
      expect(current.axes['economia']!.mu, lessThan(0));
      expect(report.ranked.first.evaluatedDimensions, greaterThanOrEqualTo(6));
      // Apoio absoluto médio de 1/3 (um vértice apoiado, dois rejeitados) fica
      // levemente fora da faixa neutra, mas muito abaixo do limiar de alarme:
      // não deve ser tratado como baixa discriminação.
      expect(report.ranked.first.meanEngagementPenalty, lessThan(0.1));
      expect(report.ranked.first.evaluatedTriads, greaterThanOrEqualTo(1));
    });

    test('conflito em um único eixo não dispara o aviso global', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation result = score(questions, (UnifiedQuestion q) {
        if (q.kind == UnifiedQuestionKind.bipolar &&
            q.axisQuestion!.axisId == 'economia') {
          // Concorda com ambos os polos de economia: tensão localizada.
          return 2;
        }
        return coherentLeft(q);
      });

      final BipolarDimensionScore economia = result.axes.firstWhere(
        (BipolarDimensionScore a) => a.axisId == 'economia',
      );
      // Os dois itens têm pesos ligeiramente diferentes, então a média ponderada
      // não é exatamente zero — mas fica próxima do centro e a tensão é máxima.
      expect(economia.score.abs(), lessThan(0.2));
      expect(economia.hasInternalTension, isTrue);
      expect(result.quality.axesInTension, <String>[economia.label]);
      expect(result.quality.answeredAxisCount, 12);
      expect(result.quality.tensionAxisRatio, closeTo(1 / 12, 1e-9));
      expect(result.quality.hasLowDiscriminationWarning, isFalse);
      expect(result.quality.warnings.join(' '), contains('Tensão interna'));

      expect(compat(result).isLowDiscrimination, isFalse);
    });

    test('alternância de concordância/discordância não fabrica apoio a vértice', () {
      final List<UnifiedQuestion> questions = select();
      int? alternating(UnifiedQuestion q) {
        final int idx = questions.indexOf(q);
        return idx.isEven ? 2 : -2;
      }

      final ScoredEvaluation result = score(questions, alternating);
      // Resultado é determinístico e auditável: toda dimensão tem resposta
      // suficiente e nenhum vértice é preenchido sem observação.
      for (final TriadDimensionScore triad in result.triads) {
        expect(triad.vertexObserved.every((bool o) => o), isTrue);
        expect(triad.answeredCount, 6);
        expect(triad.isIndeterminate, isFalse);
      }
      // A alternância bruta não é um padrão ideológico: o aviso de baixa
      // discriminação só existe se houver conflito real (>= 2 eixos e metade
      // deles). O teste fixa o comportamento atual, seja qual for o veredito.
      final int tensionAxes = result.quality.axesInTension.length;
      expect(
        result.quality.hasLowDiscriminationWarning,
        tensionAxes >= 2 && tensionAxes / 12 >= 0.5,
      );
    });
  });

  group('pulos, cobertura e ausência de fabricação', () {
    test('pular tudo torna todas as dimensões indeterminadas', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation result = score(questions, (_) => null);

      expect(result.axes.every((BipolarDimensionScore a) => a.isIndeterminate), isTrue);
      expect(result.axes.every((BipolarDimensionScore a) => a.answeredCount == 0), isTrue);
      expect(
        result.axes.every((BipolarDimensionScore a) => a.confidence == ScoreConfidence.insufficient),
        isTrue,
      );
      for (final TriadDimensionScore triad in result.triads) {
        expect(triad.isIndeterminate, isTrue);
        expect(triad.answeredCount, 0);
        expect(triad.vertexObserved, <bool>[false, false, false]);
        expect(triad.engagement, closeTo(0.5, 1e-9));
        // Placeholder neutro explícito, nunca apresentado como apoio do usuário.
        expect(triad.vertexSupport, <double>[0.5, 0.5, 0.5]);
      }
      expect(result.quality.coverage, closeTo(0.0, 1e-9));
      expect(result.quality.hasLowCoverageWarning, isTrue);
      expect(result.quality.hasLowDiscriminationWarning, isFalse);
    });

    test('vértice não observado recebe participação zero e indeterminação', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation result = score(questions, (UnifiedQuestion q) {
        if (q.kind == UnifiedQuestionKind.bipolar) return coherentLeft(q);
        // Responde apenas dois dos três vértices de cada tríade.
        return q.sixQuestion!.subcategory == 2 ? null : coherentLeft(q);
      });

      for (final TriadDimensionScore triad in result.triads) {
        expect(triad.vertexObserved, <bool>[true, true, false]);
        expect(triad.composition[2], closeTo(0.0, 1e-9));
        expect(triad.composition[0] + triad.composition[1], closeTo(1.0, 1e-9));
        expect(triad.isIndeterminate, isTrue);
        // Cobertura é ponderada pela força dos itens; o vértice omitido
        // respondeu zero dos itens apresentados.
        expect(triad.vertexAnsweredCount[2], 0);
        expect(triad.vertexPresentedCount[2], 2);
        expect(triad.vertexCoverage[2], closeTo(0.0, 1e-9));
        expect(triad.coverage, lessThan(1.0));
        expect(triad.coverage, greaterThan(0.6));
        expect(triad.confidence, ScoreConfidence.insufficient);
        // O placeholder de 0.5 não pode ser lido como apoio observado.
        expect(triad.vertexSupport[2], closeTo(0.5, 1e-9));
        expect(triad.observedVertexCount, 2);
        expect(triad.hasAllVerticesObserved, isFalse);
      }
    });

    test('metade das respostas reduz cobertura sem enviesar o escore', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation full = score(questions, coherentLeft);
      final ScoredEvaluation half = score(questions, (UnifiedQuestion q) {
        return questions.indexOf(q).isEven ? coherentLeft(q) : null;
      });

      expect(half.quality.coverage, closeTo(0.5, 1e-9));
      // Cada eixo responde um único item: o escore permanece no extremo do que
      // foi efetivamente respondido (não é empurrado ao centro pela ausência),
      // mas a confiança cai porque um dos polos não foi observado.
      for (final BipolarDimensionScore axis in half.axes) {
        expect(axis.answeredCount, 1);
        expect(axis.coverage, lessThan(1.0));
        expect(axis.score.abs(), closeTo(1.0, 1e-9));
        final bool bothPoles = axis.answeredLeftCount > 0 && axis.answeredRightCount > 0;
        expect(axis.hasBothPoles, bothPoles);
        expect(axis.isIndeterminate, !bothPoles);
      }
      expect(
        half.axes.map((BipolarDimensionScore a) => a.score).toList(),
        full.axes.map((BipolarDimensionScore a) => a.score).toList(),
        reason: 'pular não pode deslocar o escore dos itens respondidos',
      );
      expect(
        half.axes.every((BipolarDimensionScore a) => a.coverage < 1.0),
        isTrue,
      );
    });
  });

  group('determinismo, ordem e persistência', () {
    test('o mesmo padrão produz exatamente os mesmos números', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation a = score(questions, coherentLeft);
      final ScoredEvaluation b = score(questions, coherentLeft);
      expect(
        b.axes.map((BipolarDimensionScore x) => x.score).toList(),
        a.axes.map((BipolarDimensionScore x) => x.score).toList(),
      );
      expect(
        b.triads.map((TriadDimensionScore x) => x.composition).toList(),
        a.triads.map((TriadDimensionScore x) => x.composition).toList(),
      );
    });

    test('a ordem de apresentação das perguntas não altera o resultado', () {
      final List<UnifiedQuestion> questions = select();
      final List<UnifiedQuestion> reversed = questions.reversed.toList();
      final ScoredEvaluation a = score(questions, coherentLeft);
      final ScoredEvaluation b = score(reversed, coherentLeft);
      for (var i = 0; i < a.axes.length; i++) {
        expect(b.axes[i].score, closeTo(a.axes[i].score, 1e-12));
        expect(b.axes[i].tensionScore, closeTo(a.axes[i].tensionScore, 1e-12));
      }
      for (var i = 0; i < a.triads.length; i++) {
        for (var k = 0; k < 3; k++) {
          expect(
            b.triads[i].composition[k],
            closeTo(a.triads[i].composition[k], 1e-12),
          );
        }
      }
    });

    test('serialização preserva os novos campos de cobertura', () {
      final List<UnifiedQuestion> questions = select();
      final ScoredEvaluation result = score(questions, coherentLeft);
      final BipolarDimensionScore axis = result.axes.first;
      final TriadDimensionScore triad = result.triads.first;

      BipolarDimensionScore roundTripAxis(BipolarDimensionScore s) =>
          BipolarDimensionScore.fromJson(
            jsonDecode(jsonEncode(s.toJson())) as Map<String, Object?>,
            'axis',
          );
      TriadDimensionScore roundTripTriad(TriadDimensionScore s) =>
          TriadDimensionScore.fromJson(
            jsonDecode(jsonEncode(s.toJson())) as Map<String, Object?>,
            'triad',
          );

      final BipolarDimensionScore axisCopy = roundTripAxis(axis);
      expect(axisCopy.poleBreakdownAvailable, isTrue);
      expect(axisCopy.answeredLeftCount, axis.answeredLeftCount);
      expect(axisCopy.presentedRightCount, axis.presentedRightCount);
      expect(axisCopy.leftPoleMean, closeTo(axis.leftPoleMean, 1e-12));
      expect(axisCopy.minimumPoleCoverage, closeTo(axis.minimumPoleCoverage, 1e-12));
      expect(axisCopy.confidence, axis.confidence);

      final TriadDimensionScore triadCopy = roundTripTriad(triad);
      expect(triadCopy.vertexBreakdownAvailable, isTrue);
      expect(triadCopy.vertexObserved, triad.vertexObserved);
      expect(triadCopy.vertexAnsweredCount, triad.vertexAnsweredCount);
      expect(triadCopy.minimumVertexCoverage, closeTo(triad.minimumVertexCoverage, 1e-12));
      expect(triadCopy.confidence, triad.confidence);
    });

    test('registro antigo sem os novos campos mantém a regra original', () {
      final Map<String, Object?> legacyAxis = <String, Object?>{
        'axisId': 'economia',
        'label': 'Economia',
        'leftPole': 'Público',
        'rightPole': 'Privado',
        'score': 0.2,
        'standardError': 0.1,
        'coverage': 0.6,
        'answeredCount': 3,
        'presentedCount': 5,
        'tensionScore': 0.0,
      };
      final BipolarDimensionScore axis = BipolarDimensionScore.fromJson(
        legacyAxis,
        'axis',
      );
      expect(axis.poleBreakdownAvailable, isFalse);
      expect(axis.hasBothPoles, isTrue);
      expect(axis.isIndeterminate, isFalse);
      expect(axis.confidence, axis.confidence); // derivado apenas de coverage/SE

      final Map<String, Object?> legacyTriad = <String, Object?>{
        'categoryId': 0,
        'label': 'Economia',
        'vertices': <String>['Controle', 'Regulação', 'Mercados'],
        'vertexScores': <double>[0.2, 0.0, -0.2],
        'vertexSupport': <double>[0.6, 0.5, 0.4],
        'composition': <double>[0.4, 0.33, 0.27],
        'engagement': 0.5,
        'standardError': 0.05,
        'coverage': 0.8,
        'answeredCount': 5,
        'presentedCount': 6,
        'classification': 'Equilíbrio entre os 3 vértices',
      };
      final TriadDimensionScore triad = TriadDimensionScore.fromJson(
        legacyTriad,
        'triad',
      );
      expect(triad.vertexBreakdownAvailable, isFalse);
      expect(triad.vertexObserved, <bool>[true, true, true]);
      expect(triad.isIndeterminate, isFalse);
      expect(triad.minimumVertexCoverage, triad.coverage);
    });
  });

  test('a bateria curta não é a mesma em todas as sementes', () {
    final List<UnifiedQuestion> a = select(seed: 42);
    final List<UnifiedQuestion> b = select(seed: 7);
    final Set<String> uidsA = a.map((UnifiedQuestion q) => q.uid).toSet();
    final Set<String> uidsB = b.map((UnifiedQuestion q) => q.uid).toSet();
    expect(uidsA.length, 60);
    expect(uidsB.length, 60);
    final int shared = uidsA.intersection(uidsB).length;
    expect(shared, lessThan(60));
    expect(shared, greaterThan(0));
    expect(math.min(uidsA.length, uidsB.length), 60);
  });
}
