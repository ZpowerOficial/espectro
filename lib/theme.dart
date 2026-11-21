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

/// Métricas espaciais compartilhadas por todas as telas principais para alinhar
/// `AppBar`, `TabBar`, cabeçalhos e cartões sobre a mesma coluna e cadência vertical.
abstract final class EspectroLayout {
  static const double workspaceMaxWidth = 1100.0;
  static const double workspaceInnerWidth = 1060.0;
  static const double proseMaxWidth = 860.0;
  static const double quizMaxWidth = 680.0;

  static const double pageHorizontalPadding = 20.0;
  static const double pageTopPadding = 24.0;
  static const double pageBottomPadding = 72.0;

  static const double sectionGap = 28.0;
  static const double blockGap = 20.0;
  static const double controlGap = 14.0;
  static const double headerToContentGap = 14.0;
  static const double cardGap = 14.0;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    pageHorizontalPadding,
    pageTopPadding,
    pageHorizontalPadding,
    pageBottomPadding,
  );
}

/// Elevação com camada dupla sutil (anel hairline + sombra ambiente colorida pela
/// tinta do tema, evitando sombras cinzentas lavadas ou pretos absolutos).
abstract final class EspectroElevation {
  static List<BoxShadow> cardShadows(
    EspectroPalette p, {
    Color? tint,
    bool elevated = true,
  }) {
    if (!elevated || p.isDark) return const <BoxShadow>[];
    return <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF141819).withValues(alpha: 0.045),
        blurRadius: 10,
        spreadRadius: -2,
        offset: const Offset(0, 3),
      ),
    ];
  }

  /// Decoração padrão de cartões: preserva [BoxDecoration.color] e aplica
  /// superfície de papel velino mineral (light) ou ardósia noturna (dark),
  /// sem halos coloridos nem reflexos artificiais.
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
        borderColor ?? p.line.withValues(alpha: 0.88);
    final Gradient? surfaceGradient =
        customGradient ??
        (color != null
            ? null
            : (p.isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFF151C28), Color(0xFF101620)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFFAF9F6), Color(0xFFF4F2ED)],
                    )));
    return BoxDecoration(
      color: color ?? p.surface,
      gradient: surfaceGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: resolvedBorder, width: borderWidth),
      boxShadow: cardShadows(p, elevated: elevated),
    );
  }

  /// Decoração editorial para o Troféu do Resultado.
  static BoxDecoration trophyDecoration(
    EspectroPalette p, {
    required Color accentColor,
    double radius = 20,
  }) {
    final Color topTint = Color.alphaBlend(
      accentColor.withValues(alpha: p.isDark ? 0.07 : 0.035),
      p.isDark ? const Color(0xFF151C28) : const Color(0xFFFAF9F6),
    );
    final Color bottomBase = p.isDark
        ? const Color(0xFF101620)
        : const Color(0xFFF2F0EB);
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
        color: accentColor.withValues(alpha: p.isDark ? 0.32 : 0.26),
        width: 1.1,
      ),
      boxShadow: cardShadows(p, elevated: true),
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
    Color(0xFF0E8E72),
    Color(0xFF155F70),
    Color(0xFF2B79B7),
  ];

  static const EspectroPalette light = EspectroPalette(
    isDark: false,
    // Papel velino editorial + Íris cartográfico sólido (#44378F)
    canvas: Color(0xFFF2F0EB),
    surface: Color(0xFFFAF9F6),
    surfaceMuted: Color(0xFFE6E3DC),
    ink: Color(0xFF151822),
    inkSoft: Color(0xFF3A4052),
    // AA inclusive sobre surfaceMuted (#E6E3DC).
    muted: Color(0xFF545A6E),
    line: Color(0xFFD4D1C9),
    // Íris cartográfico editorial (contraste >= 9.11:1 sobre surface)
    accent: Color(0xFF44378F),
    accentSoft: Color(0xFFEAE7F6),
    poleLeft: Color(0xFF155F70),
    poleRight: Color(0xFF9B4614),
    warning: Color(0xFF8F4305),
    success: Color(0xFF0E614E),
    heroBackground: Color(0xFF0F1320),
    heroForeground: Color(0xFFF5F6FA),
    heroMuted: Color(0xFFB3BBD0),
    triadPalette: <Color>[
      Color(0xFF0E5A4F),
      Color(0xFF9B4614),
      Color(0xFF1E5A8A),
      Color(0xFF8F3352),
      Color(0xFF5A6B1C),
      Color(0xFF7A5410),
    ],
  );

  static const EspectroPalette dark = EspectroPalette(
    isDark: true,
    // Ardósia noturna de observatório cartográfico + Íris luminoso + Latão nos CTAs
    canvas: Color(0xFF0B0F16),
    surface: Color(0xFF121822),
    surfaceMuted: Color(0xFF192130),
    ink: Color(0xFFF2F4F8),
    inkSoft: Color(0xFFBCC5D6),
    // AA sobre superfícies elevadas no tema escuro (>= 5.50:1).
    muted: Color(0xFF8C97AE),
    line: Color(0xFF232D3F),
    // Íris cartográfico escuro (#9A92F0, contraste >= 6.57:1 sobre surface)
    accent: Color(0xFF9A92F0),
    accentSoft: Color(0xFF1F1D3A),
    poleLeft: Color(0xFF4AC2BE),
    poleRight: Color(0xFFE5A448),
    warning: Color(0xFFF0A42E),
    success: Color(0xFF38CC9F),
    heroBackground: Color(0xFF0D111C),
    heroForeground: Color(0xFFFFFFFF),
    heroMuted: Color(0xFFA6B0C8),
    triadPalette: <Color>[
      Color(0xFF34C3A6),
      Color(0xFFE5A448),
      Color(0xFF5FA3DF),
      Color(0xFFDF6E8F),
      Color(0xFF9CBF4E),
      Color(0xFFD4B055),
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
        onPrimary: isDark ? const Color(0xFF0B0E1E) : const Color(0xFFFAF9F6),
        secondary: p.poleRight,
        onSecondary: isDark ? const Color(0xFF140D03) : const Color(0xFFFAF9F6),
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
        backgroundColor: isDark ? const Color(0xFFE5A448) : p.accent,
        foregroundColor: isDark
            ? const Color(0xFF140D03)
            : const Color(0xFFFAF9F6),
        elevation: 0,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(
              color: isDark ? p.heroForeground : p.ink,
              width: 2.0,
            );
          }
          return null;
        }),
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
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: p.accent, width: 2.0);
          }
          return BorderSide(color: p.line);
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.accent,
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: p.accent, width: 2.0);
          }
          return null;
        }),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.padded,
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: p.accent, width: 2.0);
          }
          return null;
        }),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      selectedColor: p.accentSoft,
      secondarySelectedColor: p.accentSoft,
      checkmarkColor: p.accent,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: p.accent, width: 2.0);
        }
        if (states.contains(WidgetState.selected)) {
          return BorderSide(color: p.accent, width: 1.5);
        }
        return BorderSide(color: p.line);
      }),
      labelStyle: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 13,
        color: p.ink,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: p.accent,
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
      reverseCurve: EspectroMotion.easeOut,
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
