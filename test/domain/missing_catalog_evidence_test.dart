import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/engine/atlas_and_nolan_engine.dart';
import 'package:politico/domain/models/atlas_models.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/charts/nolan_diagram_chart.dart';
import 'package:politico/ui/features/compare/entity_comparison_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

BipolarDimensionScore axis(String id, double value) => BipolarDimensionScore(
  axisId: id,
  label: id,
  leftPole: 'A',
  rightPole: 'B',
  score: value,
  standardError: .1,
  coverage: 1,
  answeredCount: 4,
  presentedCount: 4,
  tensionScore: 0,
);
TriadDimensionScore triad(
  int id,
  List<double> composition, {
  double engagement = .5,
}) => TriadDimensionScore(
  categoryId: id,
  label: 'Tríade $id',
  vertices: ['A', 'B', 'C'],
  vertexScores: [0, 0, 0],
  vertexSupport: [.5, .5, .5],
  composition: composition,
  engagement: engagement,
  standardError: .1,
  coverage: 1,
  answeredCount: 6,
  presentedCount: 6,
  classification: 'sintético',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async {
    data = await AppData.load();
  });
  IdeologicalCurrent current(String id) =>
      data.catalog.currents.firstWhere((c) => c.id == id);
  IdeologicalCurrent emptyCurrent(String id) => IdeologicalCurrent(
    id: id,
    name: 'Corrente Sem Evidência',
    family: 'Teste',
    summary: 'Sem evidência para teste de omissão',
    keyIdeas: const [],
    axes: {
      'economia': const CurrentAxisProfile(mu: 0, sigma: 0.65, relevance: 0, note: ''),
      'poder': const CurrentAxisProfile(mu: 0, sigma: 0.65, relevance: 0, note: ''),
    },
    triangles: const {},
  );

  test(
    'Nolan omits a missing basis but retains an observed neutral position',
    () {
      expect(EspectroNolanEngine.fromRawMaps(axes: {}, triangles: {}), isNull);
      expect(
        EspectroNolanEngine.fromRawMaps(axes: {'economia': .9}, triangles: {}),
        isNull,
      );
      expect(
        EspectroNolanEngine.fromRawMaps(axes: {'poder': .9}, triangles: {}),
        isNull,
      );
      final neutral = EspectroNolanEngine.fromRawMaps(
        axes: {'economia': 0, 'poder': 0},
        triangles: {},
      );
      expect(neutral, isNotNull);
      expect(neutral!.economicFreedom, 50);
      expect(neutral.personalFreedom, 50);
    },
  );

  test('new currents with excluded economics or civil evidence never acquire a fabricated center', () {
    expect(
      EspectroNolanEngine.fromCurrent(emptyCurrent('anarquismo_egoista')),
      isNull,
    );
    expect(
      EspectroNolanEngine.fromCurrent(emptyCurrent('socialismo_de_mercado')),
      isNull,
    );
    expect(
      EspectroNolanEngine.fromCurrent(current('socialismo_marxista')),
      isNotNull,
    );
  });

  test('native current comparison excludes relevance zero and has no score without overlap', () {
    final result = EspectroAtlasEngine.compareWithCurrent(
      current: emptyCurrent('anarquismo_egoista'),
      userAxes: [axis('economia', 0)],
      userTriads: [],
    );
    expect(result.axisDeltas, isEmpty);
    expect(result.compatibilityPercent, isNull);
    expect(result.rmsd, isNull);
    expect(result.nolanTarget, isNull);
    expect(result.nolanUser, isNull);
    expect(result.evaluatedDimensions, 0);
  });

  test('native Atlas comparison preserves both missing projections and missing affinity', () {
    final realEntry = data.atlas.books.firstWhere(
      (b) => b.id == 'acao_humana_mises',
    );
    expect(EspectroNolanEngine.fromAtlasEntry(realEntry), isNotNull);

    final partialEntry = AtlasEntry(
      id: 'partial_test_book',
      kind: realEntry.kind,
      name: 'Obra Parcial Sem Eixo Poder',
      subtitle: 'Ludwig von Mises',
      category: 'Economia',
      era: '1949',
      origin: 'Áustria',
      spectrumId: 'libertarian',
      summary: 'Entrada sintética parcial para validar omissão sem eixo poder',
      highlights: const [],
      quote: null,
      axes: const {'economia': 0.96},
      triangles: const {},
    );
    expect(EspectroNolanEngine.fromAtlasEntry(partialEntry), isNull);
    final result = EspectroAtlasEngine.compareWithAtlasEntry(
      entry: partialEntry,
      userAxes: [axis('poder', .9)],
      userTriads: [],
    );
    expect(result.nolanTarget, isNull);
    expect(result.compatibilityPercent, isNull);
    expect(result.axisDeltas, isEmpty);
  });

  test('triad-only current comparison uses observed compositions and absolute engagement', () {
    final target = current('libertarianismo_minarquista');
    final mean = target.triangles[0]!.mu;
    final matching = EspectroAtlasEngine.compareWithCurrent(
      current: target,
      userAxes: [],
      userTriads: [triad(0, mean)],
    );
    final rejection = EspectroAtlasEngine.compareWithCurrent(
      current: target,
      userAxes: [],
      userTriads: [triad(0, mean, engagement: 0)],
    );
    expect(matching.axisDeltas, isEmpty);
    expect(matching.triadDeltas.keys, contains(0));
    expect(matching.evaluatedDimensions, 1);
    expect(matching.compatibilityPercent, closeTo(100, .001));
    expect(
      rejection.compatibilityPercent,
      lessThan(matching.compatibilityPercent!),
    );
    expect(matching.nolanUser, isNull);
  });

  testWidgets(
    'native comparison states no evidence rather than painting a 100% center',
    (tester) async {
      final vm = AppViewModel(
        data: data,
        repository: EvaluationRepository(
          storage: LocalStorageService.inMemory(),
        ),
      );
      await vm.initialize();
      final comparison = EspectroAtlasEngine.compareWithCurrent(
        current: emptyCurrent('anarquismo_egoista'),
        userAxes: [axis('economia', 0)],
        userTriads: [],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: EntityComparisonScreen(
            comparison: comparison,
            appViewModel: vm,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsNothing);
      expect(find.textContaining('Sem dimensões em comum'), findsWidgets);
      expect(find.byType(NolanDiagramChart), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
