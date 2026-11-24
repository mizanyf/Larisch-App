import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/selected_period_provider.dart';
import '../theme/theme.dart';
import '../utils/date_formatter.dart';

/// Shared bottom sheet to pick a month across Beranda, Transaksi, and Laporan.
/// Uses root navigator and responsive height constraints so it never overflows.
void showMonthPickerSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime current,
) {
  final now = DateTime.now();
  final months = List.generate(12, (index) {
    return DateTime(now.year, now.month - index, 1);
  });

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: AppRadius.sheetTopBorder,
    ),
    builder: (sheetContext) {
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.65;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: AppResponsive.maxMobileContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Periode Bulan',
                  style: AppTypography.sectionHeading(),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: months.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final m = months[index];
                      final isSelected =
                          m.year == current.year && m.month == current.month;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          AppDateFormatter.monthYear(m),
                          style: AppTypography.bodyMedium(
                            color: isSelected
                                ? AppColors.accentBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.accentBlue,
                              )
                            : null,
                        onTap: () {
                          ref
                              .read(selectedMonthProvider.notifier)
                              .setMonth(m.year, m.month);
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
