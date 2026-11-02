import 'package:flutter/material.dart';

/// Paleta única do app: papel creme + verde profundo (12 Axes) com um bloco
/// escuro herdado do Six Triangles.
abstract final class AppColors {
  static const Color ink = Color(0xFF102E24);
  static const Color inkSoft = Color(0xFF345046);
  static const Color paper = Color(0xFFF2EEE1);
  static const Color surface = Color(0xFFFFFCF3);
  static const Color surfaceAlt = Color(0xFFEDE7D6);
  static const Color accent = Color(0xFFA8232B);
  static const Color muted = Color(0xFF6B7A70);
  static const Color line = Color(0xFFDED8C6);
  static const Color dark = Color(0xFF22262A);
  static const Color darkSoft = Color(0xFF2E3338);
  static const Color pastelBlue = Color(0xFF80B1D3);
}

ThemeData buildAppTheme() {
  final ThemeData base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppColors.ink,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.ink,
    onPrimary: AppColors.surface,
    secondary: AppColors.accent,
    onSecondary: AppColors.surface,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    outline: AppColors.line,
    outlineVariant: AppColors.line,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    splashFactory: InkSparkle.splashFactory,
    textTheme: base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontSize: 44,
        height: 1.02,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.8,
        color: AppColors.ink,
      ),
      displayMedium: const TextStyle(
        fontSize: 34,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppColors.ink,
      ),
      headlineLarge: const TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: AppColors.ink,
      ),
      headlineSmall: const TextStyle(
        fontSize: 21,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.ink,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.ink,
      ),
      titleMedium: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: AppColors.inkSoft,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: AppColors.inkSoft,
      ),
      bodySmall: const TextStyle(
        fontSize: 12.5,
        height: 1.4,
        color: AppColors.muted,
      ),
      labelSmall: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.7,
        color: AppColors.muted,
      ),
      labelLarge: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: AppColors.surface, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
  );
}

/// Texto de apoio com a mesma cor do papel, para cartões escuros.
TextTheme darkTextTheme(TextTheme base) {
  return base.apply(bodyColor: AppColors.surface, displayColor: AppColors.surface).copyWith(
        bodyLarge: base.bodyLarge?.copyWith(color: const Color(0xFFDCE3DD)),
        bodyMedium: base.bodyMedium?.copyWith(color: const Color(0xFFC3CCC6)),
        bodySmall: base.bodySmall?.copyWith(color: const Color(0xFF9AA69E)),
        labelSmall: base.labelSmall?.copyWith(color: const Color(0xFF9AA69E)),
        headlineSmall: base.headlineSmall?.copyWith(color: AppColors.surface),
        titleLarge: base.titleLarge?.copyWith(color: AppColors.surface),
      );
}
