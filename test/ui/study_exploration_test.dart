import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/app.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/domain/models/study_result_link.dart';
import 'package:politico/ui/features/results/espectro_result_screen.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';
import 'package:politico/ui/features/atlas/atlas_explorer_screen.dart';
import 'package:politico/ui/charts/study_constellation.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';
import 'package:politico/ui/features/compare/study_comparison_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late EvaluationRepository repository;
  late AppViewModel vm;
  setUpAll(() async => data = await AppData.load());
  setUp(() async {
    repository = EvaluationRepository(storage: LocalStorageService.inMemory());
    vm = AppViewModel(data: data, repository: repository);
    await vm.initialize();
  });

  Future<void> start(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(EspectroApp(appViewModel: vm));
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String route) async {
    tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
    await tester.pumpAndSettle();
  }

  Finder verticalScroll() => find
      .descendant(
        of: find
            .byWidgetPredicate((w) => w is CustomScrollView || w is ListView)
            .first,
        matching: find.byType(Scrollable),
      )
      .first;
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    for (
      var attempt = 0;
      attempt < 60 && finder.evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(verticalScroll(), const Offset(0, -250));
      await tester.pumpAndSettle();
    }
    expect(finder, findsWidgets);
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
  }

  Future<void> top(WidgetTester tester) async {
    await tester.drag(verticalScroll(), const Offset(0, 3000));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'busca global sem acentos encontra pessoas e obras e salvos sobrevivem à reabertura',
    (tester) async {
      await start(tester);
      await open(tester, '/atlas?v=1&q=platao');
      expect(find.byType(AtlasExplorerScreen), findsOneWidget);
      await reveal(tester, find.text('Platão'));
      expect(find.text('Platão'), findsWidgets);
      await reveal(tester, find.text('A República'));
      expect(find.text('A República'), findsOneWidget);
      final tile = find.byWidgetPredicate(
        (w) => w is StudySubjectTile && w.subject.key == 'personality:platao',
      );
      await tester.ensureVisible(tile);
      await tester.tap(
        find.descendant(of: tile, matching: find.byTooltip('Salvar verbete')),
      );
      await tester.pumpAndSettle();
      expect(vm.studyFavorites, contains('personality:platao'));
      final reloaded = AppViewModel(data: data, repository: repository);
      await reloaded.initialize();
      expect(reloaded.studyFavorites, contains('personality:platao'));
      vm = reloaded;
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(EspectroApp(appViewModel: vm));
      await tester.pumpAndSettle();
      await open(tester, '/atlas?v=1&q=platao');
      await tester.tap(find.widgetWithText(FilterChip, 'Salvos'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Platão'));
      expect(find.text('A República'), findsNothing);
      expect(vm.history, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'caminho colorido filtra apenas as correntes correspondentes e mantém retorno',
    (tester) async {
      await start(tester, width: 1440);
      await open(tester, '/atlas?v=1');
      await reveal(tester, find.text('Liberalismos'));
      await tester.tap(find.text('Liberalismos'));
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Ver todos os caminhos'));
      expect(
        find.text(
          'Direitos individuais, constitucionalismo e diferentes economias de mercado.',
        ),
        findsOneWidget,
      );
      await reveal(tester, find.text('Liberalismo Clássico'));
      final visible = tester.widgetList<StudySubjectTile>(
        find.byType(StudySubjectTile),
      );
      final spectrum = studySpectra.firstWhere((s) => s.name == 'Liberalismos');
      expect(visible, isNotEmpty);
      expect(
        visible.every((tile) => spectrumOf(tile.subject)?.id == spectrum.id),
        isTrue,
      );
      await top(tester);
      await reveal(tester, find.text('Ver todos os caminhos'));
      await tester.tap(find.text('Ver todos os caminhos'));
      await tester.pumpAndSettle();
      expect(find.text('Tradições e espectros'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'perfil reaberto por rota navega por dimensões, contexto e conexões',
    (tester) async {
      await start(tester);
      await open(tester, studyProfileRoute('current:liberalismo_classico'));
      expect(find.byType(StudyProfileScreen), findsOneWidget);
      expect(find.text('Liberalismo Clássico'), findsOneWidget);
      await tester.tap(find.byTooltip('Salvar verbete'));
      await tester.pumpAndSettle();
      expect(vm.studyFavorites, contains('current:liberalismo_classico'));
      await tester.tap(find.text('Dimensões'));
      await tester.pumpAndSettle();
      expect(find.text('Doze eixos.\nMais de uma leitura.'), findsOneWidget);
      final firstAxis = data.twelveAxes.axes.first;
      await reveal(tester, find.byTooltip('Entender ${firstAxis.label}'));
      await tester.tap(find.byTooltip('Entender ${firstAxis.label}'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'Dimensões ausentes não são substituídas pelo centro',
        ),
        findsOneWidget,
      );
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Conexões'));
      await tester.pumpAndSettle();
      expect(find.text('Uma ideia leva\na outra.'), findsOneWidget);
      await reveal(tester, find.text('Correntes próximas'));
      expect(find.byType(StudySubjectTile), findsWidgets);
      await tester.tap(find.text('Fontes e limites'));
      await tester.pumpAndSettle();
      expect(find.textContaining('O que sabemos.'), findsOneWidget);
      expect(vm.studyRecent, contains('current:liberalismo_classico'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compara dois perfis sem avaliação pessoal e expõe bases comuns',
    (tester) async {
      await start(tester);
      await open(tester, '/compare?v=1');
      expect(find.byType(StudyComparisonScreen), findsOneWidget);
      final search = find.widgetWithText(TextField, 'Adicionar um perfil');
      await reveal(tester, search);
      await tester.enterText(search, 'platao');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Platão'));
      await tester.pumpAndSettle();
      await tester.enterText(search, 'aristoteles');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Aristóteles'));
      await tester.pumpAndSettle();
      expect(vm.studyComparison, [
        'personality:platao',
        'personality:aristoteles',
      ]);
      expect(vm.history, isEmpty);
      await reveal(tester, find.text('Proximidade por par'));
      expect(find.text('Proximidade por par'), findsOneWidget);
      await reveal(tester, find.text('Platão × Aristóteles'));
      expect(find.textContaining('de sobreposição disponível'), findsOneWidget);
      await reveal(tester, find.text('Mesmos eixos, mesma régua'));
      expect(find.byType(StudyAxisRow), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  EvaluationRecord resultFixture() {
    final quiz = QuizViewModel.startNew(
      data: data,
      repository: repository,
      suite: TestSuite.bipolarAxes,
      depth: TestDepth.quick,
      seed: 55,
    );
    for (var i = 0; i < quiz.totalCount; i++) {
      quiz.jumpTo(i);
      quiz.selectAnswer(i.isEven ? LikertAnswer.agree : LikertAnswer.disagree);
    }
    return EvaluationRecord.fromJson({
      ...quiz.buildCompletedRecord().toJson(),
      'id': 'shared_regression_local',
      'title': 'Local preservado',
      'createdAt': '2026-11-03T12:00:00.000Z',
    });
  }

  testWidgets(
    'perfil fora da comparação cheia exige substituição e entra na seleção',
    (tester) async {
      for (final key in [
        'personality:platao',
        'personality:aristoteles',
        'personality:thomas_hobbes',
      ]) {
        await vm.toggleStudyComparison(key);
      }
      await start(tester);
      await open(tester, studyProfileRoute('personality:john_locke'));
      await reveal(tester, find.text('Comparar perfil'));
      await tester.tap(find.text('Comparar perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Substituir um perfil'), findsOneWidget);
      expect(vm.studyComparison, isNot(contains('personality:john_locke')));
      await tester.tap(find.widgetWithText(SimpleDialogOption, 'Platão'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyComparisonScreen), findsOneWidget);
      expect(vm.studyComparison, [
        'personality:aristoteles',
        'personality:thomas_hobbes',
        'personality:john_locke',
      ]);
      expect(find.widgetWithText(InputChip, 'John Locke'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Platão'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'resultado recebido com ID local é somente leitura e não altera histórico nem título',
    (tester) async {
      final local = resultFixture();
      await vm.recordCompletedEvaluation(local);
      final before = jsonEncode(
        (await repository.listRecords()).single.toJson(),
      );
      final incoming = local.copyWith(title: 'Recebido por link');
      final route = Uri(
        path: '/shared',
        queryParameters: {'v': '1', 'data': encodeStudyResult(incoming)},
      ).toString();
      await start(tester);
      await open(tester, route);
      expect(
        find.textContaining('Não foi salvo no seu histórico.'),
        findsOneWidget,
      );
      final screen = tester.widget<EspectroResultScreen>(
        find.byType(EspectroResultScreen),
      );
      expect(screen.readOnly, isTrue);
      expect(screen.record.id, local.id);
      expect(screen.record.title, 'Recebido por link');
      final title = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Recebido por link'),
      );
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(find.text('Nomear avaliação'), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(vm.history, hasLength(1));
      expect(vm.history.single.title, 'Local preservado');
      expect(
        jsonEncode((await repository.listRecords()).single.toJson()),
        before,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'rota de resultado compartilhado rejeita envelope, versão e payload incompatíveis',
    (tester) async {
      final local = resultFixture();
      String envelope(Map<String, Object?> value) =>
          base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
      final validToken = encodeStudyResult(local);
      final invalidSchema = {...local.toJson(), 'schemaVersion': 999};
      final invalidAxis = {
        ...local.toJson(),
        'axes': [
          for (final axis in local.axes) {...axis.toJson(), 'score': 9},
        ],
      };
      final routes = [
        Uri(path: '/shared', queryParameters: {'v': '99', 'data': validToken}),
        Uri(
          path: '/shared',
          queryParameters: {
            'v': '1',
            'data': envelope({'v': 2, 'record': local.toJson()}),
          },
        ),
        Uri(
          path: '/shared',
          queryParameters: {
            'v': '1',
            'data': envelope({'v': 1, 'record': invalidSchema}),
          },
        ),
        Uri(
          path: '/shared',
          queryParameters: {
            'v': '1',
            'data': envelope({'v': 1, 'record': invalidAxis}),
          },
        ),
        Uri(
          path: '/shared',
          queryParameters: {'v': '1', 'data': 'invalid-json-payload'},
        ),
      ];
      await start(tester);
      for (final route in routes) {
        await open(tester, route.toString());
        expect(find.text('Link indisponível'), findsOneWidget);
        expect(find.byType(EspectroResultScreen), findsNothing);
        expect(vm.history, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Voltar ao início'));
        await tester.pumpAndSettle();
      }
      expect(await repository.listRecords(), isEmpty);
    },
  );

  testWidgets('abertura inicial de links inválidos mostra erro recuperável', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    for (final route in [
      '/atlas?v=%FF',
      '/atlas?v=99',
      '/shared?v=1&data=inválido',
    ]) {
      tester.platformDispatcher.defaultRouteNameTestValue = route;
      await tester.pumpWidget(const SizedBox());
      await start(tester);
      expect(find.text('Link indisponível'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Voltar ao início'));
      await tester.pumpAndSettle();
      expect(find.text('ESPECTRO'), findsWidgets);
    }
  });

  testWidgets('links inválidos e perfis ausentes têm estados explícitos', (
    tester,
  ) async {
    await start(tester);
    for (final route in [
      '/atlas?v=%FF',
      '/atlas?v=1&q=%FF',
      '/compare?v=1&items=%C3',
    ]) {
      await open(tester, route);
      expect(find.text('Link indisponível'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Voltar ao início'));
      await tester.pumpAndSettle();
    }
    await open(tester, '/atlas?v=99');
    expect(find.text('Link indisponível'), findsOneWidget);
    await tester.tap(find.text('Voltar ao início'));
    await tester.pumpAndSettle();
    await open(tester, studyProfileRoute('current:nao_existe'));
    expect(find.text('Verbete indisponível'), findsOneWidget);
    expect(
      find.textContaining('não está no catálogo instalado'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('teia conserva busca e permite abrir um ponto selecionado', (
    tester,
  ) async {
    await start(tester);
    await open(tester, '/atlas?v=1&q=platao&view=map');
    final graphFinder = find.byType(StudyConstellation);
    await reveal(tester, graphFinder);
    final graph = tester.widget<StudyConstellation>(graphFinder);
    expect(
      graph.subjects.map((s) => s.key),
      containsAll(['personality:platao', 'book:a_republica_platao']),
    );
    final subject = graph.subjects.firstWhere(
      (s) => s.key == 'personality:platao',
    );
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    final painting = find.descendant(
      of: find.byType(InteractiveViewer),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.painter.runtimeType.toString() == '_ConstellationPainter',
      ),
    );
    final origin = tester.getTopLeft(painting);
    final position = StudyConstellationGeometry.position(subject)!;
    await tester.tapAt(
      origin +
          position * viewer.transformationController!.value.getMaxScaleOnAxis(),
    );
    await tester.pumpAndSettle();
    final selectedTile = find
        .byWidgetPredicate(
          (w) => w is StudySubjectTile && w.subject.key == 'personality:platao',
        )
        .first;
    await reveal(tester, selectedTile);
    await tester.tap(selectedTile);
    await tester.pumpAndSettle();
    expect(find.byType(StudyProfileScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cold startup reabre perfil pela rota inicial da plataforma', (
    tester,
  ) async {
    tester.platformDispatcher.defaultRouteNameTestValue = studyProfileRoute(
      'current:liberalismo_classico',
    );
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    await start(tester);
    expect(find.byType(StudyProfileScreen), findsOneWidget);
    expect(find.text('Liberalismo Clássico'), findsOneWidget);
    expect(vm.studyRecent, contains('current:liberalismo_classico'));
    await tester.ensureVisible(find.text('Fontes e limites'));
    await tester.tap(find.text('Fontes e limites'));
    await tester.pumpAndSettle();
    expect(find.textContaining('O que sabemos.'), findsOneWidget);
    expect(vm.history, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cold startup reabre comparação com os dois perfis do link', (
    tester,
  ) async {
    tester.platformDispatcher.defaultRouteNameTestValue =
        '/compare?v=1&items=personality:platao,personality:aristoteles';
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
    await start(tester);
    expect(find.byType(StudyComparisonScreen), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Platão'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'Aristóteles'), findsOneWidget);
    await reveal(tester, find.text('Platão × Aristóteles'));
    expect(find.textContaining('de sobreposição disponível'), findsOneWidget);
    expect(vm.history, isEmpty);
    expect(
      vm.studyComparison,
      isEmpty,
      reason: 'seleção do link não sobrescreve a comparação local',
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'Atlas, perfil e comparação permitem texto ampliado 2x em $width px',
      (tester) async {
        await start(tester, width: width, scale: 2);
        await open(tester, '/atlas?v=1&q=platao');
        await reveal(tester, find.text('Platão'));
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.byWidgetPredicate(
            (w) =>
                w is StudySubjectTile && w.subject.key == 'personality:platao',
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(StudyProfileScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        await open(
          tester,
          '/compare?v=1&items=personality:platao,personality:aristoteles',
        );
        await reveal(tester, find.text('Platão × Aristóteles'));
        expect(tester.takeException(), isNull);
        expect(vm.history, isEmpty);
      },
    );
  }
}
