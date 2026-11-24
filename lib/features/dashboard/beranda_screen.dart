import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/seed_data.dart';
import '../../core/domain/finance_summary.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/providers/selected_period_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/larisch_logo_badge.dart';
import '../../core/widgets/month_picker_sheet.dart';
import '../../core/widgets/transaction_list_tile.dart';

/// Screen 1 - Beranda: Dark brand header (Total Saldo Kas + 3 manual accounts)
/// and clean white sheet (Laba Bersih periode, Quick Actions, Transaksi Terbaru).
class BerandaScreen extends ConsumerWidget {
  const BerandaScreen({super.key});

  String _accountLabel(String accountId) {
    switch (accountId) {
      case AccountIds.cash:
        return 'Tunai';
      case AccountIds.qris:
        return 'QRIS';
      case AccountIds.bank:
        return 'Rekening Bank';
      default:
        return accountId;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(businessProfileProvider);
    final cashAsync = ref.watch(cashBalanceSummaryProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final period = ref.watch(selectedMonthPeriodProvider);
    final profitAsync = ref.watch(periodProfitSummaryProvider(period));
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    final businessName =
        profileAsync.valueOrNull?.businessName ?? 'Usaha Saya';
    final cashSummary = cashAsync.valueOrNull;
    final profitSummary = profitAsync.valueOrNull;
    final allTransactions = transactionsAsync.valueOrNull ?? const <Transaction>[];
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    final categoryMap = {for (final c in categories) c.id: c.name};

    final recentTransactions = allTransactions.take(5).toList();
    final hPad = AppResponsive.horizontalPadding(context);
    final bottomClearance = AppResponsive.bottomNavClearance(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBase,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                  child: AppResponsive.constrain(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand + Period Selector Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const LarischLogoBadge(size: 32),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Larisch',
                                  style: AppTypography.pageTitle(
                                    color: AppColors.textOnDark,
                                  ).copyWith(fontSize: 18),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () => showMonthPickerSheet(
                                context,
                                ref,
                                selectedMonth,
                              ),
                              borderRadius: AppRadius.smBorder,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.darkCard,
                                  borderRadius: AppRadius.smBorder,
                                  border: Border.all(
                                    color: AppColors.darkBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppDateFormatter.monthYear(selectedMonth),
                                      style: AppTypography.captionMedium(
                                        color: AppColors.textOnDark,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textOnDarkMuted,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Business Name + Manual Balance Disclosure
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.sectionHeading(
                                  color: AppColors.textOnDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Saldo tercatat manual',
                              style: AppTypography.caption(
                                color: AppColors.textOnDarkSubtle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Total Saldo Kas Card (Strictly distinct from Laba Bersih)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: AppRadius.cardLargeBorder,
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Saldo Kas',
                                style: AppTypography.caption(
                                  color: AppColors.textOnDarkMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  CurrencyFormatter.format(
                                    cashSummary?.totalCashBalance ?? 0,
                                  ),
                                  style: AppTypography.displayBalance(
                                    color: AppColors.textOnDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const Divider(color: AppColors.darkBorder),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AccountBalanceColumn(
                                      label: 'Tunai',
                                      amount: cashSummary?.cashBalance ?? 0,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: _AccountBalanceColumn(
                                      label: 'QRIS',
                                      amount: cashSummary?.qrisBalance ?? 0,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: _AccountBalanceColumn(
                                      label: 'Rekening',
                                      amount: cashSummary?.bankBalance ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Clean White Content Sheet
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height * 0.62,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: AppRadius.sheetTopBorder,
                ),
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, bottomClearance),
                child: AppResponsive.constrain(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Laba Bersih (Periode) Card
                    _ProfitSummaryCard(
                      monthLabel: AppDateFormatter.monthYear(selectedMonth),
                      summary: profitSummary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Quick Actions: + Pemasukan | - Pengeluaran
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => context.push(
                              '${AppRoutes.catat}?type=${TransactionTypes.income}',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.darkBase,
                              foregroundColor: AppColors.textOnDark,
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: const Text('+ Pemasukan'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push(
                              '${AppRoutes.catat}?type=${TransactionTypes.expense}',
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: const Text('- Pengeluaran'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Transaksi Terbaru Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Transaksi Terbaru',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sectionHeading(),
                          ),
                        ),
                        if (allTransactions.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.transaksi),
                            child: Text(
                              'Lihat semua',
                              style: AppTypography.captionMedium(
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (recentTransactions.isEmpty)
                      EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum Ada Transaksi',
                        description:
                            'Catat pemasukan atau pengeluaran pertamamu untuk mulai memantau kas usaha.',
                        actionLabel: 'Catat Transaksi Pertama',
                        onAction: () => context.push(AppRoutes.catat),
                      )
                    else
                      Column(
                        children: List.generate(recentTransactions.length, (i) {
                          final tx = recentTransactions[i];
                          final catName =
                              categoryMap[tx.categoryId] ?? 'Transaksi';
                          final title =
                              (tx.note != null && tx.note!.isNotEmpty)
                              ? tx.note!
                              : catName;
                          final subtitle =
                              '${_accountLabel(tx.accountId)} · ${AppDateFormatter.relativeDateTime(tx.transactionDate)}';
                          return TransactionListTile(
                            title: title,
                            subtitle: subtitle,
                            amount: tx.amount,
                            isIncome: tx.type == TransactionTypes.income,
                            showDivider: i < recentTransactions.length - 1,
                            onTap: () => context.push(
                              '${AppRoutes.transaksi}/${tx.id}',
                            ),
                          );
                        }),
                      ),
                  ],
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

class _AccountBalanceColumn extends StatelessWidget {
  const _AccountBalanceColumn({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall(color: AppColors.textOnDarkMuted),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          CurrencyFormatter.format(amount),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.captionMedium(
            color: AppColors.textOnDark,
          ).copyWith(fontFeatures: AppTypography.tabularFeatures),
        ),
      ],
    );
  }
}

class _ProfitSummaryCard extends StatelessWidget {
  const _ProfitSummaryCard({required this.monthLabel, required this.summary});

  final String monthLabel;
  final PeriodProfitSummary? summary;

  @override
  Widget build(BuildContext context) {
    final netProfit = summary?.netProfit ?? 0;
    final totalIncome = summary?.totalIncome ?? 0;
    final totalExpense = summary?.totalExpense ?? 0;

    final netColor = netProfit > 0
        ? AppColors.incomeGreen
        : (netProfit < 0 ? AppColors.expenseRed : AppColors.textPrimary);

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Laba Bersih ($monthLabel)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionMedium(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                CurrencyFormatter.formatNetProfit(netProfit),
                style: AppTypography.amountMedium(color: netColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pemasukan', style: AppTypography.caption()),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      CurrencyFormatter.format(totalIncome),
                      style: AppTypography.amountMedium(),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.borderLight,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengeluaran', style: AppTypography.caption()),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      CurrencyFormatter.format(totalExpense),
                      style: AppTypography.amountMedium(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
