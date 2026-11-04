import 'package:flutter/material.dart';

import 'theme.dart';
import 'domain/models/study_result_link.dart';
import 'ui/features/results/espectro_result_screen.dart';
import 'ui/features/atlas/atlas_explorer_screen.dart';
import 'ui/features/atlas/study_profile_screen.dart';
import 'ui/features/compare/study_comparison_screen.dart';
import 'ui/features/home/espectro_home_screen.dart';
import 'ui/view_models/app_view_model.dart';

class EspectroApp extends StatelessWidget {
  const EspectroApp({required this.appViewModel, super.key});

  final AppViewModel appViewModel;

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
          uri.toString().length > (uri.path == '/shared' ? 101000 : 4096) ||
          uri.queryParameters['v'] != '1') {
        return null;
      }
      Widget? screen;
      if (uri.path == '/shared') {
        final record = decodeStudyResult(uri.queryParameters['data'] ?? '');
        if (record != null) {
          screen = Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  MaterialBanner(
                    content: const Text(
                      'Resultado recebido por link. Conteúdo fornecido por quem compartilhou, sem verificação de autenticidade. Não foi salvo no seu histórico.',
                    ),
                    actions: [const SizedBox.shrink()],
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
        }
      } else if (uri.path == '/atlas') {
        final key = uri.queryParameters['subject'];
        screen = key == null
            ? AtlasExplorerScreen(
                appViewModel: appViewModel,
                initialQuery: uri.queryParameters['q'] ?? '',
                initialSpectrum: uri.queryParameters['spectrum'],
                initialMap: uri.queryParameters['view'] == 'map',
                initialType: uri.queryParameters['kind'],
              )
            : StudyProfileScreen(appViewModel: appViewModel, subjectKey: key);
      } else if (uri.path == '/compare') {
        screen = StudyComparisonScreen(
          appViewModel: appViewModel,
          initialKeys: !uri.queryParameters.containsKey('items')
              ? null
              : (uri.queryParameters['items'] ?? '')
                    .split(',')
                    .where((s) => s.isNotEmpty)
                    .toSet()
                    .take(3)
                    .toList(),
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
