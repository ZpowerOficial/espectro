import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/charts/study_constellation.dart';

const liberal = StudySubject(
  key: 'current:a',
  name: 'Perfil A',
  kind: 'current',
  kindLabel: 'Corrente',
  family: 'Liberais',
  axes: {'economia': .7, 'poder': .8},
);
const dirigist = StudySubject(
  key: 'current:b',
  name: 'Perfil B',
  kind: 'current',
  kindLabel: 'Corrente',
  family: 'Dirigistas',
  axes: {'economia': -.7, 'poder': -.8},
);
const incomplete = StudySubject(
  key: 'current:missing',
  name: 'Perfil sem base civil',
  kind: 'current',
  kindLabel: 'Corrente',
  axes: {'economia': .5},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async => data = await AppData.load());
  test(
    'projection is stable and does not fill a missing basis with neutrality',
    () {
      final original = StudyConstellationGeometry.position(liberal);
      expect(original, isNotNull);
      expect(StudyConstellationGeometry.position(liberal), original);
      expect(StudyConstellationGeometry.position(incomplete), isNull);
      expect(StudyConstellationGeometry.position(dirigist), isNot(original));
      expect(
        StudyConstellationGeometry.familyColor('Liberais', dark: false),
        StudyConstellationGeometry.familyColor('Liberais', dark: false),
      );
    },
  );

  testWidgets(
    'reduced motion settles, nodes select by stable position and zoom works',
    (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();
      StudySubject? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(900, 900),
                disableAnimations: true,
              ),
              child: SingleChildScrollView(
                child: StudyConstellation(
                  subjects: const [liberal, dirigist, incomplete],
                  selected: null,
                  onSelected: (subject) => selected = subject,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(
        find.semantics.byLabel(RegExp('Teia de ideias')).evaluate(),
        hasLength(1),
      );
      expect(
        find.textContaining('1 perfis sem base suficiente'),
        findsOneWidget,
      );
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final camera = viewer.transformationController!;
      final painting = find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter.runtimeType.toString() == '_ConstellationPainter',
        ),
      );
      final origin = tester.getTopLeft(painting);
      final scale = camera.value.getMaxScaleOnAxis();
      final position = StudyConstellationGeometry.position(liberal)!;
      await tester.tapAt(origin + position * scale);
      await tester.pumpAndSettle();
      expect(selected?.key, liberal.key);
      await tester.tap(find.byTooltip('Aumentar zoom'));
      await tester.pumpAndSettle();
      expect(camera.value.getMaxScaleOnAxis(), greaterThan(scale));
      await tester.tap(find.byTooltip('Reenquadrar teia'));
      await tester.pumpAndSettle();
      expect(camera.value.getMaxScaleOnAxis(), closeTo(scale, .001));
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('explicit pause stops animation scheduling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: StudyConstellation(
              subjects: const [liberal, dirigist],
              selected: liberal,
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Pausar movimento'));
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byTooltip('Ativar movimento sutil'), findsOneWidget);
  });

  testWidgets(
    'offscreen chart does not schedule motion and stops after scrolling away',
    (tester) async {
      final scroll = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scroll,
              child: Column(
                children: [
                  const SizedBox(height: 900),
                  StudyConstellation(
                    subjects: const [liberal, dirigist],
                    selected: liberal,
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 900),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      scroll.jumpTo(800);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.binding.hasScheduledFrame, isTrue);
      scroll.jumpTo(0);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox());
      scroll.dispose();
    },
  );

  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'vizinhos coincidentes usam chips legíveis e selecionáveis sem sobreposição em $width px',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final neighbours = List.generate(
          7,
          (i) => StudySubject(
            key: 'current:neighbour$i',
            name: 'Corrente de pensamento democrático e institucional $i',
            kind: 'current',
            kindLabel: 'Corrente',
            axes: const {'economia': .7, 'poder': .8},
          ),
        );
        StudySubject? selected;
        final original = StudyConstellationGeometry.position(liberal);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1000),
                  disableAnimations: true,
                  textScaler: const TextScaler.linear(2),
                ),
                child: SingleChildScrollView(
                  child: StudyConstellation(
                    subjects: [liberal, ...neighbours],
                    selected: liberal,
                    onSelected: (subject) => selected = subject,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Nesta vizinhança 2D'), findsOneWidget);
        final chips = find.byType(ActionChip);
        expect(chips, findsNWidgets(6));
        final rectangles = [
          for (var i = 0; i < 6; i++) tester.getRect(chips.at(i)),
        ];
        for (var i = 0; i < 6; i++) {
          expect(
            find.widgetWithText(ActionChip, neighbours[i].name),
            findsOneWidget,
          );
          expect(rectangles[i].width, lessThanOrEqualTo(width));
          for (var j = i + 1; j < 6; j++) {
            expect(rectangles[i].overlaps(rectangles[j]), isFalse);
          }
        }
        final last = find.byKey(
          ValueKey('study-neighbour:${neighbours[5].key}'),
        );
        await tester.ensureVisible(last);
        await tester.pumpAndSettle();
        await tester.tap(last);
        await tester.pumpAndSettle();
        expect(selected?.key, neighbours[5].key);
        expect(StudyConstellationGeometry.position(liberal), original);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('arrasto vertical na teia move câmera em vez de rolar a página', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final outer = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            controller: outer,
            child: Column(
              children: [
                const SizedBox(height: 100),
                StudyConstellation(
                  subjects: const [liberal, dirigist],
                  selected: null,
                  onSelected: (_) {},
                ),
                const SizedBox(height: 1200),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final before = viewer.transformationController!.value.clone();
    await tester.drag(find.byType(InteractiveViewer), const Offset(0, -100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      outer.offset,
      0,
      reason: 'um gesto dentro do mapa deve controlar o mapa',
    );
    expect(
      viewer.transformationController!.value.storage[13],
      isNot(before.storage[13]),
    );
    await tester.pumpWidget(const SizedBox());
    outer.dispose();
  });

  testWidgets('gesto do usuário interrompe voo de seleção sem perder o pan', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    StudySubject? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: StudyConstellation(
                subjects: const [liberal, dirigist],
                selected: selected,
                onSelected: (subject) => setState(() => selected = subject),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final camera = viewer.transformationController!;
    final origin = tester.getTopLeft(
      find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              w.painter.runtimeType.toString() == '_ConstellationPainter',
        ),
      ),
    );
    final point = StudyConstellationGeometry.position(liberal)!;
    await tester.tapAt(origin + point * camera.value.getMaxScaleOnAxis());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(selected?.key, liberal.key);
    await tester.timedDrag(
      find.byType(InteractiveViewer),
      const Offset(90, 0),
      const Duration(milliseconds: 100),
    );
    await tester.pump(const Duration(milliseconds: 30));
    final panned = camera.value.storage[12];
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      camera.value.storage[12],
      closeTo(panned, 1),
      reason: 'o voo anterior não deve sobrescrever o gesto',
    );
    await tester.tap(find.byTooltip('Pausar movimento'));
    await tester.pumpAndSettle();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.linux]) {
    testWidgets(
      'pan, pinch, zoom, toque transformado, perfil e retorno em $platform',
      (tester) async {
        final mobile = platform == TargetPlatform.android;
        tester.view.physicalSize = Size(mobile ? 390 : 1440, 1000);
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
        final subjects = [
          StudySubject.fromCurrent(
            data.catalog.currents.firstWhere(
              (s) => s.id == 'liberalismo_classico',
            ),
          ),
          StudySubject.fromCurrent(
            data.catalog.currents.firstWhere(
              (s) => s.id == 'marxismo_leninismo',
            ),
          ),
        ];
        StudySubject? selected;
        final outer = ScrollController();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme().copyWith(platform: platform),
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(mobile ? 390 : 1440, 1000),
                  disableAnimations: true,
                ),
                child: StatefulBuilder(
                  builder: (context, setState) => SingleChildScrollView(
                    controller: outer,
                    child: StudyConstellation(
                      subjects: subjects,
                      selected: selected,
                      onSelected: (subject) =>
                          setState(() => selected = subject),
                      onOpen: (subject) => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => StudyProfileScreen(
                            appViewModel: vm,
                            subjectKey: subject.key,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final viewerFinder = find.byType(InteractiveViewer);
        final camera = tester
            .widget<InteractiveViewer>(viewerFinder)
            .transformationController!;
        final initial = camera.value.clone();
        final center = tester.getCenter(viewerFinder);
        final first = await tester.startGesture(
          center - const Offset(30, 0),
          pointer: 11,
        );
        final second = await tester.startGesture(
          center + const Offset(30, 0),
          pointer: 12,
        );
        await tester.pump();
        await first.moveTo(center - const Offset(65, 0));
        await second.moveTo(center + const Offset(65, 0));
        await tester.pump();
        await first.up();
        await second.up();
        await tester.pumpAndSettle();
        expect(
          camera.value.getMaxScaleOnAxis(),
          greaterThan(initial.getMaxScaleOnAxis() * 1.6),
        );
        expect(selected, isNull, reason: 'pinch não deve acionar um perfil');
        expect(outer.offset, 0);
        await tester.tap(find.byTooltip('Reenquadrar teia'));
        await tester.pumpAndSettle();
        expect(
          camera.value.getMaxScaleOnAxis(),
          closeTo(initial.getMaxScaleOnAxis(), .0001),
        );
        await tester.tap(find.byTooltip('Aumentar zoom'));
        await tester.pumpAndSettle();
        final zoomed = camera.value.getMaxScaleOnAxis();
        expect(zoomed, greaterThan(initial.getMaxScaleOnAxis()));
        if (!mobile) {
          await tester.sendEventToBinding(
            PointerScrollEvent(
              position: center,
              scrollDelta: const Offset(0, -50),
            ),
          );
          await tester.pumpAndSettle();
          expect(camera.value.getMaxScaleOnAxis(), greaterThan(zoomed));
        }
        final beforePan = camera.value.storage[12];
        final pan = await tester.startGesture(
          center,
          kind: mobile ? PointerDeviceKind.touch : PointerDeviceKind.mouse,
        );
        await pan.moveBy(const Offset(22, 18));
        await tester.pump();
        await pan.up();
        await tester.pumpAndSettle();
        expect(camera.value.storage[12], isNot(beforePan));
        expect(outer.offset, 0);
        final origin = tester.getTopLeft(viewerFinder);
        final stableViewportTop = origin;
        final scene = StudyConstellationGeometry.position(subjects.first)!;
        final renderedPoint =
            origin + MatrixUtils.transformPoint(camera.value, scene);
        expect(tester.getRect(viewerFinder).contains(renderedPoint), isTrue);
        final tap = await tester.startGesture(
          renderedPoint,
          kind: mobile ? PointerDeviceKind.touch : PointerDeviceKind.mouse,
        );
        await tap.up();
        await tester.pumpAndSettle();
        expect(
          selected?.key,
          subjects.first.key,
          reason: 'toque usa a mesma transformação da pintura após pan e zoom',
        );
        expect(
          tester.getTopLeft(viewerFinder),
          stableViewportTop,
          reason: 'seleção não desloca o canvas com novo layout',
        );
        final open = find.byKey(const ValueKey('study-map-open-profile'));
        await tester.ensureVisible(open);
        await tester.pumpAndSettle();
        final beforeProfile = camera.value.clone();
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(find.byType(StudyProfileScreen), findsOneWidget);
        expect(find.text('Liberalismo Clássico'), findsOneWidget);
        tester.state<NavigatorState>(find.byType(Navigator).first).pop();
        await tester.pumpAndSettle();
        expect(find.byType(StudyConstellation), findsOneWidget);
        expect(selected?.key, subjects.first.key);
        expect(camera.value.storage, orderedEquals(beforeProfile.storage));
        final chip = find.byKey(
          ValueKey('study-neighbour:${subjects.last.key}'),
        );
        await tester.ensureVisible(chip);
        await tester.pumpAndSettle();
        await tester.tap(chip);
        await tester.pumpAndSettle();
        expect(selected?.key, subjects.last.key);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        outer.dispose();
        vm.dispose();
      },
    );
  }

  testWidgets(
    'perfis na mesma coordenada têm seleção acessível independente sem alvos sobrepostos',
    (tester) async {
      const overlapping = StudySubject(
        key: 'current:overlap',
        name: 'Outra corrente',
        kind: 'current',
        kindLabel: 'Corrente',
        axes: {'economia': .7, 'poder': .8},
      );
      StudySubject? selected;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 1000),
                disableAnimations: true,
              ),
              child: StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  child: StudyConstellation(
                    subjects: const [liberal, overlapping],
                    selected: selected,
                    onSelected: (subject) => setState(() => selected = subject),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        StudyConstellationGeometry.position(liberal),
        StudyConstellationGeometry.position(overlapping),
      );
      expect(
        find.semantics.byLabel('Perfil A').evaluate(),
        isEmpty,
        reason:
            'o canvas não cria botões DOM invisíveis sobre a mesma coordenada',
      );
      final choose = find.byKey(const ValueKey('study-map-choose'));
      await tester.ensureVisible(choose);
      await tester.tap(choose);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('study-map-choice:current:a')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('study-map-choice:current:overlap')),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar um perfil na teia'),
        'Outra',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('study-map-choice:current:a')),
        findsNothing,
      );
      await tester.tap(
        find.byKey(const ValueKey('study-map-choice:current:overlap')),
      );
      await tester.pumpAndSettle();
      expect(selected?.key, overlapping.key);
      await tester.ensureVisible(choose);
      await tester.tap(choose);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('study-map-choice:current:a')),
      );
      await tester.pumpAndSettle();
      expect(selected?.key, liberal.key);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
