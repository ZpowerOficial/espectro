import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// Estratégia cromática para exibição dos 12 eixos bipolares:
/// - [dualPole]: par cromático distinto para polo esquerdo e polo direito (24 cores).
/// - [primaryAnchor]: cor semântica única por eixo (12 cores), mantendo o polo
///   oposto em tom neutro com distinção espacial e simbólica.
enum AxisColorStrategy { dualPole, primaryAnchor }

/// Escopo opcional (não intrusivo, padrão [AxisColorStrategy.dualPole]) usado
/// em comparações A/B e visualização experimental dos 12 eixos.
class AxisColorStrategyScope extends InheritedWidget {
  const AxisColorStrategyScope({
    required this.strategy,
    required super.child,
    super.key,
  });

  final AxisColorStrategy strategy;

  static AxisColorStrategy of(BuildContext context) {
    final AxisColorStrategyScope? scope =
        context.dependOnInheritedWidgetOfExactType<AxisColorStrategyScope>();
    return scope?.strategy ?? AxisColorStrategy.dualPole;
  }

  @override
  bool updateShouldNotify(AxisColorStrategyScope oldWidget) =>
      strategy != oldWidget.strategy;
}

/// Identidade cromática e icônica unificada dos 12 eixos e 6 tríades,
/// espelhada do catálogo `twelve_axes.json`.
abstract final class AxisColors {
  static const Map<String, (Color, Color)> pairs = <String, (Color, Color)>{
    'estrutura': (Color(0xFF2F6DC0), Color(0xFFCF5A22)),
    'representacao': (Color(0xFF12907F), Color(0xFFB02556)),
    'poder': (Color(0xFF3C5A80), Color(0xFFAD7A06)),
    'imigracao': (Color(0xFFCC3456), Color(0xFF6A45C0)),
    'diplomacia': (Color(0xFF6A8425), Color(0xFF2D86C8)),
    'intervencao': (Color(0xFF3F8E5C), Color(0xFFB94A16)),
    'economia': (Color(0xFFD43A28), Color(0xFF8E6516)),
    'controle': (Color(0xFF8A3AA0), Color(0xFF1A8A56)),
    'comercio': (Color(0xFF9C5E2A), Color(0xFF0E86B0)),
    'religiao': (Color(0xFFC65E0E), Color(0xFF3B50B5)),
    'moral': (Color(0xFFD23E84), Color(0xFF74502C)),
    'tecnologia': (Color(0xFF5376B0), Color(0xFF4E9020)),
  };

  /// Uma cor-âncora única e distinta por eixo (12 tons no total).
  static const Map<String, Color> primaryAnchorColors = <String, Color>{
    'estrutura': Color(0xFF2F6DC0),
    'representacao': Color(0xFF12907F),
    'poder': Color(0xFFAD7A06),
    'imigracao': Color(0xFFCC3456),
    'diplomacia': Color(0xFF2D86C8),
    'intervencao': Color(0xFF3F8E5C),
    'economia': Color(0xFFD43A28),
    'controle': Color(0xFF8A3AA0),
    'comercio': Color(0xFF0E86B0),
    'religiao': Color(0xFF3B50B5),
    'moral': Color(0xFFD23E84),
    'tecnologia': Color(0xFF4E9020),
  };

  /// Ordem canônica (1..12) para indexação visual consistente em todo o app.
  static const Map<String, int> order = <String, int>{
    'estrutura': 1,
    'representacao': 2,
    'poder': 3,
    'imigracao': 4,
    'diplomacia': 5,
    'intervencao': 6,
    'economia': 7,
    'controle': 8,
    'comercio': 9,
    'religiao': 10,
    'moral': 11,
    'tecnologia': 12,
  };

  /// Marcadores icônicos distintos por eixo (nunca depender apenas de cor).
  static const Map<String, IconData> icons = <String, IconData>{
    'estrutura': Icons.account_balance_outlined,
    'representacao': Icons.how_to_vote_outlined,
    'poder': Icons.shield_outlined,
    'imigracao': Icons.public_outlined,
    'diplomacia': Icons.handshake_outlined,
    'intervencao': Icons.explore_outlined,
    'economia': Icons.storefront_outlined,
    'controle': Icons.tune_rounded,
    'comercio': Icons.swap_horiz_rounded,
    'religiao': Icons.auto_stories_outlined,
    'moral': Icons.balance_outlined,
    'tecnologia': Icons.biotech_outlined,
  };

  /// Marcadores icônicos distintos para as 6 tríades ternárias (`categoryId` 0..5).
  static const Map<int, IconData> triadIcons = <int, IconData>{
    0: Icons.change_history_rounded,
    1: Icons.hub_outlined,
    2: Icons.category_outlined,
    3: Icons.public_rounded,
    4: Icons.account_tree_outlined,
    5: Icons.explore_outlined,
  };

  static Color primaryFor(String axisId, EspectroPalette p) =>
      primaryAnchorColors[axisId] ?? pairs[axisId]?.$1 ?? p.accent;

  static (Color, Color) pairFor(String axisId, EspectroPalette p) =>
      pairs[axisId] ?? (p.poleLeft, p.poleRight);

  static Color dominantColor(
    String axisId, {
    required bool leansLeft,
    required EspectroPalette palette,
    AxisColorStrategy strategy = AxisColorStrategy.dualPole,
  }) {
    if (strategy == AxisColorStrategy.primaryAnchor) {
      return primaryFor(axisId, palette);
    }
    final (Color l, Color r) = pairFor(axisId, palette);
    return leansLeft ? l : r;
  }

  static IconData iconFor(String axisId) =>
      icons[axisId] ?? Icons.linear_scale_rounded;

  static IconData triadIconFor(int categoryId) =>
      triadIcons[categoryId] ?? Icons.change_history_rounded;

  static double contrastRatio(Color fg, Color bg) {
    final double l1 = fg.computeLuminance();
    final double l2 = bg.computeLuminance();
    return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
  }

  /// Ajusta apenas a luminosidade HSL da cor preservando seu matiz semântico
  /// original até atingir contraste WCAG 2.2 AA (`>= minContrast`) sobre [background].
  static Color readableInk(
    Color color, {
    required bool isDark,
    Color? background,
    double minContrast = 4.6,
  }) {
    final Color bg =
        background ??
        (isDark ? const Color(0xFF121822) : const Color(0xFFFAF9F6));
    if (contrastRatio(color, bg) >= minContrast) {
      return color;
    }
    HSLColor hsl = HSLColor.fromColor(color);
    if (isDark) {
      double l = math.max(hsl.lightness, 0.56);
      final double s = hsl.saturation.clamp(0.42, 0.86);
      while (l <= 0.94) {
        final Color cand = hsl.withLightness(l).withSaturation(s).toColor();
        if (contrastRatio(cand, bg) >= minContrast) return cand;
        l += 0.025;
      }
      return hsl.withLightness(0.88).toColor();
    } else {
      double l = math.min(hsl.lightness, 0.42);
      final double s = hsl.saturation.clamp(0.42, 0.88);
      while (l >= 0.12) {
        final Color cand = hsl.withLightness(l).withSaturation(s).toColor();
        if (contrastRatio(cand, bg) >= minContrast) return cand;
        l -= 0.025;
      }
      return hsl.withLightness(0.18).toColor();
    }
  }
}
