import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/app.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/features/atlas/atlas_explorer_screen.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/ui/charts/study_constellation.dart';
import 'package:politico/ui/features/compare/study_comparison_screen.dart';
import 'package:politico/ui/features/history/history_evolution_screen.dart';
import 'package:politico/ui/features/methodology/methodology_screen.dart';
import 'package:politico/ui/features/quiz/espectro_intro_screen.dart';
import 'package:politico/ui/features/quiz/espectro_quiz_screen.dart';
import 'package:politico/ui/features/quiz/espectro_suites_screen.dart';
import 'package:politico/ui/features/results/espectro_result_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async {
    data = await AppData.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final family in ['IBMPlexSans', 'IBMPlexMono']) {
      final loader = FontLoader(family);
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        loader.addFont(rootBundle.load('assets/fonts/$family-$weight.ttf'));
      }
      await loader.load();
    }
  });
  for (final dark in [false, true]) {
    for (final size in [const Size(390, 844), const Size(1440, 900)]) {
      testWidgets(
        'Figma: navegação e relatório ${dark ? 'escuro' : 'claro'} $size',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repo = EvaluationRepository(
            storage: LocalStorageService.inMemory(),
          );
          final vm = AppViewModel(data: data, repository: repo);
          await vm.initialize();
          await vm.setThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
          final quiz = QuizViewModel.startNew(
            data: data,
            repository: repo,
            suite: TestSuite.espectroIntegrated,
            depth: TestDepth.quick,
            seed: 55,
          );
          for (var i = 0; i < quiz.totalCount; i++) {
            quiz.jumpTo(i);
            quiz.selectAnswer(
              i.isEven ? LikertAnswer.agree : LikertAnswer.disagree,
            );
          }
          final record = EvaluationRecord.fromJson({
            ...quiz.buildCompletedRecord().toJson(),
            'createdAt': '2026-11-03T12:00:00.000Z',
          });
          await vm.recordCompletedEvaluation(record);
          final suffix = '${size.width.toInt()}-${dark ? 'dark' : 'light'}';
          await tester.pumpWidget(EspectroApp(appViewModel: vm));
          await tester.pumpAndSettle();
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/figma/espectro-mascot.png'),
              tester.element(find.byType(MaterialApp)),
            ),
          );
          // Os retratos do carrossel carregam em paralelo; sem pré-cache o
          // golden da home podia capturar a primeira dobra antes das imagens.
          for (final key in const <String>[
            'personality:karl_marx',
            'personality:friedrich_hayek',
            'personality:hannah_arendt',
            'personality:john_maynard_keynes',
            'personality:max_weber',
            'personality:murray_rothbard',
            'personality:rosa_luxemburgo',
            'personality:adam_smith',
            'personality:john_locke',
            'personality:mikhail_bakunin',
          ]) {
            final portrait = data.portraits[key];
            if (portrait != null) {
              await tester.runAsync(
                () => precacheImage(
                  AssetImage(portrait.assetPath),
                  tester.element(find.byType(MaterialApp)),
                ),
              );
            }
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/home-$suffix.png'),
          );
          // Confere as quatro áreas principais e o questionário com fontes reais.
          final screens = <String, Widget>{
            'modalidades': EspectroSuitesScreen(appViewModel: vm),
            'profundidade': EspectroIntroScreen(
              appViewModel: vm,
              suite: TestSuite.espectroIntegrated,
            ),
            'atlas': AtlasExplorerScreen(appViewModel: vm),
            'perfil': StudyProfileScreen(
              appViewModel: vm,
              subjectKey: 'current:liberalismo_classico',
            ),
            'marx': StudyProfileScreen(
              appViewModel: vm,
              subjectKey: 'personality:karl_marx',
            ),
            'rothbard': StudyProfileScreen(
              appViewModel: vm,
              subjectKey: 'personality:murray_rothbard',
            ),
            'comparacao': StudyComparisonScreen(
              appViewModel: vm,
              initialKeys: const [
                'current:liberalismo_classico',
                'current:social_democracia',
              ],
            ),
            'teia': MediaQuery(
              data: MediaQueryData(size: size, disableAnimations: true),
              child: AtlasExplorerScreen(
                appViewModel: vm,
                initialMap: true,
                initialQuery: 'liberalismo',
              ),
            ),
            'historico': HistoryEvolutionScreen(appViewModel: vm),
            'metodo': MethodologyScreen(data: data, appViewModel: vm),
            'resultado': EspectroResultScreen(appViewModel: vm, record: record),
            'quiz': EspectroQuizScreen(
              appViewModel: vm,
              quizViewModel: QuizViewModel.startNew(
                data: data,
                repository: repo,
                suite: TestSuite.espectroIntegrated,
                depth: TestDepth.quick,
                seed: 55,
              ),
            ),
          };
          for (final entry in screens.entries) {
            await tester.pumpWidget(
              MaterialApp(
                debugShowCheckedModeBanner: false,
                key: ValueKey(entry.key),
                theme: buildAppTheme(
                  brightness: dark ? Brightness.dark : Brightness.light,
                ),
                home: entry.value,
              ),
            );
            await tester.pumpAndSettle();
            if (entry.key == 'marx' || entry.key == 'rothbard') {
              final key = entry.key == 'marx'
                  ? 'personality:karl_marx'
                  : 'personality:murray_rothbard';
              final portrait = data.portraits[key];
              if (portrait != null) {
                await tester.runAsync(
                  () => precacheImage(
                    AssetImage(portrait.assetPath),
                    tester.element(find.byType(StudyProfileScreen)),
                  ),
                );
              }
              await tester.pumpAndSettle();
            }
            if (entry.key == 'atlas') {
              await tester.runAsync(
                () => precacheImage(
                  const AssetImage('assets/figma/atlas-circle.png'),
                  tester.element(find.byType(AtlasExplorerScreen)),
                ),
              );
              await tester.pumpAndSettle();
            }
            if (entry.key == 'teia') {
              final graphFinder = find.byType(StudyConstellation);
              await tester.ensureVisible(graphFinder);
              final graph = tester.widget<StudyConstellation>(graphFinder);
              graph.onSelected(
                graph.subjects.firstWhere(
                  (s) => s.key == 'current:liberalismo_classico',
                ),
              );
              await tester.pumpAndSettle();
            }
            if (entry.key == 'quiz') {
              expect(
                tester.getSize(find.byType(Scrollable).first).height,
                greaterThan(300),
              );
            }
            expect(tester.takeException(), isNull, reason: entry.key);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/${entry.key}-$suffix.png'),
            );
          }
        },
      );
    }
  }
  testWidgets('Jornada: início, modalidade, profundidade e respostas', (
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
    await vm.setAutoAdvance(false);
    await tester.pumpWidget(EspectroApp(appViewModel: vm));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fazer Avaliação Rápida (3 min)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('6 tríades políticas'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Continuar'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('Iniciar avaliação'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.textContaining('Iniciar avaliação'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Iniciar avaliação'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EspectroQuizScreen>(find.byType(EspectroQuizScreen))
          .quizViewModel
          .suite,
      TestSuite.triads,
    );
    await tester.scrollUntilVisible(
      find.text('Concordo totalmente'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Concordo totalmente'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Texto ampliado: início, modalidades e profundidade sem cortes', (
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
    for (final screen in <Widget>[
      EspectroSuitesScreen(appViewModel: vm),
      EspectroIntroScreen(
        appViewModel: vm,
        suite: TestSuite.espectroIntegrated,
      ),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          key: UniqueKey(),
          theme: buildAppTheme(),
          builder: (_, child) => MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2),
            ),
            child: child!,
          ),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -1500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
