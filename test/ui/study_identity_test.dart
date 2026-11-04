import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/study_media.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/features/atlas/study_identity.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  late StudyCatalog catalog;
  const identities = <(String, String, Color)>[
    ('personality:karl_marx', 'radical_left', Color(0xFFD6373E)),
    ('personality:robert_nozick', 'libertarian', Color(0xFFF2C534)),
    ('personality:pierre_joseph_proudhon', 'anarchist', Color(0xFF30343A)),
  ];
  setUpAll(() async {
    data = await AppData.load();
    catalog = StudyCatalog(data);
    for (final family in <String>['IBMPlexSans', 'IBMPlexMono']) {
      final FontLoader font = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'));
      await font.load();
    }
  });

  test('identidade editorial mantém Marx vermelho, Nozick amarelo e Proudhon carvão', () {
    for (final identity in identities) {
      final StudySubject subject = catalog.find(identity.$1)!;
      expect(spectrumOf(subject)?.id, identity.$2);
      expect(spectrumOf(subject)?.color, identity.$3);
    }
  });

  for (final Brightness brightness in Brightness.values) {
    for (final double width in <double>[390, 1000]) {
      testWidgets(
        'hero com retratos reais legível em $brightness, $width e fonte 2x',
        (tester) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final SemanticsHandle semantics = tester.ensureSemantics();
          try {
            for (final identity in identities) {
              final StudySubject subject = catalog.find(identity.$1)!;
              final portrait = data.portraits[subject.key];
              expect(portrait, isNotNull, reason: subject.key);
              await tester.pumpWidget(
                MaterialApp(
                  theme: buildAppTheme(brightness: brightness),
                  home: MediaQuery(
                    data: MediaQueryData(
                      size: Size(width, 1200),
                      textScaler: const TextScaler.linear(2),
                    ),
                    child: Scaffold(
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: StudyIdentityHero(
                            subject: subject,
                            portrait: portrait,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
              final BuildContext context = tester.element(
                find.byType(StudyIdentityHero),
              );
              await tester.runAsync(
                () => precacheImage(AssetImage(portrait!.assetPath), context),
              );
              await tester.pumpAndSettle();
              expect(
                find.bySemanticsLabel('Retrato de ${subject.name}'),
                findsOneWidget,
              );
              final RawImage image = tester.widget<RawImage>(
                find.byType(RawImage),
              );
              expect(image.image, isNotNull, reason: subject.key);
              expect(image.image!.width, greaterThan(0));
              final Rect title = tester.getRect(find.text(subject.name));
              expect(title.left, greaterThanOrEqualTo(18));
              expect(title.right, lessThanOrEqualTo(width - 18));
              final String spectrumName = spectrumOf(subject)!.name
                  .toUpperCase();
              final Text spectrumLabel = tester.widget<Text>(
                find.text(spectrumName),
              );
              expect(
                _contrast(spectrumLabel.style!.color!, identity.$3),
                greaterThanOrEqualTo(4.5),
                reason: spectrumName,
              );
              final Container hero = tester.widget<Container>(
                find
                    .descendant(
                      of: find.byType(StudyIdentityHero),
                      matching: find.byType(Container),
                    )
                    .first,
              );
              final Color background =
                  (hero.decoration! as BoxDecoration).color!;
              final Text kindLabel = tester.widget<Text>(
                find.text(subject.kindLabel),
              );
              expect(
                _contrast(kindLabel.style!.color!, background),
                greaterThanOrEqualTo(4.5),
                reason: '${subject.key} tipo de verbete',
              );
              final Text subtitle = tester.widget<Text>(
                find.text(subject.subtitle),
              );
              expect(
                _contrast(subtitle.style!.color!, background),
                greaterThanOrEqualTo(4.5),
                reason: subject.key,
              );
              expect(tester.takeException(), isNull);
            }
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }

  testWidgets(
    'avatar sem retrato apresenta iniciais e nome acessível sem imagem fictícia',
    (tester) async {
      final subject = catalog.find('personality:karl_marx')!;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.dark),
          home: Scaffold(body: StudyIdentityAvatar(subject: subject)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('KM'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(
        tester
            .widget<Semantics>(
              find
                  .descendant(
                    of: find.byType(StudyIdentityAvatar),
                    matching: find.byType(Semantics),
                  )
                  .first,
            )
            .properties
            .label,
        subject.name,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'perfil usa retrato real e exibe créditos como texto literal sem executar URLs',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const String key = 'personality:karl_marx';
      const String author =
          '<img src="x" onerror="alert(1)"> Autor & colaborador';
      final StudyPortrait original = data.portraits[key]!;
      final StudyPortrait literal = StudyPortrait(
        assetPath: original.assetPath,
        caption: original.caption,
        author: author,
        licenseName: original.licenseName,
        licenseUrl: original.licenseUrl,
        sourceUrl: original.sourceUrl,
        changes: original.changes,
        sha256: original.sha256,
        verifiedOn: original.verifiedOn,
      );
      final AppData customized = AppData(
        twelveAxes: data.twelveAxes,
        sixTriangles: data.sixTriangles,
        catalog: data.catalog,
        atlas: data.atlas,
        portraits: <String, StudyPortrait>{...data.portraits, key: literal},
      );
      final AppViewModel vm = AppViewModel(
        data: customized,
        repository: EvaluationRepository(
          storage: LocalStorageService.inMemory(),
        ),
      );
      await vm.initialize();
      addTearDown(vm.dispose);
      var externalLaunches = 0;
      const MethodChannel launcher = MethodChannel(
        'plugins.flutter.io/url_launcher',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcher, (call) async {
            externalLaunches++;
            return true;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(launcher, null),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: StudyProfileScreen(appViewModel: vm, subjectKey: key),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          AssetImage(literal.assetPath),
          tester.element(find.byType(StudyProfileScreen)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StudyIdentityHero), findsOneWidget);
      expect(
        tester.widget<RawImage>(find.byType(RawImage).first).image,
        isNotNull,
      );
      await tester.ensureVisible(find.text('Fontes e limites'));
      await tester.tap(find.text('Fontes e limites'));
      await tester.pumpAndSettle();
      final Finder vertical = find
          .byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Autoria: $author'),
        400,
        scrollable: vertical,
        maxScrolls: 60,
      );
      expect(find.text('Autoria: $author'), findsOneWidget);
      expect(find.text('Licença: ${literal.licenseName}'), findsOneWidget);
      expect(
        find.widgetWithText(SelectableText, literal.sourceUrl),
        findsOneWidget,
      );
      expect(externalLaunches, 0);
      expect(tester.takeException(), isNull);
    },
  );
}

double _contrast(Color foreground, Color background) {
  final double a = foreground.computeLuminance();
  final double b = background.computeLuminance();
  return a >= b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
}
