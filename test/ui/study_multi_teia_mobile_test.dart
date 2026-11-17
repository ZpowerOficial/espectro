import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/charts/study_constellation.dart';
import 'package:politico/ui/features/atlas/study_map_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async => data = await AppData.load());

  testWidgets('mobile multi-teia renders clean full-size teia with tab strip and switching without overflows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
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

    // Starts with 1 single full-size teia
    expect(find.byType(StudyConstellation), findsOneWidget);
    expect(find.byKey(const ValueKey('mobile-teia-tab-0')), findsNothing);

    // Add 2nd teia using app bar action
    await tester.tap(find.byKey(const ValueKey('add-teia-btn')));
    await tester.pumpAndSettle();

    // Mobile strip appears with Teia 1 and Teia 2 tabs
    expect(find.byKey(const ValueKey('mobile-teia-tab-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('mobile-teia-tab-1')), findsOneWidget);
    expect(find.text('Teia 1'), findsOneWidget);
    expect(find.text('Teia 2'), findsOneWidget);

    // Switch to Teia 2 by tapping tab
    await tester.tap(find.byKey(const ValueKey('mobile-teia-tab-1')));
    await tester.pumpAndSettle();

    // Add 3rd teia using strip + button
    await tester.tap(find.byKey(const ValueKey('add-teia-strip-btn')));
    await tester.pumpAndSettle();
    expect(find.text('Teia 3'), findsOneWidget);

    // Remove active teia (Teia 3)
    final removeBtn = find.descendant(
      of: find.byKey(const ValueKey('mobile-teia-tab-2')),
      matching: find.byTooltip('Remover esta teia'),
    );
    if (removeBtn.evaluate().isNotEmpty) {
      await tester.tap(removeBtn);
      await tester.pumpAndSettle();
    }

    // No rendering overflow exceptions
    expect(tester.takeException(), isNull);
  });
}
