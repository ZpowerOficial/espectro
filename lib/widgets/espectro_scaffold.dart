import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';
import 'espectro_brand_mark.dart';
import '../ui/view_models/app_view_model.dart';
import '../ui/features/atlas/atlas_explorer_screen.dart';
import '../ui/features/history/history_evolution_screen.dart';
import '../ui/features/quiz/espectro_suites_screen.dart';
import '../ui/features/methodology/methodology_screen.dart';
import '../ui/features/compare/study_comparison_screen.dart';

/// Shell adaptativo multiplataforma do Espectro (Web, Android, Linux e Windows):
/// rail lateral de observatório no desktop e barra inferior tátil no mobile,
/// mantendo uma única barra contextual alinhada ao conteúdo sem cabeçalhos duplos.
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
    final EspectroPalette p = context.palette;
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 100;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop =
            navigationVisible && constraints.maxWidth >= 1100;
        final PreferredSizeWidget? alignedAppBar = appBar == null
            ? null
            : _WorkspaceConstrainedAppBar(
                appBar: appBar!,
                canvasColor: p.canvas,
                borderColor: p.line.withValues(alpha: p.isDark ? 0.55 : 0.65),
              );

        final Widget content = Scaffold(
          backgroundColor: p.canvas,
          appBar: alignedAppBar,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color.alphaBlend(
                    p.accent.withValues(alpha: p.isDark ? 0.05 : 0.03),
                    p.canvas,
                  ),
                  p.canvas,
                ],
                stops: const <double>[0.0, 0.36],
              ),
            ),
            child: SizedBox.expand(child: body),
          ),
          bottomNavigationBar:
              bottomNavigationBar ??
              (isDesktop || !navigationVisible || keyboardOpen
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.surface,
                        border: Border(
                          top: BorderSide(
                            color: p.line.withValues(alpha: 0.85),
                          ),
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
          child: Row(
            children: [
              _EspectroDesktopRail(
                appViewModel: appViewModel,
                selectedIndex: selectedIndex,
                onSelect: (int idx) => _open(context, idx),
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

/// Mantém a `AppBar` alinhada à mesma coluna máxima do conteúdo em monitores
/// largos (Linux, Windows e Web), evitando títulos e ações isolados nas bordas.
class _WorkspaceConstrainedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _WorkspaceConstrainedAppBar({
    required this.appBar,
    required this.canvasColor,
    required this.borderColor,
  });

  final PreferredSizeWidget appBar;
  final Color canvasColor;
  final Color borderColor;

  @override
  Size get preferredSize => appBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: canvasColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: EspectroLayout.workspaceMaxWidth,
          ),
          child: appBar,
        ),
      ),
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
    final bool ultraCompact = MediaQuery.sizeOf(context).width < 350;
    return Semantics(
      button: true,
      selected: selected,
      child: TactilePress(
        scale: 0.94,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ultraCompact ? 2 : 6,
                vertical: 2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedContainer(
                    duration: EspectroMotion.fast,
                    curve: EspectroMotion.easeOut,
                    width: ultraCompact ? 38 : 46,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: ultraCompact ? 10 : 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? p.accent : p.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rail lateral nativo para Desktop (Linux, Windows e Web): croma escuro de
/// observatório harmonizado com o mascote do Espectro, sem cortes horizontais.
class _EspectroDesktopRail extends StatelessWidget {
  const _EspectroDesktopRail({
    required this.appViewModel,
    required this.selectedIndex,
    required this.onSelect,
  });

  final AppViewModel appViewModel;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color railBg = p.isDark
        ? const Color(0xFF080C10)
        : const Color(0xFFE7E3D9);
    final Color railBorder = p.isDark ? const Color(0xFF1D2833) : p.line;
    final Color railInk = p.isDark ? p.ink : p.ink;
    final Color railMuted = p.isDark ? p.muted : p.inkSoft;
    final Color cardBg = p.isDark
        ? p.surface
        : p.surface.withValues(alpha: 0.78);
    final Color toggleBg = p.isDark
        ? p.surfaceMuted
        : p.surface;
    final int catalogCurrents = appViewModel.data.catalog.currents.length;

    return Container(
      width: 236,
      decoration: BoxDecoration(
        color: railBg,
        border: Border(right: BorderSide(color: railBorder)),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, railConstraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: railConstraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => onSelect(0),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              const EspectroBrandMark(size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ESPECTRO',
                                      style: TextStyle(
                                        color: railInk,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    Text(
                                      'Observatório político',
                                      style: TextStyle(
                                        color: railMuted,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: railBorder),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Observatório',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            color: railMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final int i in const <int>[0, 1, 2, 4, 3])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _RailNavItem(
                            icon: const <IconData>[
                              Icons.space_dashboard_outlined,
                              Icons.fact_check_outlined,
                              Icons.hub_outlined,
                              Icons.history_rounded,
                              Icons.compare_arrows_rounded,
                              Icons.menu_book_outlined,
                            ][i],
                            selectedIcon: const <IconData>[
                              Icons.space_dashboard_rounded,
                              Icons.fact_check_rounded,
                              Icons.hub_rounded,
                              Icons.history_rounded,
                              Icons.compare_arrows_rounded,
                              Icons.menu_book_rounded,
                            ][i],
                            label: const <String>[
                              'Visão geral',
                              'Meus testes',
                              'Atlas político',
                              'Histórico',
                              'Comparar',
                              'Método aberto',
                            ][i],
                            selected: selectedIndex == i,
                            onTap: () => onSelect(i),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        color: railBorder.withValues(alpha: 0.75),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Referência',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            color: railMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _RailNavItem(
                        icon: Icons.menu_book_outlined,
                        selectedIcon: Icons.menu_book_rounded,
                        label: 'Método aberto',
                        selected: selectedIndex == 5,
                        onTap: () => onSelect(5),
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: railBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 13,
                                  color: p.poleLeft,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Privacidade local',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: railInk,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$catalogCurrents correntes offline, sem rastreio',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 11.5,
                                color: railMuted,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => appViewModel.setThemeMode(
                                p.isDark ? ThemeMode.light : ThemeMode.dark,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: toggleBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: railBorder),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      p.isDark
                                          ? Icons.light_mode_rounded
                                          : Icons.dark_mode_rounded,
                                      size: 14,
                                      color: p.poleRight,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        p.isDark
                                            ? 'Tema claro'
                                            : 'Tema escuro',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: railInk,
                                        ),
                                      ),
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
    );
  }
}

class _RailNavItem extends StatefulWidget {
  const _RailNavItem({
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
  State<_RailNavItem> createState() => _RailNavItemState();
}

class _RailNavItemState extends State<_RailNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color activeBg = p.isDark ? p.surfaceMuted : p.surface;
    final Color activeBorder = p.line;
    final Color activeAccent = p.accent;
    final Color activeText = p.ink;
    final Color idleText = p.isDark ? p.inkSoft : p.inkSoft;
    final Color hoverBg = p.isDark
        ? Colors.white.withValues(alpha: 0.04)
        : p.surface.withValues(alpha: 0.65);

    return Semantics(
      button: true,
      selected: widget.selected,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: TactilePress(
          scale: 0.98,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: Colors.transparent,
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : EspectroMotion.fast,
              curve: EspectroMotion.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: widget.selected
                    ? activeBg
                    : (_hovered ? hoverBg : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.selected ? activeBorder : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  if (widget.selected) ...[
                    Container(
                      width: 2.5,
                      height: 16,
                      decoration: BoxDecoration(
                        color: activeAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    widget.selected ? widget.selectedIcon : widget.icon,
                    size: 18,
                    color: widget.selected
                        ? activeAccent
                        : (_hovered ? activeText : idleText),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 13.5,
                        fontWeight: widget.selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: widget.selected
                            ? activeText
                            : (_hovered ? activeText : idleText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
