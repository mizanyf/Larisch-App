import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Floating dark pill navigation bar with separate primary blue FAB `+`.
/// Adapts cleanly to iOS Home Indicator, Android gesture nav, Android 3-button nav,
/// and compact/large/landscape viewports.
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  static const List<String> _labels = [
    'Beranda',
    'Transaksi',
    'Laporan',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    final compact = AppResponsive.isCompactWidth(context);
    final hPad = AppResponsive.horizontalPadding(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomMargin = math.max(12.0, bottomInset + 8.0);
    final barHeight = compact ? 54.0 : 58.0;
    final fabGap = compact ? AppSpacing.sm : AppSpacing.md;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomMargin),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppResponsive.maxBottomNavWidth,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: barHeight,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.darkBase,
                  borderRadius: AppRadius.pillBorder,
                  border: Border.all(color: AppColors.darkBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(_labels.length, (index) {
                    final isSelected = index == currentIndex;
                    return Expanded(
                      child: InkWell(
                        onTap: () => onTabSelected(index),
                        borderRadius: AppRadius.pillBorder,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkCardElevated
                                : Colors.transparent,
                            borderRadius: AppRadius.pillBorder,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _labels[index],
                              maxLines: 1,
                              style: AppTypography.captionMedium(
                                color: isSelected
                                    ? AppColors.textOnDark
                                    : AppColors.textOnDarkMuted,
                              ).copyWith(
                                fontSize: compact ? 11.5 : 12.0,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(width: fabGap),
            Material(
              color: AppColors.accentBlue,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: AppColors.accentBlue.withValues(alpha: 0.35),
              child: InkWell(
                onTap: onAddPressed,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: barHeight,
                  height: barHeight,
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.textOnDark,
                    size: compact ? 24 : 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
