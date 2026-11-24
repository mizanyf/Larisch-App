import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/currency_formatter.dart';

/// Reusable row for displaying a single income or expense transaction.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final int amount;
  final bool isIncome;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium(),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  CurrencyFormatter.formatSigned(amount, isIncome: isIncome),
                  style: AppTypography.amountMedium(
                    color: isIncome
                        ? AppColors.incomeGreen
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }
}
