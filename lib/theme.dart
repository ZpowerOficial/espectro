import 'package:flutter/material.dart';

/// Tokens de movimento do Espectro inspirados em princípios táteis de interface:
/// saída rápida com desaceleração forte (`Cubic(0.23, 1, 0.32, 1)`), sempre
/// abaixo de 300ms e sem `ease-in` em entradas ou feedback de toque.
abstract final class EspectroMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 280);
  static const Curve easeOut = Cubic(0.23, 1, 0.32, 1);
}

/// Elevação com camada dupla sutil (anel hairline + sombra ambiente colorida pela
/// tinta do tema, evitando sombras cinzentas lavadas ou pretos absolutos).
abstract final class EspectroElevation {
  static List<BoxShadow> cardShadows(
    EspectroPalette p, {
    Color? tint,
    bool elevated = true,
  }) {
    if (!elevated) return const <BoxShadow>[];
    if (p.isDark) {
      final Color darkShadow = tint != null
          ? Color.alphaBlend(
              tint.withValues(alpha: 0.18),
              const Color(0xFF020506),
            )
          : const Color(0xFF020506);
      return <BoxShadow>[
        BoxShadow(
          color: darkShadow.withValues(alpha: 0.42),
          blurRadius: 14,
          spreadRadius: -2,
          offset: const Offset(0, 6),
        ),
      ];
    }
    final Color baseTint = tint ?? const Color(0xFF26231D);
    return <BoxShadow>[
      BoxShadow(
        color: baseTint.withValues(alpha: 0.055),
        blurRadius: 14,
        spreadRadius: -2,
        offset: const Offset(0, 5),
      ),
    ];
  }

  /// Decoração padrão de cartões: preserva [BoxDecoration.color] e aplica
  /// superfície de papel velino aquecido (light) ou ardósia aveludada (dark).
  static BoxDecoration cardDecoration(
    EspectroPalette p, {
    Color? color,
    Color? borderColor,
    Color? tint,
    double radius = 16,
    bool elevated = true,
    double borderWidth = 1,
    Gradient? customGradient,
  }) {
    final Color resolvedBorder =
        borderColor ??
        (p.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : p.line.withValues(alpha: 0.80));
    final Gradient? surfaceGradient =
        customGradient ??
        (color != null
            ? null
            : (p.isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFF141C22), Color(0xFF10171C)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFFDFCF9), Color(0xFFF9F6EF)],
                    )));
    return BoxDecoration(
      color: color ?? p.surface,
      gradient: surfaceGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: resolvedBorder, width: borderWidth),
      boxShadow: cardShadows(p, tint: tint, elevated: elevated),
    );
  }

  /// Decoração editorial para o Troféu do Resultado.
  static BoxDecoration trophyDecoration(
    EspectroPalette p, {
    required Color accentColor,
    double radius = 20,
  }) {
    final Color topTint = Color.alphaBlend(
      accentColor.withValues(alpha: p.isDark ? 0.09 : 0.045),
      p.isDark ? const Color(0xFF151E24) : const Color(0xFFFDFCF9),
    );
    final Color bottomBase = p.isDark
        ? const Color(0xFF10171C)
        : const Color(0xFFF7F3EA);
    return BoxDecoration(
      color: p.surface,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[topTint, p.surface, bottomBase],
        stops: const <double>[0.0, 0.55, 1.0],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: accentColor.withValues(alpha: p.isDark ? 0.30 : 0.24),
        width: 1.1,
      ),
      boxShadow: cardShadows(p, tint: accentColor, elevated: true),
    );
  }
}

/// Extensão de tema do Espectro com tokens semânticos próprios para modo claro e escuro.
///
/// Identidade visual própria: ardósia arquitetônica + petróleo mineral + âmbar ocre
/// (par amigável a daltônicos inspirado em Okabe–Ito), evitando tanto o bege/verde
/// do 12 Axes quanto o cinza/pastéis D3 do Six Triangles e estereótipos partidários.
@immutable
class EspectroPalette extends ThemeExtension<EspectroPalette> {
  const EspectroPalette({
    required this.isDark,
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.line,
    required this.accent,
    required this.accentSoft,
    required this.poleLeft,
    required this.poleRight,
    required this.warning,
    required this.success,
    required this.heroBackground,
    required this.heroForeground,
    required this.heroMuted,
    required this.triadPalette,
  });

  final bool isDark;
  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color line;
  final Color accent;
  final Color accentSoft;
  final Color poleLeft;
  final Color poleRight;
  final Color warning;
  final Color success;
  final Color heroBackground;
  final Color heroForeground;
  final Color heroMuted;
  final List<Color> triadPalette;

