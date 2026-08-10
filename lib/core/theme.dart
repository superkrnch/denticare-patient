import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0D9488);
  static const primaryDark = Color(0xFF0F766E);
  static const primaryLight = Color(0xFFCCFBF1);
  static const bg = Color(0xFFF8FAFC);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFD97706);

  // Modernized Dark palette
  static const darkBg = Color(0xFF0B132B);
  static const darkSurface = Color(0xFF1C2541);
  static const darkSurfaceElevated = Color(0xFF232ED1);
  static const darkText = Color(0xFFF1F5F9);
  static const darkMuted = Color(0xFF94A3B8);

  static const lightBorder = Color(0xFFE2E8F0);
  static const darkBorder = Color(0xFF334155);

  /// Border color for cards / tiles that adapts to the active theme.
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;

  /// Card / elevated surface color that adapts to the active theme.
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : Colors.white;

  /// Primary body text color that adapts to the active theme.
  static Color body(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : text;

  /// Secondary / muted text color that adapts to the active theme.
  static Color subtle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkMuted : muted;
}

ThemeData buildAppTheme() => _buildTheme(Brightness.light);

ThemeData buildAppDarkTheme() => _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final scaffoldBg = isDark ? AppColors.darkBg : AppColors.bg;
  final surface = isDark ? AppColors.darkSurface : Colors.white;
  final onSurface = isDark ? AppColors.darkText : AppColors.text;
  final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
  final fieldFill = isDark ? const Color(0xFF131B2E) : AppColors.bg;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
    primary: AppColors.primary,
    surface: surface,
    onSurface: onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBg,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBg,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: isDark ? 2 : 1,
      shadowColor: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    dividerTheme: DividerThemeData(color: border),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        side: BorderSide(color: isDark ? AppColors.primary : AppColors.primaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}