import 'package:flutter/material.dart';

import '../theme.dart';
import 'espectro_brand_mark.dart';
import '../ui/view_models/app_view_model.dart';
import '../ui/features/atlas/atlas_explorer_screen.dart';
import '../ui/features/history/history_evolution_screen.dart';
import '../ui/features/quiz/espectro_suites_screen.dart';
import '../ui/features/methodology/methodology_screen.dart';
import '../ui/features/compare/study_comparison_screen.dart';

/// Navegação mobile e desktop do handoff 14:15, preservando as rotas nativas.
class EspectroScaffold extends StatelessWidget {
  const EspectroScaffold({
    required this.appViewModel,
    required this.body,
    this.selectedIndex = 0,
    this.isSectionRoot = false,
    this.navigationVisible = true,
    this.appBar,
    this.bottomNavigationBar,
    super.key,
  });
  final AppViewModel appViewModel;
  final Widget body;
  final int selectedIndex;

  /// Raízes mantêm sua instância ao retornar de uma subpágina da mesma seção.
  final bool isSectionRoot;
  final bool navigationVisible;
  static final Expando<Map<int, Route<dynamic>>> _sectionRoots =
      Expando<Map<int, Route<dynamic>>>('Espectro section roots');

  static Map<int, Route<dynamic>> _rootsFor(NavigatorState navigator) {
    final roots = _sectionRoots[navigator] ??= <int, Route<dynamic>>{};
    roots.removeWhere((_, route) => !route.isActive);
    return roots;
  }

  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  void _open(BuildContext context, int index) {
    if (index == selectedIndex && isSectionRoot) return;
    final navigator = Navigator.of(context);
    if (index == 0) {
      navigator.popUntil((route) => route.isFirst);
      return;
    }
    final existing = _rootsFor(navigator)[index];
    if (existing != null && existing.navigator == navigator) {
      navigator.popUntil((route) => identical(route, existing));
      return;
    }
    final Widget screen = switch (index) {
      1 => EspectroSuitesScreen(appViewModel: appViewModel),
      2 => AtlasExplorerScreen(appViewModel: appViewModel),
      3 => HistoryEvolutionScreen(appViewModel: appViewModel),
      4 => StudyComparisonScreen(appViewModel: appViewModel),
      _ => MethodologyScreen(
        data: appViewModel.data,
        appViewModel: appViewModel,
      ),
    };
    navigator.push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    if (isSectionRoot) {
      final navigator = Navigator.maybeOf(context);
      final route = ModalRoute.of(context);
      if (navigator != null && route != null) {
        _rootsFor(navigator)[selectedIndex] = route;
      }
    }
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = navigationVisible && constraints.maxWidth >= 1100;
        final content = Scaffold(
          appBar: appBar,
          body: body,
          bottomNavigationBar:
              bottomNavigationBar ??
              (wide || !navigationVisible
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.surface,
                        border: Border(top: BorderSide(color: p.line)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              for (var i = 0; i < 4; i++)
                                Expanded(
                                  child: Semantics(
                                    selected: selectedIndex == i,
                                    child: InkWell(
                                      onTap: () => _open(context, i),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            const [
                                              Icons.circle,
                                              Icons.diamond_outlined,
                                              Icons.crop_square_rounded,
                                              Icons.history_rounded,
                                            ][i],
                                            size: 22,
                                            color: selectedIndex == i
                                                ? p.accent
                                                : p.muted,
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            const [
                                              "Início",
                                              "Testes",
                                              "Atlas",
                                              "Histórico",
                                            ][i],
                                            style: TextStyle(
                                              fontFamily: "IBMPlexSans",
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: selectedIndex == i
                                                  ? p.accent
                                                  : p.inkSoft,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )),
        );
        if (!wide) return content;
        return Material(
          child: Row(
            children: [
              Container(
                width: 244,
                color: const Color(0xFF0C1C27),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, sidebarConstraints) =>
                        SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: sidebarConstraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 17,
                                  vertical: 30,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const EspectroBrandMark(),
                                        const SizedBox(width: 10),
                                        const Expanded(
                                          child: Text(
                                            "ESPECTRO",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 44),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "NAVEGAÇÃO",
                                        style: TextStyle(
                                          fontFamily: "IBMPlexMono",
                                          color: Color(0xFF6AE0CB),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    for (final i in [0, 1, 2, 4, 3, 5])
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Material(
                                          color: selectedIndex == i
                                              ? const Color(0xFF17313D)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: InkWell(
                                            onTap: () => _open(context, i),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 14,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    const [
                                                      Icons.circle,
                                                      Icons.diamond_outlined,
                                                      Icons.crop_square_rounded,
                                                      Icons.history_rounded,
                                                      Icons
                                                          .compare_arrows_rounded,
                                                      Icons
                                                          .help_outline_rounded,
                                                    ][i],
                                                    size: 19,
                                                    color: selectedIndex == i
                                                        ? const Color(
                                                            0xFF6AE0CB,
                                                          )
                                                        : const Color(
                                                            0xFFB9CFD1,
                                                          ),
                                                  ),
                                                  const SizedBox(width: 22),
                                                  Expanded(
                                                    child: Text(
                                                      const [
                                                        "Visão geral",
                                                        "Meus testes",
                                                        "Atlas político",
                                                        "Histórico",
                                                        "Comparar",
                                                        "Método aberto",
                                                      ][i],
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFB9CFD1,
                                                        ),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "SUA INVESTIGAÇÃO\nÉ PRIVADA",
                                            style: TextStyle(
                                              fontFamily: "IBMPlexMono",
                                              fontSize: 12,
                                              color: Color(0xFF6AE0CB),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "Dados locais e exportação sob seu controle.",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF88A4A4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}