  static const List<Color> spectrumStops = <Color>[
    Color(0xFFD6373E),
    Color(0xFFDF7A1E),
    Color(0xFFD9A518),
    Color(0xFF0F9D6B),
    Color(0xFF2563EB),
    Color(0xFF7C4DFF),
  ];

  static const EspectroPalette light = EspectroPalette(
    isDark: false,
    // Papel linho / pergaminho editorial aquecido (zero branco hospitalar)
    canvas: Color(0xFFF4F0E6),
    surface: Color(0xFFFCFBF7),
    surfaceMuted: Color(0xFFEAE4D7),
    ink: Color(0xFF141917),
    inkSoft: Color(0xFF3D4642),
    // AA inclusive sobre surfaceMuted (#EAE4D7).
    muted: Color(0xFF56605B),
    line: Color(0xFFDAD2C3),
    // Verde-pinho profundo de imprensa e cartografia (adeus azul SaaS)
    accent: Color(0xFF0F3D30),
    accentSoft: Color(0xFFDDE9E3),
    poleLeft: Color(0xFF1E556E),
    poleRight: Color(0xFFB5481F),
    warning: Color(0xFFA84D08),
    success: Color(0xFF0E7453),
    heroBackground: Color(0xFF0D1512),
    heroForeground: Color(0xFFF6F8F6),
    heroMuted: Color(0xFFB4C2BC),
    triadPalette: <Color>[
      Color(0xFF0F3D30),
      Color(0xFFB5481F),
      Color(0xFF68589E),
      Color(0xFF0E7453),
      Color(0xFFA83B60),
      Color(0xFF285C78),
    ],
  );

  static const EspectroPalette dark = EspectroPalette(
    isDark: true,
    // Obsidiana botânica profunda e aveludada
    canvas: Color(0xFF0A0F12),
    surface: Color(0xFF12191E),
    surfaceMuted: Color(0xFF192329),
    ink: Color(0xFFF3F6F4),
    inkSoft: Color(0xFFB7C3BE),
    // AA sobre superfícies elevadas no tema escuro.
    muted: Color(0xFF85948E),
    line: Color(0xFF223038),
    // Jade luminoso editorial
    accent: Color(0xFF38B293),
    accentSoft: Color(0xFF132B24),
    poleLeft: Color(0xFF5698B8),
    poleRight: Color(0xFFF08A4B),
    warning: Color(0xFFF59E0B),
    success: Color(0xFF34D399),
    heroBackground: Color(0xFF0D1519),
    heroForeground: Color(0xFFFFFFFF),
    heroMuted: Color(0xFF9EB0AA),
    triadPalette: <Color>[
      Color(0xFF38B293),
      Color(0xFFF08A4B),
      Color(0xFFA79DF5),
      Color(0xFF42C99E),
      Color(0xFFE6779E),
      Color(0xFF5698B8),
    ],
  );

  Color triadColor(int index) => triadPalette[index % triadPalette.length];

  @override
  EspectroPalette copyWith({
    bool? isDark,
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? ink,
    Color? inkSoft,
    Color? muted,
    Color? line,
    Color? accent,
    Color? accentSoft,
    Color? poleLeft,
    Color? poleRight,
    Color? warning,
    Color? success,
    Color? heroBackground,
    Color? heroForeground,
    Color? heroMuted,
    List<Color>? triadPalette,
  }) {
    return EspectroPalette(
      isDark: isDark ?? this.isDark,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      poleLeft: poleLeft ?? this.poleLeft,
      poleRight: poleRight ?? this.poleRight,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      heroBackground: heroBackground ?? this.heroBackground,
      heroForeground: heroForeground ?? this.heroForeground,
      heroMuted: heroMuted ?? this.heroMuted,
      triadPalette: triadPalette ?? this.triadPalette,
    );
  }

