import 'package:flutter/material.dart';

import '../theme.dart';
import '../ui/ads/espectro_banner_ad.dart';
import 'common.dart';
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
          backgroundColor: p.canvas,
          appBar: appBar,
          body: ObservatoryGridBackdrop(
            child: Column(
              children: [
                Expanded(child: SizedBox.expand(child: body)),
                const EspectroFloatingAdBar(),
              ],
            ),
          ),
          bottomNavigationBar:
              bottomNavigationBar ??
              (wide || !navigationVisible
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.surface,
                        border: Border(
                          top: BorderSide(color: p.line.withValues(alpha: 0.8)),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: p.isDark ? 0.16 : 0.03,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          // Em tablets a barra não deve esticar os quatro itens
                          // pela largura inteira; mantém o ritmo do mobile.
                          child: Center(
                            heightFactor: 1,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: Row(
                                children: [
                                  for (var i = 0; i < 4; i++)
                                    Expanded(
                                      child: _MobileNavItem(
                                        icon: const [
                                          Icons.space_dashboard_outlined,
                                          Icons.fact_check_outlined,
                                          Icons.hub_outlined,
                                          Icons.history_rounded,
                                        ][i],
                                        selectedIcon: const [
                                          Icons.space_dashboard_rounded,
                                          Icons.fact_check_rounded,
                                          Icons.hub_rounded,
                                          Icons.history_rounded,
                                        ][i],
                                        label: const [
                                          "Início",
                                          "Testes",
                                          "Atlas",
                                          "Histórico",
                                        ][i],
                                        selected: selectedIndex == i,
                                        onTap: () => _open(context, i),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
        );
        if (!wide) return content;
        final Color sidebarBg = p.isDark
            ? const Color(0xFF070A10)
            : const Color(0xFFE9EEF5);
        final Color sidebarLine = p.isDark
            ? const Color(0xFF1D2638)
            : p.line;
        final int catalogCurrents = appViewModel.data.catalog.currents.length;

        return Material(
          child: Row(
            children: [
              Container(
                width: 228,
                decoration: BoxDecoration(
                  color: sidebarBg,
                  border: Border(right: BorderSide(color: sidebarLine)),
                ),
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
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  22,
                                  14,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          const EspectroBrandMark(size: 30),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'ESPECTRO',
                                                  style: TextStyle(
                                                    color: p.ink,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                                Text(
                                                  'Observatório político',
                                                  style: TextStyle(
                                                    color: p.muted,
                                                    fontSize: 10.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(height: 1, color: sidebarLine),
                                    const SizedBox(height: 18),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        'OBSERVATÓRIO',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          color: p.muted,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    for (final i in const [0, 1, 2, 4, 3])
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: _EspectroRailNavItem(
                                          icon: const [
                                            Icons.space_dashboard_outlined,
                                            Icons.fact_check_outlined,
                                            Icons.hub_outlined,
                                            Icons.history_rounded,
                                            Icons.compare_arrows_rounded,
                                            Icons.menu_book_outlined,
                                          ][i],
                                          selectedIcon: const [
                                            Icons.space_dashboard_rounded,
                                            Icons.fact_check_rounded,
                                            Icons.hub_rounded,
                                            Icons.history_rounded,
                                            Icons.compare_arrows_rounded,
                                            Icons.menu_book_rounded,
                                          ][i],
                                          label: const [
                                            'Visão geral',
                                            'Meus testes',
                                            'Atlas político',
                                            'Histórico',
                                            'Comparar',
                                            'Método aberto',
                                          ][i],
                                          selected: selectedIndex == i,
                                          onTap: () => _open(context, i),
                                        ),
                                      ),
                                    const SizedBox(height: 14),
                                    Divider(
                                      height: 1,
                                      color: sidebarLine.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(height: 14),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        'REFERÊNCIA',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          color: p.muted,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _EspectroRailNavItem(
                                      icon: Icons.menu_book_outlined,
                                      selectedIcon: Icons.menu_book_rounded,
                                      label: 'Método aberto',
                                      selected: selectedIndex == 5,
                                      onTap: () => _open(context, 5),
                                    ),
                                    const Spacer(),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: p.surface.withValues(
                                          alpha: p.isDark ? 0.55 : 0.78,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: sidebarLine),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.lock_outline_rounded,
                                                size: 13,
                                                color: p.success,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Privacidade local',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: p.ink,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$catalogCurrents correntes offline · Zero rastreio',
                                            style: TextStyle(
                                              fontFamily: 'IBMPlexMono',
                                              fontSize: 9.5,
                                              color: p.muted,
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            onTap: () =>
                                                appViewModel.setThemeMode(
                                                  p.isDark
                                                      ? ThemeMode.light
                                                      : ThemeMode.dark,
                                                ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 9,
                                                    vertical: 7,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: p.surfaceMuted
                                                    .withValues(alpha: 0.75),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: sidebarLine,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    p.isDark
                                                        ? Icons
                                                              .light_mode_rounded
                                                        : Icons
                                                              .dark_mode_rounded,
                                                    size: 14,
                                                    color: p.accent,
                                                  ),
                                                  const SizedBox(width: 7),
                                                  Expanded(
                                                    child: Text(
                                                      p.isDark
                                                          ? 'Modo claro'
                                                          : 'Modo escuro',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: p.inkSoft,
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.swap_horiz_rounded,
                                                    size: 14,
                                                    color: p.muted,
                                                  ),
                                                ],
                                              ),
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

class _MobileNavItem extends StatelessWidget {
  const _MobileNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      child: TactilePress(
        scale: 0.94,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: EspectroMotion.fast,
                  curve: EspectroMotion.easeOut,
                  width: 46,
                  height: 29,
                  decoration: BoxDecoration(
                    color: selected ? p.accentSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    selected ? selectedIcon : icon,
                    size: 20,
                    color: selected ? p.accent : p.inkSoft,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: "IBMPlexSans",
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? p.accent : p.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EspectroRailNavItem extends StatefulWidget {
  const _EspectroRailNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_EspectroRailNavItem> createState() => _EspectroRailNavItemState();
}

class _EspectroRailNavItemState extends State<_EspectroRailNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final bool active = widget.selected;
    final bool highlighted = _hovered || active;

    final Color bgColor = active
        ? (p.isDark ? const Color(0xFF15223B) : p.surface)
        : (_hovered
              ? p.ink.withValues(alpha: p.isDark ? 0.06 : 0.045)
              : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: TactilePress(
        scale: 0.975,
        child: AnimatedContainer(
          duration: EspectroMotion.fast,
          curve: EspectroMotion.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(
                    color: p.accent.withValues(alpha: p.isDark ? 0.42 : 0.28),
                    width: 1.0,
                  )
                : Border.all(color: Colors.transparent),
            boxShadow: active && !p.isDark
                ? <BoxShadow>[
                    BoxShadow(
                      color: p.ink.withValues(alpha: 0.045),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(10),
              hoverColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 9.5, 12, 9.5),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: EspectroMotion.fast,
                      width: 3,
                      height: active ? 16 : 0,
                      decoration: BoxDecoration(
                        color: active ? p.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Icon(
                      active ? widget.selectedIcon : widget.icon,
                      size: 18,
                      color: active
                          ? p.accent
                          : (_hovered ? p.ink : p.inkSoft),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: highlighted ? p.ink : p.inkSoft,
                          fontSize: 13.5,
                          fontWeight: active
                              ? FontWeight.w700
                              : (_hovered ? FontWeight.w600 : FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
