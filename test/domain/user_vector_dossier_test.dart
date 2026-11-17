import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/pdf_export_service.dart';
import 'package:politico/domain/engine/atlas_and_nolan_engine.dart';
import 'package:politico/domain/engine/compatibility_engine.dart';
import 'package:politico/domain/engine/scoring_engine.dart';
import 'package:politico/domain/models/political_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late Map<String, dynamic> fixture;
  late List<BipolarDimensionScore> axes;
  late List<TriadDimensionScore> triads;
  setUpAll(() async {
    data = await AppData.load();
    fixture = jsonDecode(
      File('test/fixtures/reported_quick_vector.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    axes = [
      for (final axis in data.twelveAxes.axes)
        BipolarDimensionScore(
          axisId: axis.id,
          label: axis.label,
          leftPole: axis.leftPole,
          rightPole: axis.rightPole,
          score: (fixture['axes'][axis.id] as num).toDouble(),
          // Synthetic uncertainty: the source PDF does not expose SE per axis.
          standardError: .20,
          coverage: 1,
          answeredCount: 2,
          presentedCount: 2,
          tensionScore: 0,
        ),
    ];
    triads = [
      for (final cat in data.sixTriangles.categories)
        TriadDimensionScore(
          categoryId: cat.id,
          label: cat.label,
          vertices: cat.subcategories,
          vertexScores: const [0, 0, 0],
          vertexSupport: const [.5, .5, .5],
          composition: (fixture['triads']['${cat.id}'] as List)
              .map((x) => (x as num).toDouble())
              .toList(),
          engagement: (fixture['engagement']['${cat.id}'] as num).toDouble(),
          standardError: .15,
          coverage: 1,
          answeredCount: 6,
          presentedCount: 6,
          classification:
              'Composição transcrita; apoios por vértice indisponíveis',
        ),
    ];
  });
  test(
    'transcription preserves every source axis; no shifted or invented key',
    () {
      expect(
        (fixture['axes'] as Map).keys.toSet(),
        data.twelveAxes.axes.map((a) => a.id).toSet(),
      );
      expect(axes.firstWhere((a) => a.axisId == 'representacao').score, -1);
      expect(axes.firstWhere((a) => a.axisId == 'poder').score, .11);
      expect(axes.firstWhere((a) => a.axisId == 'imigracao').score, .5);
      expect(axes.firstWhere((a) => a.axisId == 'diplomacia').score, .11);
      expect(axes.firstWhere((a) => a.axisId == 'tecnologia').score, -.25);
      final nolan = EspectroNolanEngine.fromEvaluation(
        axes: axes,
        triads: triads,
      )!;
      expect(nolan.economicFreedom, closeTo(98.8, .15));
      expect(nolan.personalFreedom, closeTo(80.9, .15));
      expect(axes.every((a) => a.confidence == ScoreConfidence.moderate), true);
      expect(triads.every((a) => a.confidence == ScoreConfidence.low), true);
    },
  );
  test(
    'ranking does not force a label and excludes sparse coverage consistently',
    () {
      final report = EspectroCompatibilityEngine.evaluate(
        catalog: data.catalog,
        axes: axes,
        triads: triads,
      );
      expect(report.ranked, hasLength(data.catalog.currents.length));
      for (final r in report.ranked) {
        expect(r.evaluatedDimensions, 18);
        expect(r.compatibilityPercent, inInclusiveRange(0, 100));
      }

      final sparseCurrent = IdeologicalCurrent(
        id: 'corrente_esparsa_teste',
        name: 'Corrente Esparsa',
        family: 'Teste',
        summary: 'Corrente sintética com menos de 8 dimensões',
        keyIdeas: const [],
        axes: {
          'economia': const CurrentAxisProfile(
            mu: 0.5,
            sigma: 0.35,
            relevance: 0.8,
            note: 'Eixo único observado.',
          ),
        },
        triangles: const {},
      );
      final sparseCatalog = IdeologicalCatalog(
        schemaVersion: data.catalog.schemaVersion,
        catalogVersion: data.catalog.catalogVersion,
        currents: [...data.catalog.currents, sparseCurrent],
      );
      final sparseReport = EspectroCompatibilityEngine.evaluate(
        catalog: sparseCatalog,
        axes: axes,
        triads: triads,
      );
      expect(
        sparseReport.ranked.any((r) => r.current.id == 'corrente_esparsa_teste'),
        false,
      );

      final synth = EspectroAtlasEngine.computeSyntheses(
        axes: axes,
        triads: triads,
      );
      expect(
        synth.any((s) => s.title == 'Comércio Aberto e Não Intervenção'),
        true,
      );
    },
  );
  test('eligibility depends on coverage rather than regime or spectrum', () {
    for (final c in data.catalog.currents) {
      final dimensions =
          c.axes.values.where((v) => v.relevance > 0).length +
          c.triangles.values.where((v) => v.relevance > 0).length;
      expect(
        c.editorialBasis!.nativeMatchingEligible,
        dimensions >= 8,
        reason: c.id,
      );
    }
  });
  test(
    'local original 60-answer replay preserves published scores and exposes tensions',
    () async {
      final input = File('/tmp/espectro-raw-quick-session.json');
      expect(input.existsSync(), true);
      final raw = jsonDecode(input.readAsStringSync()) as Map<String, dynamic>;
      final answers = (raw['rawAnswers'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toInt()),
      );
      final axisMap = {for (final q in data.twelveAxes.questions) q.id: q};
      final triMap = {for (final q in data.sixTriangles.questions) q.id: q};
      final questions = <UnifiedQuestion>[
        for (final uid in answers.keys)
          if (uid.startsWith('axis:'))
            UnifiedQuestion.bipolar(axisMap[uid.substring(5)]!)
          else if (uid.startsWith('tri:'))
            UnifiedQuestion.triad(triMap[int.parse(uid.substring(4))]!),
      ];
      expect(questions.map((q) => q.uid).toSet(), answers.keys.toSet());
      final replay = EspectroScoringEngine.evaluate(
        axesData: data.twelveAxes,
        trianglesData: data.sixTriangles,
        suite: TestSuite.espectroIntegrated,
        questions: questions,
        rawAnswersByUid: answers,
      );
      for (final axis in replay.axes) {
        expect(
          axis.score,
          closeTo((fixture['axes'][axis.axisId] as num).toDouble(), .0051),
          reason: axis.axisId,
        );
        expect(axis.confidence, isIn(ScoreConfidence.values));
      }
      expect(replay.quality.totalAnswered, 60);
      expect(replay.quality.axesInTension.toSet(), {
        'Poder',
        'Imigração',
        'Diplomacia',
        'Intervenção',
        'Moral',
      });
      expect(
        replay.triads.every((t) => t.confidence == ScoreConfidence.low),
        true,
      );
      final record = EvaluationRecord(
        id: 'sessao_real_reprocessada',
        createdAt: DateTime(2026, 11, 5),
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: raw['seed'] as int,
        engineVersion: kEspectroEngineVersion,
        bankVersion: kEspectroBankVersion,
        rawAnswers: answers,
        axes: replay.axes,
        triads: replay.triads,
        quality: replay.quality,
      );
      final dir = Directory('build/artifacts/dossier-audit')
        ..createSync(recursive: true);
      File('${dir.path}/resultado_reprocessado_60_respostas.pdf')
          .writeAsBytesSync(
            await EspectroPdfService.generateDossierBytes(
              record: record,
              data: data,
            ),
          );
      File('${dir.path}/record_reprocessado.json')
          .writeAsStringSync(jsonEncode(record.toJson()));
      File('${dir.path}/replay-summary.json').writeAsStringSync(
        jsonEncode({
          'source': '60 respostas originais decodificadas localmente do link fornecido',
          'questionSetExact': true,
          'answers': 60,
          'engineVersion': kEspectroEngineVersion,
          'axesInTension': replay.quality.axesInTension,
          'ranked':
              EspectroCompatibilityEngine.evaluate(
                    catalog: data.catalog,
                    axes: replay.axes,
                    triads: replay.triads,
                  ).ranked
                  .take(6)
                  .map(
                    (r) => {
                      'id': r.current.id,
                      'index': r.compatibilityPercent,
                      'sharedDimensions': r.evaluatedDimensions,
                    },
                  )
                  .toList(),
        }),
      );
    },
    skip: !File('/tmp/espectro-raw-quick-session.json').existsSync()
        ? 'Sessão privada não disponível; replay real não executado'
        : false,
  );
  test('reconstructed report is explicitly partial and never overwrites source PDF', () async {
    final record = EvaluationRecord(
      id: 'reconstrucao_parcial_pdf',
      createdAt: DateTime(2026, 11, 5),
      suite: TestSuite.espectroIntegrated,
      depth: TestDepth.quick,
      seed: 0,
      engineVersion: 'audit-rounded-vector',
      bankVersion: 'unknown',
      rawAnswers: const {},
      axes: axes,
      triads: triads,
      quality: const ResponseQualityReport(
        totalPresented: 60,
        totalAnswered: 60,
        totalSkipped: 0,
        acquiescenceIndex: 0,
        extremeResponseRate: 0,
        neutralResponseRate: 0,
        axesInTension: [],
      ),
    );
    final pdf = await EspectroPdfService.generateDossierBytes(
      record: record,
      data: data,
    );
    expect(pdf.length, greaterThan(20000));
    final out = Directory('build/artifacts/dossier-audit')
      ..createSync(recursive: true);
    File('${out.path}/reconstrucao_parcial.pdf').writeAsBytesSync(pdf);
    File('${out.path}/ranking.json').writeAsStringSync(
      jsonEncode({
        'notice': fixture['provenance'],
        'uncertainty': 'Sintética: os erros-padrão e as respostas originais não estão no PDF.',
        'ranked':
            EspectroCompatibilityEngine.evaluate(
                  catalog: data.catalog,
                  axes: axes,
                  triads: triads,
                ).ranked
                .take(6)
                .map(
                  (r) => {
                    'id': r.current.id,
                    'index': r.compatibilityPercent,
                    'sharedDimensions': r.evaluatedDimensions,
                  },
                )
                .toList(),
      }),
    );
  });
}
