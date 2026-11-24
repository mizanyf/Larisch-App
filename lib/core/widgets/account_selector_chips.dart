import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Manual cash account option displayed in transaction forms and filters.
class AccountOption {
  const AccountOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// Reusable horizontal selector for Larisch's 3 manual cash accounts.
class AccountSelectorChips extends StatelessWidget {
  const AccountSelectorChips({
    super.key,
    required this.selectedAccountId,
    required this.onSelected,
    this.includeAllOption = false,
  });

  final String selectedAccountId;
  final ValueChanged<String> onSelected;
  final bool includeAllOption;

  static const List<AccountOption> defaultAccounts = [
    AccountOption(id: 'cash', label: 'Tunai'),
    AccountOption(id: 'qris', label: 'QRIS'),
    AccountOption(id: 'bank', label: 'Rekening Bank'),
  ];

  @override
  Widget build(BuildContext context) {
    final options = [
      if (includeAllOption)
        const AccountOption(id: 'all', label: 'Semua Akun'),
      ...defaultAccounts,
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = option.id == selectedAccountId;
        return ChoiceChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onSelected(option.id),
          showCheckmark: false,
          selectedColor: AppColors.darkBase,
          backgroundColor: AppColors.surfaceMuted,
          labelStyle: AppTypography.captionMedium(
            color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.darkBase : AppColors.borderLight,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.smBorder,
          ),
        );
      }).toList(),
    );
  }
}
