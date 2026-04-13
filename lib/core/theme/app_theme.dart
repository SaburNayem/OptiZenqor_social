import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    final colorScheme = _lightScheme(baseScheme);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
        titleTextStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.08)),
        ),
      ),
      dividerColor: colorScheme.primary.withValues(alpha: 0.08),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.primary.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.08),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.08),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: TextStyle(
          color: colorScheme.primary.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.24)),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
        selectedColor: colorScheme.primary.withValues(alpha: 0.14),
        secondarySelectedColor: colorScheme.primary.withValues(alpha: 0.14),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.08)),
        labelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.primary.withValues(alpha: 0.55),
        indicatorColor: colorScheme.primary,
        dividerColor: colorScheme.primary.withValues(alpha: 0.08),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      iconTheme: IconThemeData(color: colorScheme.primary),
      textTheme: base.textTheme.apply(
        bodyColor: colorScheme.primary,
        displayColor: colorScheme.primary,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        textColor: colorScheme.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
    final colorScheme = _darkScheme(baseScheme);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.12)),
        ),
      ),
      dividerColor: colorScheme.primary.withValues(alpha: 0.12),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        secondarySelectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ColorScheme _lightScheme(ColorScheme base) {
    return base.copyWith(
      primary: AppColors.primary700,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary900,
      secondary: AppColors.primary600,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.primary100,
      onSecondaryContainer: AppColors.primary900,
      tertiary: AppColors.primary500,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.primary50,
      onTertiaryContainer: AppColors.primary900,
      surface: AppColors.primary50,
      onSurface: AppColors.primary900,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.primary50,
      surfaceContainer: AppColors.primary100,
      surfaceContainerHigh: AppColors.primary100,
      surfaceContainerHighest: AppColors.primary200,
      onSurfaceVariant: AppColors.primary800,
      outline: AppColors.primary200,
      outlineVariant: AppColors.primary100,
      shadow: AppColors.primary900.withValues(alpha: 0.08),
      scrim: AppColors.primary900.withValues(alpha: 0.14),
    );
  }

  static ColorScheme _darkScheme(ColorScheme base) {
    return base.copyWith(
      primary: AppColors.primary200,
      onPrimary: AppColors.primary900,
      primaryContainer: AppColors.primary800,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.primary200,
      onSecondary: AppColors.primary900,
      secondaryContainer: AppColors.primary800,
      onSecondaryContainer: AppColors.white,
      tertiary: AppColors.primary500,
      onTertiary: AppColors.primary900,
      tertiaryContainer: AppColors.primary800,
      onTertiaryContainer: AppColors.white,
      surface: AppColors.darkBackground,
      onSurface: AppColors.white,
      surfaceContainerLowest: AppColors.hexFF0B2926,
      surfaceContainerLow: AppColors.hexFF0C312E,
      surfaceContainer: AppColors.hexFF11403C,
      surfaceContainerHigh: AppColors.hexFF14504A,
      surfaceContainerHighest: AppColors.hexFF1A625A,
      onSurfaceVariant: AppColors.primary100,
      outline: AppColors.primary600,
      outlineVariant: AppColors.primary800,
      shadow: AppColors.black.withValues(alpha: 0.24),
      scrim: AppColors.black.withValues(alpha: 0.32),
    );
  }
}



