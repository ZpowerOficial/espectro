import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/charts/study_constellation.dart';
import 'package:politico/ui/features/atlas/study_map_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

import 'package:politico/domain/models/study_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async => data = await AppData.load());

  testWidgets('multi-teia allows up to 4 simultaneous projections with cross-selection and removal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final vm = AppViewModel(
      data: data,
      repository: EvaluationRepository(storage: LocalStorageService.inMemory()),
    );
    await vm.initialize();
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.dark),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: StudyMapScreen(appViewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    // Starts with 1 teia
    expect(find.byType(StudyConstellation), findsOneWidget);
    expect(find.text('+ Teia (1/4)'), findsOneWidget);
    expect(find.text('AUTORITARISMO ↑'), findsOneWidget);
    expect(find.text('ANARQUISMO ↓'), findsOneWidget);

    // Add 2nd teia
    await tester.tap(find.byKey(const ValueKey('add-teia-btn')));
    await tester.pumpAndSettle();
    expect(find.byType(StudyConstellation), findsNWidgets(2));
    expect(find.text('+ Teia (2/4)'), findsOneWidget);

    // Add 3rd teia
    await tester.tap(find.byKey(const ValueKey('add-teia-btn')));
    await tester.pumpAndSettle();
    expect(find.byType(StudyConstellation), findsNWidgets(3));
    expect(find.text('+ Teia (3/4)'), findsOneWidget);

    // Add 4th teia
    await tester.tap(find.byKey(const ValueKey('add-teia-btn')));
    await tester.pumpAndSettle();
    expect(find.byType(StudyConstellation), findsNWidgets(4));
    // At 4 teias, the "+ Teia" button is hidden
    expect(find.byKey(const ValueKey('add-teia-btn')), findsNothing);

    // Cross-synchronized selection: selecting an item selects it in the inspector
    final subject = StudyCatalog(data)
        .search('', kind: 'current')
        .firstWhere((s) => s.current?.id == 'anarcocapitalismo');
    // Find first interactive viewer to tap on ancap
    final point = StudyConstellationGeometry.position(subject)!;
    final viewer = tester.firstWidget<InteractiveViewer>(find.byType(InteractiveViewer));
    final scale = viewer.transformationController!.value.getMaxScaleOnAxis();
    final firstCustomPaint = find.descendant(
      of: find.byType(InteractiveViewer).first,
      matching: find.byType(CustomPaint),
    ).first;
    final origin = tester.getTopLeft(firstCustomPaint);
    await tester.tapAt(origin + point * scale);
    await tester.pumpAndSettle();

    // Verify inspector opened with Anarcocapitalismo
    expect(find.text('Anarcocapitalismo'), findsWidgets);
    expect(find.text('OS 12 EIXOS'), findsOneWidget);

    // Verify remove button works: close inspector first, then remove a teia
    await tester.tap(find.byTooltip('Fechar detalhes'));
    await tester.pumpAndSettle();
    expect(find.text('OS 12 EIXOS'), findsNothing);

    final closeButtons = find.byTooltip('Remover esta teia');
    expect(closeButtons, findsNWidgets(4));
    await tester.tap(closeButtons.last);
    await tester.pumpAndSettle();

    // Now 3 teias remain, and "+ Teia (3/4)" is visible again
    expect(find.byType(StudyConstellation), findsNWidgets(3));
    expect(find.text('+ Teia (3/4)'), findsOneWidget);
  });
}
