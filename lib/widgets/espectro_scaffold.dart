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

/// Estrutura editorial do Espectro: barra superior horizontal limpa no desktop
/// e barra inferior tátil no mobile, com transições rápidas sem recriar raízes.
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
    navigator.push(_SectionPageRoute<void>(builder: (_) => screen));
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
        final bool isDesktop = navigationVisible && constraints.maxWidth >= 1100;
        final Widget content = Scaffold(
          backgroundColor: p.canvas,
          appBar: appBar,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color.alphaBlend(
                    p.accent.withValues(alpha: p.isDark ? 0.055 : 0.025),
                    p.canvas,
                  ),
                  p.canvas,
                ],
                stops: const <double>[0.0, 0.35],
              ),
            ),
            child: Column(
              children: [
                Expanded(child: SizedBox.expand(child: body)),
                const EspectroFloatingAdBar(),
              ],
            ),
          ),
          bottomNavigationBar:
              bottomNavigationBar ??
              (isDesktop || !navigationVisible
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.surface,
                        border: Border(
                          top: BorderSide(color: p.line.withValues(alpha: 0.85)),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                                          'Início',
                                          'Testes',
                                          'Atlas',
                                          'Histórico',
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

        if (!isDesktop) return content;

        return Material(
          color: p.canvas,
          child: Column(
            children: [
              _EditorialDesktopHeader(
                appViewModel: appViewModel,
                selectedIndex: selectedIndex,
                onSelect: (idx) => _open(context, idx),
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

class _SectionPageRoute<T> extends MaterialPageRoute<T> {
  _SectionPageRoute({required super.builder});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 185);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 145);
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
                    fontFamily: 'IBMPlexSans',
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

class _EditorialDesktopHeader extends StatelessWidget {
  const _EditorialDesktopHeader({
    required this.appViewModel,
    required this.selectedIndex,
    required this.onSelect,
  });

  final AppViewModel appViewModel;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: p.isDark ? 0.94 : 0.96),
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.85)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => onSelect(0),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const EspectroBrandMark(size: 26),
                            const SizedBox(width: 10),
                            Text(
                              'ESPECTRO',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: p.ink,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              width: 1,
                              height: 14,
                              color: p.line,
                            ),
                            Text(
                              'Observatório Político',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: p.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _HeaderNavLink(
                              label: 'Início',
                              selected: selectedIndex == 0,
                              onTap: () => onSelect(0),
                            ),
                            _HeaderNavLink(
                              label: 'Meus testes',
                              selected: selectedIndex == 1,
                              onTap: () => onSelect(1),
                            ),
                            _HeaderNavLink(
                              label: 'Atlas político',
                              selected: selectedIndex == 2,
                              onTap: () => onSelect(2),
                            ),
                            _HeaderNavLink(
                              label: 'Comparar',
                              selected: selectedIndex == 4,
                              onTap: () => onSelect(4),
                            ),
                            _HeaderNavLink(
                              label: 'Histórico',
                              selected: selectedIndex == 3,
                              onTap: () => onSelect(3),
                            ),
                            _HeaderNavLink(
                              label: 'Método',
                              selected: selectedIndex == 5,
                              onTap: () => onSelect(5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(width: 1, height: 18, color: p.line),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: p.isDark ? 'Modo claro' : 'Modo escuro',
                      icon: Icon(
                        p.isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        size: 19,
                        color: p.inkSoft,
                      ),
                      onPressed: () => appViewModel.setThemeMode(
                        p.isDark ? ThemeMode.light : ThemeMode.dark,
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

class _HeaderNavLink extends StatefulWidget {
  const _HeaderNavLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_HeaderNavLink> createState() => _HeaderNavLinkState();
}

class _HeaderNavLinkState extends State<_HeaderNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(9),
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: EspectroMotion.fast,
          curve: EspectroMotion.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: widget.selected
                ? p.accentSoft
                : (_hovered
                      ? p.ink.withValues(alpha: p.isDark ? 0.06 : 0.04)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 13.5,
              fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
              color: widget.selected
                  ? p.accent
                  : (_hovered ? p.ink : p.inkSoft),
            ),
          ),
        ),
      ),
    );
  }
}
