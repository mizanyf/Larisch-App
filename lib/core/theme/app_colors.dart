import 'package:flutter/material.dart';

/// Color design tokens derived from Larisch Design System (FigCraft Page 1).
abstract final class AppColors {
  // Brand & Dark Surfaces
  static const Color splashBlack = Color(0xFF000000);
  static const Color darkBase = Color(0xFF0B0D10);
  static const Color darkCard = Color(0xFF161B22);
  static const Color darkCardElevated = Color(0xFF1E252E);
  static const Color darkBorder = Color(0xFF262D37);

  // Light Surfaces
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF6F7F9);
  static const Color borderLight = Color(0xFFEAECF0);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // Text on Light
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Text on Dark
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFF9CA3AF);
  static const Color textOnDarkSubtle = Color(0xFF6B7280);

  // Brand Accent & Semantic Status
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentBluePressed = Color(0xFF1D4ED8);
  static const Color accentBlueSurface = Color(0xFFEFF6FF);

  static const Color incomeGreen = Color(0xFF16A34A);
  static const Color incomeGreenLight = Color(0xFF22C55E);
  static const Color incomeSurface = Color(0xFFF0FDF4);

  static const Color expenseRed = Color(0xFFDC2626);
  static const Color expenseRedLight = Color(0xFFEF4444);
  static const Color dangerSurface = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  // Expense Category Chart Palette
  static const Color chartCategory1 = Color(0xFF2563EB);
  static const Color chartCategory2 = Color(0xFF16A34A);
  static const Color chartCategory3 = Color(0xFFF59E0B);
  static const Color chartCategory4 = Color(0xFF8B5CF6);
  static const Color chartCategory5 = Color(0xFF6B7280);
}
