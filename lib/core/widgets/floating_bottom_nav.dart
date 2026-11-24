import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Floating dark pill navigation bar with separate primary blue FAB `+`.
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
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 58,
              padding: const EdgeInsets.all(5),
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
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkCardElevated
                              : Colors.transparent,
                          borderRadius: AppRadius.pillBorder,
                        ),
                        child: Text(
                          _labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.captionMedium(
                            color: isSelected
                                ? AppColors.textOnDark
                                : AppColors.textOnDarkMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Material(
            color: AppColors.accentBlue,
            shape: const CircleBorder(),
            elevation: 4,
            shadowColor: AppColors.accentBlue.withValues(alpha: 0.35),
            child: InkWell(
              onTap: onAddPressed,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 58,
                height: 58,
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.textOnDark,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
