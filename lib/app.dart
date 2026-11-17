import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'domain/models/political_models.dart';
import 'domain/models/study_result_link.dart';
import 'ui/analytics/espectro_analytics.dart';
import 'ui/features/quiz/espectro_quiz_screen.dart';
import 'ui/features/results/espectro_result_screen.dart';
import 'ui/features/atlas/atlas_explorer_screen.dart';
import 'ui/features/atlas/study_profile_screen.dart';
import 'ui/features/compare/compare_evaluations_screen.dart';
import 'ui/features/compare/study_comparison_screen.dart';
import 'ui/features/home/espectro_home_screen.dart';
import 'ui/view_models/app_view_model.dart';
import 'ui/view_models/quiz_view_model.dart';

/// Permite arrasto fluido em listas horizontais e carrosséis usando mouse,
/// trackpad, caneta ou toque em Web, Linux, Windows e Android.
class EspectroScrollBehavior extends MaterialScrollBehavior {
  const EspectroScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}

class EspectroApp extends StatelessWidget {
  const EspectroApp({required this.appViewModel, super.key});

  final AppViewModel appViewModel;

  static final RegExp _safeKeyRegExp = RegExp(r'^[a-zA-Z0-9_:-]{1,100}$');
  static final RegExp _controlCharsRegExp = RegExp(r'[\x00-\x1F\x7F<>]');

  static String? _sanitizeKey(String? raw) {
    if (raw == null || !_safeKeyRegExp.hasMatch(raw)) return null;
    return raw;
  }

  static String _sanitizeQuery(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final cleaned = raw.replaceAll(_controlCharsRegExp, '').trim();
    return cleaned.length > 100 ? cleaned.substring(0, 100) : cleaned;
  }

