import 'package:flutter/material.dart';

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

  static const EspectroPalette light = EspectroPalette(
    isDark: false,
    canvas: Color(0xFFF4F7F6),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFE8EEED),
    ink: Color(0xFF142630),
    inkSoft: Color(0xFF52616B),
    muted: Color(0xFF80919C),
    line: Color(0xFFDAE5E5),
    accent: Color(0xFF087B75),
    accentSoft: Color(0xFFD9F6F0),
    poleLeft: Color(0xFF087B75),
    poleRight: Color(0xFFA15704),
    warning: Color(0xFFB45309),
    success: Color(0xFF13795B),
    heroBackground: Color(0xFF0C1C27),
    heroForeground: Color(0xFFFFFFFF),
    heroMuted: Color(0xFFBCD2D2),
    triadPalette: <Color>[
      Color(0xFF087B75),
      Color(0xFFA15704),
      Color(0xFF776ABD),
      Color(0xFF177E5E),
      Color(0xFFA84266),
      Color(0xFF3A6EA5),
    ],
  );

  static const EspectroPalette dark = EspectroPalette(
    isDark: true,
    canvas: Color(0xFF0B141C),
    surface: Color(0xFF15313D),
    surfaceMuted: Color(0xFF1C3442),
    ink: Color(0xFFF4F7F6),
    inkSoft: Color(0xFFBCD2D2),
    muted: Color(0xFF80919C),
    line: Color(0xFF223E4F),
    accent: Color(0xFF6AE0CB),
    accentSoft: Color(0xFF163C38),
    poleLeft: Color(0xFF6AE0CB),
    poleRight: Color(0xFFEDA23B),
    warning: Color(0xFFF59E0B),
    success: Color(0xFF34D399),
    heroBackground: Color(0xFF15313D),
    heroForeground: Color(0xFFFFFFFF),
    heroMuted: Color(0xFF88A4A4),
    triadPalette: <Color>[
      Color(0xFF6AE0CB),
      Color(0xFFEDA23B),
      Color(0xFF9B95EC),
      Color(0xFF42C99E),
      Color(0xFFE6779E),
      Color(0xFF6DA6E4),
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
        onPrimary: isDark ? const Color(0xFF061318) : Colors.white,
        secondary: p.poleRight,
        onSecondary: isDark ? const Color(0xFF1A1002) : Colors.white,
        surface: p.surface,
        onSurface: p.ink,
        outline: p.line,
        outlineVariant: p.line,
      );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: p.canvas,
    splashFactory: InkSparkle.splashFactory,
    extensions: <ThemeExtension<dynamic>>[p],
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
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
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
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 11,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
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
