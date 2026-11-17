import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/charts/study_constellation.dart';
import 'package:politico/ui/features/atlas/study_map_screen.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async => data = await AppData.load());

  test('square Nolan keeps corners and alternate projections preserve missing data', () {
    const subject = StudySubject(
      key: 'current:x',
      name: 'X',
      kind: 'current',
      kindLabel: 'Corrente',
      axes: {'economia': 1, 'poder': -1},
    );
    final economy = data.twelveAxes.axes.firstWhere((a) => a.id == 'economia');
    final power = data.twelveAxes.axes.firstWhere((a) => a.id == 'poder');
    expect(StudyConstellationGeometry.canvasSize, const Size(880, 880));
    expect(
      StudyConstellationGeometry.position(
        subject,
        projection: StudyMapProjection.axes(economy, power),
      ),
      const Offset(780, 780),
    );
    expect(
      StudyConstellationGeometry.position(
        subject,
        projection: StudyMapProjection.axes(
          economy,
          data.twelveAxes.axes.first,
        ),
      ),
      isNull,
    );
  });

  test('every current appears in the map or separate unplaced tray without imputation', () {
    final currents = StudyCatalog(data).search('', kind: 'current');
    final points = StudyConstellationGeometry.layout(currents);
    expect(currents.length, greaterThan(275));
    expect(
      points.map((p) => p.$1.key).toSet(),
      currents.map((s) => s.key).toSet(),
    );
    for (final point in points) {
      if (StudyConstellationGeometry.position(point.$1) == null) {
        expect(point.$2.dx, greaterThan(800));
      } else {
        expect(point.$2, StudyConstellationGeometry.position(point.$1));
      }
    }
  });

  test('eight spectra sort every current into contiguous groups', () {
    expect(studySpectra.map((s) => s.id), [
      'radical_left',
      'left',
      'center',
      'right',
      'far_right',
      'anarchist',
      'libertarian',
      'third_position',
    ]);
    final subjects = StudyCatalog(data).search('', kind: 'current')
      ..sort(compareStudySubjects);
    final ranks = subjects
        .map((s) => studySpectra.indexOf(spectrumOf(s)!))
        .toList();
    expect(ranks, orderedEquals([...ranks]..sort()));
    expect(ranks.toSet(), hasLength(8));
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets('fullscreen map all currents pan and twelve axes at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final vm = AppViewModel(
        data: data,
        repository: EvaluationRepository(
          storage: LocalStorageService.inMemory(),
        ),
      );
      await vm.initialize();
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.light),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: StudyMapScreen(appViewModel: vm),
        ),
      );
      await tester.pumpAndSettle();
      StudyConstellation graph() =>
          tester.widget<StudyConstellation>(find.byType(StudyConstellation));
      expect(graph().subjects.length, data.catalog.currents.length);
      expect(graph().subjects.every((s) => s.kind == 'current'), isTrue);
      expect(graph().expanded, isTrue);
      final canvas = find.byType(InteractiveViewer);
      expect(tester.getSize(canvas).width, width);
      expect(tester.getSize(canvas).height, greaterThan(750));
      expect(
        find.ancestor(of: canvas, matching: find.byType(Scrollable)),
        findsNothing,
      );
      final camera = tester
          .widget<InteractiveViewer>(canvas)
          .transformationController!;
      final before = camera.value.storage.toList();
      await tester.dragFrom(Offset(width / 2, 440), const Offset(70, 40));
      await tester.pumpAndSettle();
      expect(camera.value.storage, isNot(before));
      await tester.tap(find.byTooltip('Escolher eixos'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '12 eixos'));
      await tester.pumpAndSettle();
      final dropdowns = tester
          .widgetList<DropdownButton<String>>(
            find.byType(DropdownButton<String>),
          )
          .toList();
      expect(dropdowns, hasLength(2));
      expect(dropdowns.first.items, hasLength(12));
      expect(
        dropdowns.first.items!.map((i) => i.value).toSet(),
        data.twelveAxes.axes.map((a) => a.id).toSet(),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