  @override
  EspectroPalette lerp(ThemeExtension<EspectroPalette>? other, double t) {
    if (other is! EspectroPalette) return this;
    return EspectroPalette(
      isDark: t < 0.5 ? isDark : other.isDark,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      poleLeft: Color.lerp(poleLeft, other.poleLeft, t)!,
      poleRight: Color.lerp(poleRight, other.poleRight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      heroBackground: Color.lerp(heroBackground, other.heroBackground, t)!,
      heroForeground: Color.lerp(heroForeground, other.heroForeground, t)!,
      heroMuted: Color.lerp(heroMuted, other.heroMuted, t)!,
      triadPalette: <Color>[
        for (var i = 0; i < triadPalette.length; i++)
          Color.lerp(triadPalette[i], other.triadPalette[i], t)!,
      ],
    );
  }
}

extension EspectroThemeContext on BuildContext {
  EspectroPalette get palette =>
      Theme.of(this).extension<EspectroPalette>() ?? EspectroPalette.light;
}

/// Constantes legadas mantidas para compatibilidade com widgets/testes anteriores.
abstract final class AppColors {
  static const Color ink = Color(0xFF111822);
  static const Color inkSoft = Color(0xFF3B4758);
  static const Color paper = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEBEEF4);
  static const Color accent = Color(0xFF0E6C7B);
  static const Color muted = Color(0xFF69778B);
  static const Color line = Color(0xFFDCE2EC);
  static const Color dark = Color(0xFF131C28);
  static const Color darkSoft = Color(0xFF1E2A3B);
  static const Color pastelBlue = Color(0xFF3A6EA5);
}

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final bool isDark = brightness == Brightness.dark;
  final EspectroPalette p = isDark
      ? EspectroPalette.dark
      : EspectroPalette.light;
  final ThemeData base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'IBMPlexSans',
  );

  final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: p.accent,
        brightness: brightness,
      ).copyWith(
        primary: p.accent,
        onPrimary: isDark ? const Color(0xFF061510) : const Color(0xFFFAF8F3),
        secondary: p.poleRight,
        onSecondary: isDark ? const Color(0xFF1A1002) : Colors.white,
        surface: p.surface,
        onSurface: p.ink,
        outline: p.line,
        outlineVariant: p.line,
      );

  const PageTransitionsBuilder smoothTransition =
      _EspectroSmoothPageTransitionsBuilder();

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: p.canvas,
    splashFactory: InkSparkle.splashFactory,
    extensions: <ThemeExtension<dynamic>>[p],
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        for (final TargetPlatform platform in TargetPlatform.values)
          platform: smoothTransition,
      },
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: isDark
            ? const Color(0xFF061510)
            : const Color(0xFFFAF8F3),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.canvas,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: p.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: p.line),
      ),
    ),
    textTheme: base.textTheme.copyWith(
      displayLarge: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 38,
        height: 1.24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: p.ink,
      ),
      displayMedium: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 30,
        height: 1.24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: p.ink,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 24,
        height: 1.18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: p.ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 19,
        height: 1.28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: p.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: p.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 15.5,
        height: 1.5,
        color: p.inkSoft,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 14,
        height: 1.48,
        color: p.inkSoft,
      ),
      bodySmall: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 12.5,
        height: 1.4,
        color: p.muted,
      ),
      labelSmall: TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: p.muted,
      ),
      labelLarge: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: p.ink,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        side: BorderSide(color: p.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      hintStyle: TextStyle(fontSize: 13, color: p.inkSoft),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: p.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: p.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: p.accent, width: 1.6),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: p.line,
    ),
    scrollbarTheme: ScrollbarThemeData(
      radius: const Radius.circular(999),
      thickness: const WidgetStatePropertyAll<double>(5),
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged)) {
          return p.inkSoft.withValues(alpha: 0.45);
        }
        return p.muted.withValues(alpha: 0.24);
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: p.line),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 450),
      decoration: BoxDecoration(
        color: isDark ? p.surfaceMuted : p.ink,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: p.line.withValues(alpha: 0.35)),
      ),
      textStyle: TextStyle(
        color: isDark ? p.ink : p.surface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? p.surfaceMuted : p.ink,
      contentTextStyle: TextStyle(
        color: isDark ? p.ink : p.surface,
        fontSize: 13.5,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
  );
}

TextTheme darkTextTheme(TextTheme base) {
  return base
      .apply(bodyColor: AppColors.surface, displayColor: AppColors.surface)
      .copyWith(
        bodyLarge: base.bodyLarge?.copyWith(color: const Color(0xFFDCE3DD)),
        bodyMedium: base.bodyMedium?.copyWith(color: const Color(0xFFC3CCC6)),
        bodySmall: base.bodySmall?.copyWith(color: const Color(0xFF9AA69E)),
        labelSmall: base.labelSmall?.copyWith(color: const Color(0xFF9AA69E)),
        headlineSmall: base.headlineSmall?.copyWith(color: AppColors.surface),
        titleLarge: base.titleLarge?.copyWith(color: AppColors.surface),
      );
}

/// Transição de página ultraleve (GPU composited): elimina o `ZoomPageTransitionsBuilder`
/// padrão do Material 3 (que escala duas árvores simultâneas e engasga no Web/CanvasKit),
/// usando fade + micro-deslocamento horizontal com curva rápida e desencapsulando ao concluir.
class _EspectroSmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const _EspectroSmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/' ||
        animation.status == AnimationStatus.completed) {
      return child;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: EspectroMotion.easeOut,
      reverseCurve: Curves.easeInQuad,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.015, 0.0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