  Route<dynamic>? _studyRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => EspectroHomeScreen(appViewModel: appViewModel),
      );
    }
    try {
      final uri = Uri.tryParse(settings.name ?? '');
      if (uri == null ||
          uri.toString().length > (uri.path == '/shared' ? 101000 : 4096)) {
        return null;
      }
      final v = uri.queryParameters['v'];
      if (uri.path == '/shared') {
        if (v != '1' && v != '2') return null;
      } else if (v != null && v != '1') {
        return null;
      }
      Widget? screen;
      if (uri.path == '/shared') {
        final token =
            uri.queryParameters['c'] ?? uri.queryParameters['data'] ?? '';
        final record = decodeStudyResult(token);
        if (record != null) {
          screen = Builder(
            builder: (context) {
              final hasMyResult = appViewModel.history.isNotEmpty;
              final p = context.palette;
              return Scaffold(
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          border: Border(bottom: BorderSide(color: p.line)),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_alt_rounded,
                                    color: p.accent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      hasMyResult
                                          ? 'Resultado recebido por link. Não foi salvo no seu histórico. Compare com o seu perfil!'
                                          : 'Resultado recebido por link. Não foi salvo no seu histórico. Faça o teste para comparar!',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: p.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasMyResult)
                              FilledButton.icon(
                                icon: const Icon(
                                  Icons.compare_arrows_rounded,
                                  size: 16,
                                ),
                                label: const Text('Comparar com meu perfil'),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => CompareEvaluationsScreen(
                                        appViewModel: appViewModel,
                                        initialBaseline:
                                            appViewModel.history.first,
                                        initialTarget: record,
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              FilledButton.icon(
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 16,
                                ),
                                label: const Text('Fazer teste para comparar'),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => EspectroQuizScreen(
                                        appViewModel: appViewModel,
                                        quizViewModel: QuizViewModel.startNew(
                                          data: appViewModel.data,
                                          repository: appViewModel.repository,
                                          suite: TestSuite.espectroIntegrated,
                                          depth: TestDepth.standard,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: EspectroResultScreen(
                          appViewModel: appViewModel,
                          record: record,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      } else if (uri.path == '/atlas') {
        final rawKey = uri.queryParameters['subject'];
        final key = _sanitizeKey(rawKey);
        if (rawKey != null && key == null) return null;
        final tabParam = uri.queryParameters['tab'];
        final initialTab = tabParam == 'dimensoes'
            ? 1
            : (int.tryParse(tabParam ?? '') ?? 0);
        screen = key == null
            ? AtlasExplorerScreen(
                appViewModel: appViewModel,
                initialQuery: _sanitizeQuery(uri.queryParameters['q']),
                initialSpectrum: _sanitizeQuery(uri.queryParameters['spectrum']),
                initialMap: uri.queryParameters['view'] == 'map',
                initialType: _sanitizeQuery(uri.queryParameters['kind']),
                initialSelectedSubject: _sanitizeKey(
                  uri.queryParameters['select'],
                ),
              )
            : StudyProfileScreen(
                appViewModel: appViewModel,
                subjectKey: key,
                initialTab: initialTab,
              );
      } else if (uri.path == '/compare') {
        screen = StudyComparisonScreen(
          appViewModel: appViewModel,
          initialKeys: !uri.queryParameters.containsKey('items')
              ? null
              : (uri.queryParameters['items'] ?? '')
                    .split(',')
                    .map(_sanitizeKey)
                    .whereType<String>()
                    .toSet()
                    .take(3)
                    .toList(),
        );
      } else if (uri.path == '/quiz') {
        final suiteStr = uri.queryParameters['suite'];
        final depthStr = uri.queryParameters['depth'];
        final suite = TestSuite.values.firstWhere(
          (s) => s.name == suiteStr,
          orElse: () => TestSuite.espectroIntegrated,
        );
        final depth = TestDepth.values.firstWhere(
          (d) => d.name == depthStr,
          orElse: () => TestDepth.standard,
        );
        screen = EspectroQuizScreen(
          appViewModel: appViewModel,
          quizViewModel: QuizViewModel.startNew(
            data: appViewModel.data,
            repository: appViewModel.repository,
            suite: suite,
            depth: depth,
          ),
        );
      }
      return screen == null
          ? null
          : MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => screen!,
            );
    } on FormatException {
      return null;
    }
  }

  Route<dynamic> _unknownRoute(RouteSettings settings) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: (routeContext) => Scaffold(
          appBar: AppBar(title: const Text('Link indisponível')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Este link é inválido ou usa uma versão não suportada.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(routeContext).popUntil((r) => r.isFirst),
                    child: const Text('Voltar ao início'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appViewModel,
      builder: (BuildContext context, _) {
        return MaterialApp(
          title: 'Espectro',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const EspectroScrollBehavior(),
          theme: buildAppTheme(brightness: Brightness.light),
          darkTheme: buildAppTheme(brightness: Brightness.dark),
          themeMode: appViewModel.themeMode,
          builder: (context, child) => appViewModel.storageNotice == null
              ? child!
              : Material(
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            appViewModel.storageNotice!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      Expanded(child: child!),
                    ],
                  ),
                ),
          onGenerateRoute: _studyRoute,
          onUnknownRoute: _unknownRoute,
          navigatorObservers: <NavigatorObserver>[EspectroAnalyticsObserver()],
          onGenerateInitialRoutes: (name) {
            final home = MaterialPageRoute<void>(
              settings: const RouteSettings(name: '/'),
              builder: (_) => EspectroHomeScreen(appViewModel: appViewModel),
            );
            if (name == '/') return [home];
            final settings = RouteSettings(name: name);
            return [home, _studyRoute(settings) ?? _unknownRoute(settings)];
          },
        );
      },
    );
  }
}

/// Tela de contingência: os dados ficam embarcados no APK, então uma falha aqui
/// significa instalação corrompida — mostramos o motivo em vez de tela branca.
class EspectroErrorApp extends StatelessWidget {
  const EspectroErrorApp({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Espectro',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const EspectroScrollBehavior(),
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (BuildContext context) {
          final EspectroPalette p = context.palette;
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'ESPECTRO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.6,
                        color: p.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Não foi possível abrir os testes.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Os dados offline não puderam ser lidos. Reinstale o aplicativo.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    Text(message, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
