import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Main Material 3 theme configured with Larisch design tokens.
abstract final class AppTheme {
  static ThemeData get light {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surfaceWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentBlue,
        onPrimary: AppColors.textOnDark,
        secondary: AppColors.darkBase,
        onSecondary: AppColors.textOnDark,
        surface: AppColors.surfaceWhite,
        onSurface: AppColors.textPrimary,
        error: AppColors.expenseRed,
        onError: AppColors.textOnDark,
        outline: AppColors.borderLight,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: AppTypography.headlineLarge(),
        titleLarge: AppTypography.pageTitle(),
        titleMedium: AppTypography.sectionHeading(),
        bodyLarge: AppTypography.bodyMedium(),
        bodyMedium: AppTypography.bodyRegular(),
        bodySmall: AppTypography.caption(),
        labelSmall: AppTypography.labelSmall(),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: AppColors.textOnDark,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.bodyMedium(color: AppColors.textOnDark),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.borderLight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTypography.bodyMedium(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodyRegular(color: AppColors.textTertiary),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide(color: AppColors.accentBlue, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide(color: AppColors.expenseRed),
        ),
      ),
    );
  }
}
