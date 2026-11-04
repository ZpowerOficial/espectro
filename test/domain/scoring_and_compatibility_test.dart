import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/models.dart';
import 'package:politico/domain/engine/compatibility_engine.dart';
import 'package:politico/domain/engine/comparison_engine.dart';
import 'package:politico/domain/engine/scoring_engine.dart';
import 'package:politico/domain/models/political_models.dart';

const QuestionHelp _help = QuestionHelp(
  agree: 'Concordar favorece este polo.',
  disagree: 'Discordar favorece o polo oposto.',
  note: null,
  agreeExample: 'Exemplo de concordância.',
  disagreeExample: 'Exemplo de discordância.',
);

Axis _axis(String id, String left, String right) => Axis(
  id: id,
  label: id.toUpperCase(),
  leftPole: left,
  rightPole: right,
  leftColor: const Color(0xFF0E6C7B),
  rightColor: const Color(0xFFC27318),
);

AxisQuestion _axisQ({
  required String id,
  required String axisId,
  required bool agreeIsLeft,
  double weight = 1.0,
}) => AxisQuestion(
  id: id,
  axisId: axisId,
  text: 'Afirmação $id',
  agreeIsLeft: agreeIsLeft,
  weight: weight,
  terms: const <QuestionTerm>[],
  help: _help,
);

SixCategory _triCat(int id, List<String> subs) => SixCategory(
  id: id,
  label: 'Tríade $id',
  color: const Color(0xFF0E6C7B),
  subcategories: subs,
);

SixQuestion _triQ({
  required int id,
  required int cat,
  required int sub,
  required int multiplier,
  int strength = 2,
}) => SixQuestion(
  id: id,
  category: cat,
  subcategory: sub,
  strength: strength,
  multiplier: multiplier,
  text: 'Tríade item $id',
);

