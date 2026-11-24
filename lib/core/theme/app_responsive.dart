import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Zero-dependency responsive & safe-area layout helpers for iOS & Android.
abstract final class AppResponsive {
  static const double compactWidthBreakpoint = 360;
  static const double smallHeightBreakpoint = 700;
  static const double maxMobileContentWidth = 560;
  static const double maxBottomNavWidth = 520;

  static bool isCompactWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactWidthBreakpoint;

  static bool isSmallHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height < smallHeightBreakpoint;

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  static bool isKeyboardOpen(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom > 0;

  /// Horizontal screen margin adapted to compact vs standard/large phones.
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactWidthBreakpoint) return 16;
    if (width >= 430) return 22;
    return 20;
  }

  /// Dynamic bottom clearance for scrollable content above FloatingBottomNav,
  /// adapting to iOS Home Indicator, Android gesture bar, and Android 3-button nav.
  static double bottomNavClearance(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navHeight = isCompactWidth(context) ? 54.0 : 58.0;
    final navBottomMargin = math.max(12.0, bottomInset + 8.0);
    return navHeight + navBottomMargin + 20.0;
  }

  /// Constrains content to a comfortable reading width on landscape/large devices
  /// without forcing vertical expansion inside slivers or scroll views.
  static Widget constrain(
    Widget child, {
    double maxWidth = maxMobileContentWidth,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
