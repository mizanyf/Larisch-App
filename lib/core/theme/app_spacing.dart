import 'package:flutter/widgets.dart';

/// 4px/8px spacing scale derived from Larisch Design System.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const double screenHorizontal = 20;
  static const double sectionGap = 20;
  static const double cardPadding = 16;
  static const double bottomNavClearance = 104;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
}