void main() {
  group('EspectroScoringEngine — eixos bipolares, normalização e inversão', () {
    final TwelveAxesData axesData = TwelveAxesData(
      axes: <Axis>[_axis('eco', 'Público', 'Privado')],
      answerOptions: const <AnswerOption>[],
      questions: <AxisQuestion>[
        _axisQ(id: 'q_l1', axisId: 'eco', agreeIsLeft: true, weight: 1.0),
        _axisQ(id: 'q_l2', axisId: 'eco', agreeIsLeft: true, weight: 1.5),
        _axisQ(id: 'q_r1', axisId: 'eco', agreeIsLeft: false, weight: 1.0),
        _axisQ(id: 'q_r2', axisId: 'eco', agreeIsLeft: false, weight: 1.5),
      ],
      archetypeQuestions: const <ArchetypeQuestion>[],
    );
    final SixTrianglesData emptyTriads = SixTrianglesData(
      categories: const <SixCategory>[],
      questions: const <SixQuestion>[],
    );
    final List<UnifiedQuestion> questions = axesData.questions
        .map(UnifiedQuestion.bipolar)
        .toList();

    test('extremos coerentes produzem S = -1.0 (100% Público) e S = +1.0 (100% Privado)', () {
      final ScoredEvaluation allLeft = EspectroScoringEngine.evaluate(
        axesData: axesData,
        trianglesData: emptyTriads,
        suite: TestSuite.bipolarAxes,
        questions: questions,
        rawAnswersByUid: const <String, int?>{
          'axis:q_l1': 2,
          'axis:q_l2': 2,
          'axis:q_r1': -2,
          'axis:q_r2': -2,
        },
      );
      final BipolarDimensionScore leftScore = allLeft.axes.single;
      expect(leftScore.score, closeTo(-1.0, 1e-9));
      expect(leftScore.leftPercent, closeTo(100.0, 1e-6));
      expect(leftScore.rightPercent, closeTo(0.0, 1e-6));

      final ScoredEvaluation allRight = EspectroScoringEngine.evaluate(
        axesData: axesData,
        trianglesData: emptyTriads,
        suite: TestSuite.bipolarAxes,
        questions: questions,
        rawAnswersByUid: const <String, int?>{
          'axis:q_l1': -2,
          'axis:q_l2': -2,
          'axis:q_r1': 2,
          'axis:q_r2': 2,
        },
      );
      final BipolarDimensionScore rightScore = allRight.axes.single;
      expect(rightScore.score, closeTo(1.0, 1e-9));
      expect(rightScore.rightPercent, closeTo(100.0, 1e-6));
    });

    test(
      'simetria exata de inversão: inverter respostas r -> -r inverte S -> -S',
      () {
        const Map<String, int?> original = <String, int?>{
          'axis:q_l1': 2,
          'axis:q_l2': 1,
          'axis:q_r1': -1,
          'axis:q_r2': 0,
        };
        final Map<String, int?> negated = <String, int?>{
          for (final MapEntry<String, int?> e in original.entries)
            e.key: -e.value!,
        };

        final ScoredEvaluation s1 = EspectroScoringEngine.evaluate(
          axesData: axesData,
          trianglesData: emptyTriads,
          suite: TestSuite.bipolarAxes,
          questions: questions,
          rawAnswersByUid: original,
        );
        final ScoredEvaluation s2 = EspectroScoringEngine.evaluate(
          axesData: axesData,
          trianglesData: emptyTriads,
          suite: TestSuite.bipolarAxes,
          questions: questions,
          rawAnswersByUid: negated,
        );

        expect(s2.axes.single.score, closeTo(-s1.axes.single.score, 1e-9));
        expect(
          s2.axes.single.standardError,
          closeTo(s1.axes.single.standardError, 1e-9),
        );
      },
    );

    test('invariância à ordem das perguntas em permutações aleatórias', () {
      const Map<String, int?> answers = <String, int?>{
        'axis:q_l1': 2,
        'axis:q_l2': -1,
        'axis:q_r1': 1,
        'axis:q_r2': 2,
      };
      final ScoredEvaluation baseline = EspectroScoringEngine.evaluate(
        axesData: axesData,
        trianglesData: emptyTriads,
        suite: TestSuite.bipolarAxes,
        questions: questions,
        rawAnswersByUid: answers,
      );

      final Random rng = Random(99);
      for (var trial = 0; trial < 10; trial++) {
        final List<UnifiedQuestion> shuffled = <UnifiedQuestion>[...questions]
          ..shuffle(rng);
        final ScoredEvaluation permuted = EspectroScoringEngine.evaluate(
          axesData: axesData,
          trianglesData: emptyTriads,
          suite: TestSuite.bipolarAxes,
          questions: shuffled,
          rawAnswersByUid: answers,
        );
        expect(
          permuted.axes.single.score,
          closeTo(baseline.axes.single.score, 1e-12),
        );
        expect(
          permuted.axes.single.standardError,
          closeTo(baseline.axes.single.standardError, 1e-12),
        );
      }
    });

    test(
      'pular (null) difere matematicamente de neutro (0) e reduz cobertura',
      () {
        final ScoredEvaluation withNeutral = EspectroScoringEngine.evaluate(
          axesData: axesData,
          trianglesData: emptyTriads,
          suite: TestSuite.bipolarAxes,
          questions: questions,
          rawAnswersByUid: const <String, int?>{
            'axis:q_l1': 2,
            'axis:q_l2': 2,
            'axis:q_r1': 0,
            'axis:q_r2': 0,
          },
        );
        final ScoredEvaluation withSkip = EspectroScoringEngine.evaluate(
          axesData: axesData,
          trianglesData: emptyTriads,
          suite: TestSuite.bipolarAxes,
          questions: questions,
          rawAnswersByUid: const <String, int?>{
            'axis:q_l1': 2,
            'axis:q_l2': 2,
            'axis:q_r1': null,
            'axis:q_r2': null,
          },
        );

        // Com neutro nos dois itens de direita, o escore puxa para -0.5 (75% Público) com 100% de cobertura.
        expect(withNeutral.axes.single.score, closeTo(-0.5, 1e-9));
        expect(withNeutral.axes.single.coverage, closeTo(1.0, 1e-9));

        // Com pulo explícito nos dois itens de direita, o escore reflete apenas os itens respondidos (-1.0)
        // com cobertura de 50% e maior erro-padrão.
        expect(withSkip.axes.single.score, closeTo(-1.0, 1e-9));
        expect(withSkip.axes.single.coverage, closeTo(0.5, 1e-9));
        expect(withSkip.quality.totalSkipped, 2);

        // Se pular 3 de 4 itens (cobertura 20% < 50%), a dimensão é sinalizada como indeterminada.
        final ScoredEvaluation lowCoverage = EspectroScoringEngine.evaluate(
          axesData: axesData,
          trianglesData: emptyTriads,
          suite: TestSuite.bipolarAxes,
          questions: questions,
          rawAnswersByUid: const <String, int?>{
            'axis:q_l1': 2,
            'axis:q_l2': null,
            'axis:q_r1': null,
            'axis:q_r2': null,
          },
        );
        expect(lowCoverage.axes.single.isIndeterminate, isTrue);
      },
    );

    test('concordar simultaneamente com ambos os polos detecta tensão interna e aquiescência', () {
      final ScoredEvaluation contradictory = EspectroScoringEngine.evaluate(
        axesData: axesData,
        trianglesData: emptyTriads,
        suite: TestSuite.bipolarAxes,
        questions: questions,
        rawAnswersByUid: const <String, int?>{
          'axis:q_l1': 2,
          'axis:q_l2': 2,
          'axis:q_r1': 2,
          'axis:q_r2': 2,
        },
      );
      final BipolarDimensionScore score = contradictory.axes.single;
      // O escore líquido se anula no centro (0.0), mas NÃO é confundido com moderação tranquila:
      // tensionScore atinge 2.0 (hasInternalTension == true) e acquiescenceIndex == 1.0!
      expect(score.score, closeTo(0.0, 1e-9));
      expect(score.hasInternalTension, isTrue);
      expect(contradictory.quality.acquiescenceIndex, closeTo(1.0, 1e-9));
      expect(contradictory.quality.axesInTension, contains('ECO'));

      // Em bateria com >= 12 itens respondidos, dispara também o alerta global de aquiescência.
      final List<AxisQuestion> twelveQs = <AxisQuestion>[
        for (var i = 0; i < 12; i++)
          _axisQ(id: 'aq_$i', axisId: 'eco', agreeIsLeft: i.isEven),
      ];
      final ScoredEvaluation fullAcq = EspectroScoringEngine.evaluate(
        axesData: TwelveAxesData(
          axes: axesData.axes,
          answerOptions: const <AnswerOption>[],
          questions: twelveQs,
          archetypeQuestions: const <ArchetypeQuestion>[],
        ),
        trianglesData: emptyTriads,
        suite: TestSuite.bipolarAxes,
        questions: twelveQs.map(UnifiedQuestion.bipolar).toList(),
        rawAnswersByUid: <String, int?>{
          for (var i = 0; i < 12; i++) 'axis:aq_$i': 2,
        },
      );
      expect(fullAcq.quality.hasAcquiescenceWarning, isTrue);
    });
  });

  group(
    'EspectroScoringEngine — tríades e superação do fechamento composicional',
    () {
      final TwelveAxesData emptyAxes = TwelveAxesData(
        axes: const <Axis>[],
        answerOptions: const <AnswerOption>[],
        questions: const <AxisQuestion>[],
        archetypeQuestions: const <ArchetypeQuestion>[],
      );
      final SixTrianglesData triData = SixTrianglesData(
        categories: <SixCategory>[
          _triCat(0, const <String>['Controle', 'Regulação', 'Mercados']),
        ],
        questions: <SixQuestion>[
          _triQ(id: 0, cat: 0, sub: 0, multiplier: 1),
          _triQ(id: 1, cat: 0, sub: 0, multiplier: -1),
          _triQ(id: 2, cat: 0, sub: 1, multiplier: 1),
          _triQ(id: 3, cat: 0, sub: 1, multiplier: -1),
          _triQ(id: 4, cat: 0, sub: 2, multiplier: 1),
          _triQ(id: 5, cat: 0, sub: 2, multiplier: -1),
        ],
      );
      final List<UnifiedQuestion> triQuestions = triData.questions
          .map(UnifiedQuestion.triad)
          .toList();

      test('distingue apoio amplo aos 3 vértices de ceticismo nos 3 vértices apesar da mesma composição 1/3', () {
        // Usuário A apoia fortemente todos os 3 vértices (+2 nos positivos, -2 nos invertidos).
        final ScoredEvaluation endorseAll = EspectroScoringEngine.evaluate(
          axesData: emptyAxes,
          trianglesData: triData,
          suite: TestSuite.triads,
          questions: triQuestions,
          rawAnswersByUid: const <String, int?>{
            'tri:0': 2,
            'tri:1': -2,
            'tri:2': 2,
            'tri:3': -2,
            'tri:4': 2,
            'tri:5': -2,
          },
        );
        // Usuário B rejeita fortemente todos os 3 vértices (-2 nos positivos, +2 nos invertidos).
        final ScoredEvaluation rejectAll = EspectroScoringEngine.evaluate(
          axesData: emptyAxes,
          trianglesData: triData,
          suite: TestSuite.triads,
          questions: triQuestions,
          rawAnswersByUid: const <String, int?>{
            'tri:0': -2,
            'tri:1': 2,
            'tri:2': -2,
            'tri:3': 2,
            'tri:4': -2,
            'tri:5': 2,
          },
        );

        final TriadDimensionScore a = endorseAll.triads.single;
        final TriadDimensionScore b = rejectAll.triads.single;

        for (var k = 0; k < 3; k++) {
          expect(a.composition[k], closeTo(1.0 / 3.0, 1e-6));
          expect(b.composition[k], closeTo(1.0 / 3.0, 1e-6));
        }
        expect(a.engagement, closeTo(1.0, 1e-6));
        expect(b.engagement, closeTo(0.0, 1e-6));
        expect(a.classification, 'Apoio amplo aos 3 vértices');
        expect(b.classification, 'Ceticismo nos 3 vértices');
      });

      test(
        'classifica predomínio forte de 1 vértice e síntese de 2 vértices',
        () {
          final ScoredEvaluation oneDominant = EspectroScoringEngine.evaluate(
            axesData: emptyAxes,
            trianglesData: triData,
            suite: TestSuite.triads,
            questions: triQuestions,
            rawAnswersByUid: const <String, int?>{
              'tri:0': 2,
              'tri:1': -2, // Controle u = 1.0
              'tri:2': -1,
              'tri:3': 1, // Regulação u = 0.25
              'tri:4': -1,
              'tri:5': 1, // Mercados u = 0.25
            },
          );
          expect(
            oneDominant.triads.single.classification,
            'Predomínio forte de Controle',
          );

          final ScoredEvaluation twoSynthesis = EspectroScoringEngine.evaluate(
            axesData: emptyAxes,
            trianglesData: triData,
            suite: TestSuite.triads,
            questions: triQuestions,
            rawAnswersByUid: const <String, int?>{
              'tri:0': 2,
              'tri:1': -2, // Controle u = 1.0
              'tri:2': 2,
              'tri:3': -2, // Regulação u = 1.0
              'tri:4': -2,
              'tri:5': 2, // Mercados u = 0.0
            },
          );
          expect(
            twoSynthesis.triads.single.classification,
            'Síntese Controle + Regulação',
          );
        },
      );
    },
  );

  group('EspectroCompatibilityEngine e EspectroComparisonEngine', () {
    final IdeologicalCatalog miniCatalog = IdeologicalCatalog(
      schemaVersion: 1,
      catalogVersion: '1.0.0',
      currents: <IdeologicalCurrent>[
        const IdeologicalCurrent(
          id: 'c_left',
          name: 'Corrente Pública',
          family: 'Esquerda',
          summary: 'Foco em propriedade pública.',
          keyIdeas: <String>['Serviços públicos'],
          axes: <String, CurrentAxisProfile>{
            'eco': CurrentAxisProfile(
              mu: -0.8,
              sigma: 0.22,
              relevance: 1.0,
              note: 'Público',
            ),
            'mor': CurrentAxisProfile(
              mu: -0.7,
              sigma: 0.22,
              relevance: 1.0,
              note: 'Progressista',
            ),
          },
          triangles: <int, CurrentTriadProfile>{},
        ),
        const IdeologicalCurrent(
          id: 'c_right',
          name: 'Corrente Privada',
          family: 'Direita',
          summary: 'Foco em mercado e tradição.',
          keyIdeas: <String>['Livre iniciativa'],
          axes: <String, CurrentAxisProfile>{
            'eco': CurrentAxisProfile(
              mu: 0.8,
              sigma: 0.22,
              relevance: 1.0,
              note: 'Privado',
            ),
            'mor': CurrentAxisProfile(
              mu: 0.7,
              sigma: 0.22,
              relevance: 1.0,
              note: 'Tradicional',
            ),
          },
          triangles: <int, CurrentTriadProfile>{},
        ),
      ],
    );

    BipolarDimensionScore mkAxis(String id, double s, {double se = 0.08}) =>
        BipolarDimensionScore(
          axisId: id,
          label: id.toUpperCase(),
          leftPole: 'Esq',
          rightPole: 'Dir',
          score: s,
          standardError: se,
          coverage: 1.0,
          answeredCount: 6,
          presentedCount: 6,
          tensionScore: 0.0,
        );

    test('não força rótulo único em perfil híbrido/contraditório (< 52%) nem em empate técnico', () {
      // Perfil cruzado: eco = -0.9 (extrema esquerda) + mor = +0.9 (extrema direita)
      // diverge fortemente de AMBAS as correntes do catálogo -> isHybridProfile == true!
      final CompatibilityReport hybrid = EspectroCompatibilityEngine.evaluate(
        catalog: miniCatalog,
        axes: <BipolarDimensionScore>[mkAxis('eco', -0.9), mkAxis('mor', 0.9)],
        triads: const <TriadDimensionScore>[],
      );
      expect(hybrid.isHybridProfile, isTrue);
      expect(hybrid.headline, contains('híbrido'));
      expect(hybrid.ranked.first.divergences, isNotEmpty);

      // Perfil exatamente equidistante no centro com sigma largo -> empate técnico!
      final IdeologicalCatalog closeCatalog = IdeologicalCatalog(
        schemaVersion: 1,
        catalogVersion: '1.0.0',
        currents: <IdeologicalCurrent>[
          const IdeologicalCurrent(
            id: 'a',
            name: 'Centro A',
            family: 'Centro',
            summary: 'A',
            keyIdeas: <String>[],
            axes: <String, CurrentAxisProfile>{
              'eco': CurrentAxisProfile(
                mu: -0.15,
                sigma: 0.35,
                relevance: 1.0,
                note: 'n',
              ),
            },
            triangles: <int, CurrentTriadProfile>{},
          ),
          const IdeologicalCurrent(
            id: 'b',
            name: 'Centro B',
            family: 'Centro',
            summary: 'B',
            keyIdeas: <String>[],
            axes: <String, CurrentAxisProfile>{
              'eco': CurrentAxisProfile(
                mu: 0.15,
                sigma: 0.35,
                relevance: 1.0,
                note: 'n',
              ),
            },
            triangles: <int, CurrentTriadProfile>{},
          ),
        ],
      );
      final CompatibilityReport tie = EspectroCompatibilityEngine.evaluate(
        catalog: closeCatalog,
        axes: <BipolarDimensionScore>[mkAxis('eco', 0.0)],
        triads: const <TriadDimensionScore>[],
      );
      expect(tie.isTechnicalTie, isTrue);
      expect(tie.headline, contains('Proximidade compartilhada'));
    });

    test('compara duas avaliações, detecta mudança significativa e ordena série temporal', () {
      final EvaluationRecord r1 = EvaluationRecord(
        id: 'rec_1',
        createdAt: DateTime.utc(2026, 5, 1),
        suite: TestSuite.bipolarAxes,
        depth: TestDepth.standard,
        seed: 1,
        engineVersion: kEspectroEngineVersion,
        bankVersion: kEspectroBankVersion,
        rawAnswers: const <String, int?>{'ax_1': 2, 'ax_2': 1},
        axes: <BipolarDimensionScore>[
          mkAxis('eco', -0.60, se: 0.08),
          mkAxis('mor', 0.10, se: 0.12),
        ],
        triads: const <TriadDimensionScore>[],
        quality: const ResponseQualityReport(
          totalPresented: 12,
          totalAnswered: 12,
          totalSkipped: 0,
          acquiescenceIndex: 0.0,
          extremeResponseRate: 0.2,
          neutralResponseRate: 0.1,
          axesInTension: <String>[],
        ),
      );
      final EvaluationRecord r2 = EvaluationRecord(
        id: 'rec_2',
        createdAt: DateTime.utc(2026, 6, 1),
        suite: TestSuite.bipolarAxes,
        depth: TestDepth.standard,
        seed: 2,
        engineVersion: kEspectroEngineVersion,
        bankVersion: kEspectroBankVersion,
        rawAnswers: const <String, int?>{'ax_1': -2, 'ax_2': 1},
        axes: <BipolarDimensionScore>[
          mkAxis(
            'eco',
            0.50,
            se: 0.08,
          ), // salto de +1.10 >> 1.96 * sqrt(2)*0.08
          mkAxis('mor', 0.14, se: 0.12), // variação +0.04 dentro da margem
        ],
        triads: const <TriadDimensionScore>[],
        quality: r1.quality,
      );

      final EvaluationComparisonReport cmp = EspectroComparisonEngine.compare(
        baseline: r1,
        target: r2,
        catalog: miniCatalog,
        questionTextByUid: const <String, String>{
          'ax_1': 'Pergunta 1',
          'ax_2': 'Pergunta 2',
        },
      );
      expect(cmp.significantAxesCount, 1);
      expect(cmp.sharedAnsweredQuestions, 2);
      expect(cmp.unchangedAnswersCount, 1);
      expect(cmp.answerShifts.single.questionUid, 'ax_1');
      expect(cmp.answerShifts.single.stepDiff, 4);

      // Passando na ordem reversa [r2, r1], axisSeries deve ordenar cronologicamente [r1, r2].
      final List<EvolutionPoint> series = EspectroComparisonEngine.axisSeries(
        records: <EvaluationRecord>[r2, r1],
        axisId: 'eco',
      );
      expect(series.map((p) => p.recordId).toList(), <String>[
        'rec_1',
        'rec_2',
      ]);
      expect(series.first.value, closeTo(20.0, 1e-6));
      expect(series.last.value, closeTo(75.0, 1e-6));
    });
  });
}
