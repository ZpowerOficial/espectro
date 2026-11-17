import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/charts/study_ternary_chart.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async => data = await AppData.load());
  test('barycentric mapping preserves vertices, center, and absence', () {
    const size = Size(320, 240);
    final vertices = StudyTernaryGeometry.vertices(size);
    for (var i = 0; i < 3; i++) {
      final composition = List.generate(3, (j) => i == j ? 1.0 : 0.0);
      expect(StudyTernaryGeometry.project(composition, size), vertices[i]);
      final probed = StudyTernaryGeometry.probe(vertices[i], size)!;
      for (var j = 0; j < 3; j++) {
        expect(probed[j], closeTo(composition[j], 1e-8));
      }
    }
    final center = StudyTernaryGeometry.project([1 / 3, 1 / 3, 1 / 3], size)!;
    expect(center, (vertices[0] + vertices[1] + vertices[2]) / 3);
    expect(StudyTernaryGeometry.project(null, size), null);
    expect(StudyTernaryGeometry.project([0, 0, 0], size), null);
    expect(StudyTernaryGeometry.project([double.nan, 0, 1], size), null);
    expect(StudyTernaryGeometry.probe(Offset.zero, size), null);
    expect(
      (vertices[1] - vertices[0]).distance,
      closeTo((vertices[2] - vertices[0]).distance, 1e-8),
    );
  });
  for (final brightness in Brightness.values) {
    testWidgets(
      'visual composition and exploration respect absence at 2x $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final semantics = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: brightness),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: const Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(22),
                    child: StudyTernaryChart(
                      vertices: ['Controle', 'Regulação', 'Mercados'],
                      series: [
                        StudyTernarySeries('Perfil conhecido', [
                          .25,
                          .6,
                          .15,
                        ], Colors.blue),
                        StudyTernarySeries(
                          'Perfil sem dados',
                          null,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(RegExp('Triângulo: A Controle')),
          findsOneWidget,
        );
        expect(find.text('Sem composição documentada'), findsOneWidget);
        final chartPaint = find
            .descendant(
              of: find.byType(StudyTernaryChart),
              matching: find.byType(CustomPaint),
            )
            .first;
        final origin = tester.getTopLeft(chartPaint);
        final size = tester.getSize(chartPaint);
        await tester.tapAt(
          origin + StudyTernaryGeometry.project([1 / 3, 1 / 3, 1 / 3], size)!,
        );
        await tester.pump();
        expect(find.textContaining('Área explorada:'), findsOneWidget);
        expect(find.textContaining('não altera o perfil'), findsOneWidget);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }
  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'profile exposes all six triangles and scroll remains usable at 2x $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
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
            theme: buildAppTheme(),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 1000),
                textScaler: const TextScaler.linear(2),
              ),
              child: StudyProfileScreen(
                appViewModel: vm,
                subjectKey: 'current:fascismo_historico',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Dimensões'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dimensões'));
        await tester.pumpAndSettle();
        final scrollable = find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first;
        final position = tester.state<ScrollableState>(scrollable).position;
        final seen = <String>{};
        for (var i = 0; i < 80; i++) {
          for (final chart in tester.widgetList<StudyTernaryChart>(
            find.byType(StudyTernaryChart),
          )) {
            seen.add(chart.vertices.join('/'));
          }
          if (position.pixels >= position.maxScrollExtent - 1) break;
          // A vertical gesture over a chart must keep scrolling the profile.
          await tester.drag(scrollable, const Offset(0, -400));
          await tester.pumpAndSettle();
        }
        expect(seen, hasLength(6));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
