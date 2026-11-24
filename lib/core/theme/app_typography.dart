import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens using bundled offline Inter static weights (400/500/600/700)
/// with tabular figures for financial amounts, matching FigCraft Design System.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  static const List<FontFeature> tabularFeatures = [
    FontFeature.tabularFigures(),
  ];

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    Color? color,
    bool tabular = false,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height / fontSize,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: tabular ? tabularFeatures : null,
    );
  }

  static TextStyle displayBalance({Color color = AppColors.textOnDark}) =>
      _inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 38,
        letterSpacing: -0.8,
        color: color,
        tabular: true,
      );

  static TextStyle headlineLarge({Color color = AppColors.textPrimary}) =>
      _inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle pageTitle({Color color = AppColors.textPrimary}) => _inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 26,
    letterSpacing: -0.3,
    color: color,
  );

  static TextStyle sectionHeading({Color color = AppColors.textPrimary}) =>
      _inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 22,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle cardMetric({Color color = AppColors.textPrimary}) => _inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24,
    letterSpacing: -0.2,
    color: color,
    tabular: true,
  );

  static TextStyle listTitle({Color color = AppColors.textPrimary}) => _inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 20,
    letterSpacing: -0.1,
    color: color,
  );

  static TextStyle amountMedium({Color color = AppColors.textPrimary}) =>
      _inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20,
        letterSpacing: -0.1,
        color: color,
        tabular: true,
      );

  static TextStyle bodyMedium({Color color = AppColors.textPrimary}) => _inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20,
    color: color,
  );

  static TextStyle bodyRegular({Color color = AppColors.textSecondary}) =>
      _inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20,
        color: color,
      );

  static TextStyle caption({Color color = AppColors.textSecondary}) => _inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16,
    color: color,
  );

  static TextStyle captionMedium({Color color = AppColors.textSecondary}) =>
      _inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16,
        color: color,
      );

  static TextStyle labelSmall({Color color = AppColors.textSecondary}) =>
      _inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14,
        letterSpacing: 0.2,
        color: color,
      );
}
