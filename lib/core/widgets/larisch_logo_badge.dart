import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Official Larisch logo badge used in dark headers and profile cards.
class LarischLogoBadge extends StatelessWidget {
  const LarischLogoBadge({
    super.key,
    this.size = 32,
    this.borderRadius = AppRadius.sm,
    this.showBorder = true,
  });

  final double size;
  final double borderRadius;
  final bool showBorder;

  static const String assetPath = 'assets/logo/larisch.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.splashBlack,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(size * 0.12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
