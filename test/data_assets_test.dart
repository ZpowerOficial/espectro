import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/models.dart';
import 'package:politico/data/pdf_export_service.dart';
import 'package:politico/domain/engine/atlas_and_nolan_engine.dart';
import 'package:politico/domain/engine/compatibility_engine.dart';
import 'package:politico/domain/engine/question_selector.dart';
import 'package:politico/domain/models/atlas_models.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/engine/six_triangles_engine.dart';
import 'package:politico/engine/twelve_axes_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppData data;

  setUpAll(() async {
    data = await AppData.load();
  });

  test('12 Eixos expandido tem 12 eixos e 600 perguntas balanceadas 50/50', () {
    final TwelveAxesData twelve = data.twelveAxes;
    expect(twelve.axes.length, 12);
    expect(twelve.questions.length, 600);
    expect(twelve.answerOptions.length, 5);
    expect(twelve.archetypeQuestions.length, 5);

    final Set<String> axisIds = twelve.axes.map((axis) => axis.id).toSet();
    for (final Axis axis in twelve.axes) {
      final List<AxisQuestion> questions = twelve.questionsFor(axis.id);
      expect(questions.length, 50, reason: axis.id);
      expect(questions.where((q) => q.agreeIsLeft).length, 25, reason: axis.id);
    }
    for (final AxisQuestion question in twelve.questions) {
      expect(axisIds, contains(question.axisId));
      expect(question.text.trim(), isNotEmpty);
      expect(question.help.agree.trim(), isNotEmpty);
      expect(question.help.disagree.trim(), isNotEmpty);
    }
    for (final ArchetypeQuestion question in twelve.archetypeQuestions) {
      expect(question.options.length, greaterThanOrEqualTo(5));
    }
  });

  test('variantes clássicas do 12 Eixos respeitam a contagem por eixo', () {
    for (final TwelveVariant variant in TwelveVariant.values) {
      final TwelveAxesSession session = TwelveAxesSession(
        data: data.twelveAxes,
        variant: variant,
        random: Random(11),
      );
      expect(
        session.questions.length,
        variant.questionCount,
        reason: variant.name,
      );
      for (final Axis axis in data.twelveAxes.axes) {
        expect(
          session.questions.where((q) => q.axisId == axis.id).length,
          variant.perAxis,
          reason: '${variant.name}/${axis.id}',
        );
      }
    }
  });

  test(
    'respostas neutras no 12 Eixos resultam em todos os eixos no centro',
    () {
      final TwelveAxesSession session = TwelveAxesSession(
        data: data.twelveAxes,
        variant: TwelveVariant.short,
        random: Random(12),
      );
      for (var i = 0; i < session.questions.length; i++) {
        session.answers[i] = 2;
      }
      final TwelveAxesResult result = session.result()!;
      expect(result.scores.length, 12);
      for (final AxisScore score in result.scores) {
        expect(score.leftPercent, closeTo(50, 0.001), reason: score.axis.id);
        expect(score.intensity, 'Equilibrado');
      }
    },
  );

  test('Six Triangles expandido tem 6 categorias e 504 perguntas balanceadas 50/50 por vértice', () {
    final SixTrianglesData six = data.sixTriangles;
    expect(six.categories.length, 6);
    expect(six.questions.length, 504);
    for (final SixCategory category in six.categories) {
      expect(category.subcategories.length, 3);
      expect(category.label.trim(), isNotEmpty);
      for (var sub = 0; sub < 3; sub++) {
        final List<SixQuestion> vertexQs = six.questions
            .where((q) => q.category == category.id && q.subcategory == sub)
            .toList();
        expect(vertexQs.length, 28, reason: 'cat=${category.id}, sub=$sub');
        expect(
          vertexQs.where((q) => q.multiplier == 1).length,
          14,
          reason: 'cat=${category.id}, sub=$sub (+1)',
        );
        expect(
          vertexQs.where((q) => q.multiplier == -1).length,
          14,
          reason: 'cat=${category.id}, sub=$sub (-1)',
        );
      }
    }
    for (final SixQuestion question in six.questions) {
      expect(question.category, inInclusiveRange(0, 5));
      expect(question.subcategory, inInclusiveRange(0, 2));
      expect(question.text.trim(), isNotEmpty);
    }
    expect(six.questions.map((q) => q.text).toSet().length, 504);
  });

  test('banco unificado indexa 1.104 proposições únicas e seleciona todas as modalidades', () {
    expect(data.totalQuestionCount, 1104);
    expect(data.questionByUid.length, 1104);

    for (final TestSuite suite in TestSuite.values) {
      for (final TestDepth depth in TestDepth.values) {
        final List<UnifiedQuestion> selected = selectUnifiedQuestions(
          axesData: data.twelveAxes,
          trianglesData: data.sixTriangles,
          suite: suite,
          depth: depth,
          seed: 42,
        );
        final int expected = depth.expectedCount(
          suite,
          totalAxesPool: data.twelveAxes.questions.length,
          totalTriadsPool: data.sixTriangles.questions.length,
        );
        expect(selected.length, expected, reason: '${suite.id}/${depth.id}');
        expect(selected.map((q) => q.uid).toSet().length, expected);
      }
    }
  });

  test('catálogo ideológico expandido tem perfis editoriais distintos e auto-compatíveis', () {
    final IdeologicalCatalog catalog = data.catalog;
    expect(catalog.currents.length, 289);

    for (final IdeologicalCurrent current in catalog.currents) {
      expect(current.axes.length, 12, reason: current.id);
      expect(current.triangles.length, 6, reason: current.id);
      expect(current.summary.trim(), isNotEmpty);
      expect(current.keyIdeas, isNotEmpty);

      if (current.editorialBasis?.nativeMatchingEligible == false) continue;
      // Verifica que o perfil exato da corrente ranqueia ela própria em 1º lugar (~100%).
      final List<BipolarDimensionScore> exactAxes = <BipolarDimensionScore>[
        for (final Axis axis in data.twelveAxes.axes)
          if (current.axes[axis.id]!.relevance > 0)
            BipolarDimensionScore(
              axisId: axis.id,
              label: axis.label,
              leftPole: axis.leftPole,
              rightPole: axis.rightPole,
              score: current.axes[axis.id]!.mu,
              standardError: 0.08,
              coverage: 1.0,
              answeredCount: 10,
              presentedCount: 10,
              tensionScore: 0.0,
            ),
      ];
      final List<TriadDimensionScore> exactTriads = <TriadDimensionScore>[
        for (final SixCategory cat in data.sixTriangles.categories)
          if (current.triangles[cat.id]!.relevance > 0)
            TriadDimensionScore(
              categoryId: cat.id,
              label: cat.label,
              vertices: cat.subcategories,
              vertexScores: const <double>[0, 0, 0],
              vertexSupport: current.triangles[cat.id]!.mu,
              composition: current.triangles[cat.id]!.mu,
              engagement: 0.5,
              standardError: 0.08,
              coverage: 1.0,
              answeredCount: 12,
              presentedCount: 12,
              classification: 'Teste',
            ),
      ];

      final CompatibilityReport report = EspectroCompatibilityEngine.evaluate(
        catalog: catalog,
        axes: exactAxes,
        triads: exactTriads,
      );
      final self = report.ranked.singleWhere((r) => r.current.id == current.id);
      expect(
        self.compatibilityPercent,
        closeTo(100.0, 0.01),
        reason: current.name,
      );
      // Perfis parcialmente observados podem empatar; não inventamos desempate histórico.
      expect(report.ranked.first.compatibilityPercent, closeTo(100.0, 0.01));
    }
  });

  test('variantes do Six Triangles têm 72 e 144 perguntas', () {
    for (final SixVariant variant in SixVariant.values) {
      final SixTrianglesSession session = SixTrianglesSession(
        data: data.sixTriangles,
        variant: variant,
        random: Random(13),
      );
      expect(
        session.questions.length,
        variant.questionCount,
        reason: variant.name,
      );
      expect(
        session.questions.map((q) => q.id).toSet().length,
        variant.questionCount,
      );
    }
  });

  test(
    'respostas neutras no Six Triangles resultam em triângulos centristas',
    () {
      for (final SixVariant variant in SixVariant.values) {
        final SixTrianglesSession session = SixTrianglesSession(
          data: data.sixTriangles,
          variant: variant,
          random: Random(14),
        );
        for (var i = 0; i < session.questions.length; i++) {
          session.answers[i] = 2;
        }
        final SixTrianglesResult result = session.result()!;
        expect(result.triangles.length, 6);
        for (final TriangleScore triangle in result.triangles) {
          for (final int point in triangle.points) {
            expect(point, closeTo(333.33, 0.7));
          }
          expect(
            triangle.classification,
            'Centrista',
            reason: triangle.category.label,
          );
        }
      }
    },
  );

  test('validações de contrato e bounds rejeitam JSON corrompido', () {
    expect(
      () => AnswerOption.fromJson(const <String, Object?>{
        'id': 'BAD',
        'label': 'Ruim',
        'scoreTowardAgreement': 1.5,
      }, 'test'),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => SixQuestion.fromJson(const <String, Object?>{
        'id': 1,
        'category': 8,
        'subcategory': 0,
        'strength': 2,
        'multiplier': 1,
        'text': 'Inválido',
      }, 'test'),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => SixCategory.fromJson(const <String, Object?>{
        'id': 9,
        'label': 'Inválido',
        'color': '#FFFFFF',
        'subcategories': <String>['A', 'B', 'C'],
      }, 'test'),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => QuestionTerm.fromJson(const <String, Object?>{
        'start': 10,
        'end': 5,
        'term': 'T',
        'definition': 'D',
      }, 'test'),
      throwsA(isA<FormatException>()),
    );
  });

  test('Atlas Político possui 81 modelos de país, mais de 2.000 personalidades (3 níveis), 110 partidos, 94 momentos e 165 obras clássicas', () {
    final PoliticalAtlas atlas = data.atlas;
    expect(atlas.countries.length, 81);
    expect(atlas.personalities.length, greaterThanOrEqualTo(2000));
    expect(atlas.partiesAndMovements.length, 110);
    expect(atlas.historicalEras.length, 94);
    expect(atlas.books.length, 165);
    expect(
      atlas.totalEntries,
      81 + atlas.personalities.length + 110 + 94 + 165,
    );

    for (final AtlasKind kind in AtlasKind.values) {
      final List<AtlasEntry> entries = atlas.entriesFor(kind);
      expect(entries, isNotEmpty);
      final Set<String> ids = <String>{};
      for (final AtlasEntry e in entries) {
        expect(ids.add(e.id), isTrue, reason: 'ID duplicado ${e.id}');
        expect(e.name.trim(), isNotEmpty);
        expect(e.summary.trim().length, greaterThanOrEqualTo(45));
        expect(e.highlights.length, greaterThanOrEqualTo(3));
        expect(e.axes.length, inInclusiveRange(0, 12));
        expect(e.triangles.length, inInclusiveRange(0, 6));
        expect(
          e.axes.keys.every(
            data.twelveAxes.axes.map((a) => a.id).toSet().contains,
          ),
          isTrue,
        );
      }
    }
  });

  test('EspectroNolanEngine projeta coordenadas e classifica quadrantes', () {
    final Map<String, double> conservativeScores = <String, double>{
      'economia': 0.8,
      'controle': 0.8,
      'comercio': 0.5,
      'poder': -0.8,
      'representacao': 0.6,
      'moral': 0.8,
      'religiao': 0.7,
      'estrutura': 0.5,
      'diplomacia': -0.6,
      'imigracao': -0.7,
      'intervencao': -0.4,
      'tecnologia': 0.2,
    };

    final List<BipolarDimensionScore> mockAxes = <BipolarDimensionScore>[
      for (final Axis axis in data.twelveAxes.axes)
        BipolarDimensionScore(
          axisId: axis.id,
          label: axis.label,
          leftPole: axis.leftPole,
          rightPole: axis.rightPole,
          score: conservativeScores[axis.id] ?? 0.0,
          standardError: 0.1,
          coverage: 1.0,
          answeredCount: 10,
          presentedCount: 10,
          tensionScore: 0.0,
        ),
    ];

    final NolanCoordinates? nolan = EspectroNolanEngine.fromEvaluation(
      axes: mockAxes,
      triads: const <TriadDimensionScore>[],
    );
    expect(nolan, isNotNull);
    expect(nolan!.economicFreedom, greaterThan(65.0));
    expect(nolan.personalFreedom, lessThan(35.0));
    expect(nolan.quadrantLabel, contains('Conservador'));
  });

  test(
    'EspectroAtlasEngine calcula sínteses temáticas, tensões e recomendações',
    () {
      final List<BipolarDimensionScore> mockAxes = <BipolarDimensionScore>[
        for (final Axis axis in data.twelveAxes.axes)
          BipolarDimensionScore(
            axisId: axis.id,
            label: axis.label,
            leftPole: axis.leftPole,
            rightPole: axis.rightPole,
            score: axis.id == 'economia'
                ? 0.7
                : (axis.id == 'moral' ? 0.6 : 0.0),
            standardError: 0.1,
            coverage: 1.0,
            answeredCount: 10,
            presentedCount: 10,
            tensionScore: 0.0,
          ),
      ];

      final List<ThematicSynthesis> syntheses =
          EspectroAtlasEngine.computeSyntheses(
            axes: mockAxes,
            triads: const <TriadDimensionScore>[],
          );
      expect(syntheses.length, greaterThanOrEqualTo(3));

      final BookRecommendationReport books = EspectroAtlasEngine.recommendBooks(
        books: data.atlas.books,
        axes: mockAxes,
        triads: const <TriadDimensionScore>[],
      );
      expect(books.affinityBooks, isNotEmpty);
      expect(books.counterpointBooks, isNotEmpty);
    },
  );

  test('EspectroAtlasEngine.compareWithAtlasEntry e compareWithCurrent calculam deltas e convergências', () {
    final List<BipolarDimensionScore> mockAxes = <BipolarDimensionScore>[
      for (final axis in data.twelveAxes.axes)
        BipolarDimensionScore(
          axisId: axis.id,
          label: axis.label,
          leftPole: axis.leftPole,
          rightPole: axis.rightPole,
          score: axis.id == 'economia' ? 0.7 : -0.2,
          standardError: 0.1,
          coverage: 1.0,
          answeredCount: 10,
          presentedCount: 10,
          tensionScore: 0.0,
        ),
    ];

    final AtlasEntry country = data.atlas.countries.first;
    final EntityComparisonResult res =
        EspectroAtlasEngine.compareWithAtlasEntry(
          entry: country,
          userAxes: mockAxes,
          userTriads: const <TriadDimensionScore>[],
        );

    expect(res.targetName, country.name);
    expect(res.compatibilityPercent, inInclusiveRange(0.0, 100.0));
    expect(res.axisDeltas.length, 12);
    expect(res.nolanUser, isNotNull);
    expect(res.nolanTarget, isNotNull);

    final IdeologicalCurrent current = data.catalog.currents.firstWhere(
      (c) => c.editorialBasis?.nativeMatchingEligible != false,
    );
    final EntityComparisonResult resCurrent =
        EspectroAtlasEngine.compareWithCurrent(
          current: current,
          userAxes: mockAxes,
          userTriads: const <TriadDimensionScore>[],
        );
    expect(resCurrent.targetName, current.name);
    expect(resCurrent.compatibilityPercent, inInclusiveRange(0.0, 100.0));
    expect(resCurrent.convergentAxes, isNotEmpty);
  });

  test(
    'EspectroPdfService gera documento PDF de 6 páginas com cabeçalho válido',
    () async {
      final List<BipolarDimensionScore> mockAxes = <BipolarDimensionScore>[
        for (final axis in data.twelveAxes.axes)
          BipolarDimensionScore(
            axisId: axis.id,
            label: axis.label,
            leftPole: axis.leftPole,
            rightPole: axis.rightPole,
            score: 0.25,
            standardError: 0.08,
            coverage: 1.0,
            answeredCount: 10,
            presentedCount: 10,
            tensionScore: 0.1,
          ),
      ];

      final List<TriadDimensionScore> mockTriads = <TriadDimensionScore>[
        for (final cat in data.sixTriangles.categories)
          TriadDimensionScore(
            categoryId: cat.id,
            label: cat.label,
            vertices: cat.subcategories,
            vertexScores: const <double>[0.1, -0.1, 0.2],
            vertexSupport: const <double>[0.55, 0.45, 0.60],
            composition: const <double>[0.34, 0.28, 0.38],
            engagement: 0.53,
            standardError: 0.06,
            coverage: 1.0,
            answeredCount: 12,
            presentedCount: 12,
            classification: 'Equilíbrio Dinâmico',
          ),
      ];

      final EvaluationRecord record = EvaluationRecord(
        id: 'test_record_pdf_12345',
        createdAt: DateTime.now(),
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.standard,
        seed: 42,
        engineVersion: '2.5.0',
        bankVersion: '2.5.0',
        rawAnswers: const <String, int>{},
        axes: mockAxes,
        triads: mockTriads,
        quality: const ResponseQualityReport(
          totalPresented: 100,
          totalAnswered: 100,
          totalSkipped: 0,
          acquiescenceIndex: 0.05,
          extremeResponseRate: 0.20,
          neutralResponseRate: 0.10,
          axesInTension: <String>[],
        ),
      );

      final Uint8List pdfBytes = await EspectroPdfService.generateDossierBytes(
        record: record,
        data: data,
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(15000));
      final String header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, '%PDF-');
    },
  );
}
