import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/seed_data.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/providers/selected_period_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/account_selector_chips.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/month_picker_sheet.dart';
import '../../core/widgets/transaction_list_tile.dart';

/// Screen 2 - Transaksi: Searchable, filterable, date-grouped transaction history.
class TransaksiScreen extends ConsumerStatefulWidget {
  const TransaksiScreen({super.key});

  @override
  ConsumerState<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends ConsumerState<TransaksiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'all'; // 'all' | 'income' | 'expense'
  String _selectedAccountId = 'all'; // 'all' | 'cash' | 'qris' | 'bank'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _accountLabel(String id) {
    switch (id) {
      case AccountIds.cash:
        return 'Tunai';
      case AccountIds.qris:
        return 'QRIS';
      case AccountIds.bank:
        return 'Rekening Bank';
      default:
        return 'Semua Akun';
    }
  }

  void _showAccountFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTopBorder,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter Akun Kas', style: AppTypography.sectionHeading()),
                const SizedBox(height: AppSpacing.md),
                AccountSelectorChips(
                  includeAllOption: true,
                  selectedAccountId: _selectedAccountId,
                  onSelected: (id) {
                    setState(() => _selectedAccountId = id);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final period = ref.watch(selectedMonthPeriodProvider);
    final txAsync = ref.watch(allTransactionsProvider);
    final catAsync = ref.watch(allCategoriesProvider);

    final allTransactions = txAsync.valueOrNull ?? const <Transaction>[];
    final categories = catAsync.valueOrNull ?? const <Category>[];
    final categoryMap = {for (final c in categories) c.id: c.name};

    final query = _searchQuery.trim().toLowerCase();
    final filtered = allTransactions.where((tx) {
      if (!period.contains(tx.transactionDate)) return false;
      if (_selectedType != 'all' && tx.type != _selectedType) return false;
      if (_selectedAccountId != 'all' && tx.accountId != _selectedAccountId) {
        return false;
      }
      if (query.isNotEmpty) {
        final note = (tx.note ?? '').toLowerCase();
        final catName = (categoryMap[tx.categoryId] ?? '').toLowerCase();
        final accName = _accountLabel(tx.accountId).toLowerCase();
        if (!note.contains(query) &&
            !catName.contains(query) &&
            !accName.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    var filteredIncome = 0;
    var filteredExpense = 0;
    for (final tx in filtered) {
      if (tx.type == TransactionTypes.income) {
        filteredIncome += tx.amount;
      } else {
        filteredExpense += tx.amount;
      }
    }

    // Group transactions by calendar day (preserving newest-first order).
    final grouped = <String, List<Transaction>>{};
    for (final tx in filtered) {
      final header = AppDateFormatter.sectionHeader(tx.transactionDate);
      grouped.putIfAbsent(header, () => <Transaction>[]).add(tx);
    }

    final hPad = AppResponsive.horizontalPadding(context);
    final bottomClearance = AppResponsive.bottomNavClearance(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        bottom: false,
        child: AppResponsive.constrain(
          Column(
            children: [
              // Header: Title + Account Filter + Month Switcher
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transaksi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.pageTitle(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      flex: 0,
                      child: _FilterChipButton(
                        label: _accountLabel(_selectedAccountId),
                        onTap: () => _showAccountFilterSheet(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      flex: 0,
                      child: _FilterChipButton(
                        label: AppDateFormatter.monthYear(selectedMonth),
                        onTap: () => showMonthPickerSheet(
                          context,
                          ref,
                          selectedMonth,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari transaksi, kategori, atau catatan...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Type Segmented Control: Semua | Pemasukan | Pengeluaran
            Padding(
              padding: AppSpacing.screenPadding,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppRadius.buttonBorder,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    _SegmentTab(
                      label: 'Semua',
                      isSelected: _selectedType == 'all',
                      onTap: () => setState(() => _selectedType = 'all'),
                    ),
                    _SegmentTab(
                      label: 'Pemasukan',
                      isSelected: _selectedType == TransactionTypes.income,
                      onTap: () => setState(
                        () => _selectedType = TransactionTypes.income,
                      ),
                    ),
                    _SegmentTab(
                      label: 'Pengeluaran',
                      isSelected: _selectedType == TransactionTypes.expense,
                      onTap: () => setState(
                        () => _selectedType = TransactionTypes.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Dark Cashflow Summary Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBase,
                  borderRadius: AppRadius.cardBorder,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemasukan',
                            style: AppTypography.labelSmall(
                              color: AppColors.textOnDarkMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatter.formatSigned(
                                filteredIncome,
                                isIncome: true,
                              ),
                              style: AppTypography.amountMedium(
                                color: AppColors.incomeGreenLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Pengeluaran',
                            style: AppTypography.labelSmall(
                              color: AppColors.textOnDarkMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              CurrencyFormatter.formatSigned(
                                filteredExpense,
                                isIncome: false,
                              ),
                              style: AppTypography.amountMedium(
                                color: const Color(0xFFFCA5A5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Grouped List or Empty State
            Expanded(
              child: filtered.isEmpty
                  ? SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: bottomClearance),
                      child: EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'Tidak Ada Transaksi',
                        description: _searchQuery.isNotEmpty
                            ? 'Tidak ditemukan transaksi untuk kata kunci "$_searchQuery".'
                            : 'Belum ada transaksi tercatat pada filter dan bulan ini.',
                        actionLabel: 'Catat Transaksi',
                        onAction: () => context.push(AppRoutes.catat),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        4,
                        hPad,
                        bottomClearance,
                      ),
                      itemCount: grouped.length,
                      itemBuilder: (context, sectionIndex) {
                        final entry = grouped.entries.elementAt(sectionIndex);
                        final dayTxs = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: AppTypography.captionMedium(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ...List.generate(dayTxs.length, (i) {
                                final tx = dayTxs[i];
                                final catName =
                                    categoryMap[tx.categoryId] ?? 'Transaksi';
                                final title =
                                    (tx.note != null && tx.note!.isNotEmpty)
                                    ? tx.note!
                                    : catName;
                                final subtitle =
                                    '$catName · ${_accountLabel(tx.accountId)} · ${AppDateFormatter.time24(tx.transactionDate)}';
                                return TransactionListTile(
                                  title: title,
                                  subtitle: subtitle,
                                  amount: tx.amount,
                                  isIncome: tx.type == TransactionTypes.income,
                                  showDivider: i < dayTxs.length - 1,
                                  onTap: () => context.push(
                                    '${AppRoutes.transaksi}/${tx.id}',
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadius.smBorder,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.captionMedium(color: AppColors.textPrimary),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smBorder,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceWhite : Colors.transparent,
            borderRadius: AppRadius.smBorder,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.captionMedium(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
