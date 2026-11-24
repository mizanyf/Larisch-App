import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
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
import '../../core/widgets/month_picker_sheet.dart';

enum ReportRangeMode { daily, weekly, monthly }

/// Screen 4 - Laporan Keuangan: Harian/Mingguan/Bulanan, Laba Bersih & Margin,
/// interactive fl_chart trend, and Expense Breakdown per Category.
class LaporanScreen extends ConsumerStatefulWidget {
  const LaporanScreen({super.key});

  @override
  ConsumerState<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends ConsumerState<LaporanScreen> {
  ReportRangeMode _rangeMode = ReportRangeMode.monthly;

  DatePeriod _activePeriod(DateTime selectedMonth) {
    final now = DateTime.now();
    switch (_rangeMode) {
      case ReportRangeMode.daily:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DatePeriod(start: start, end: end);
      case ReportRangeMode.weekly:
        final startOfToday = DateTime(now.year, now.month, now.day);
        final start = startOfToday.subtract(const Duration(days: 6));
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DatePeriod(start: start, end: end);
      case ReportRangeMode.monthly:
        return DatePeriod.month(selectedMonth.year, selectedMonth.month);
    }
  }

  String _periodSubtitle(DateTime selectedMonth) {
    switch (_rangeMode) {
      case ReportRangeMode.daily:
        return 'Hari ini (${AppDateFormatter.shortDate(DateTime.now())})';
      case ReportRangeMode.weekly:
        return '7 Hari Terakhir';
      case ReportRangeMode.monthly:
        return AppDateFormatter.monthYear(selectedMonth);
    }
  }

  static const List<Color> _categoryColors = [
    AppColors.chartCategory1,
    AppColors.chartCategory2,
    AppColors.chartCategory3,
    AppColors.chartCategory4,
    AppColors.chartCategory5,
  ];

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final period = _activePeriod(selectedMonth);
    final profitAsync = ref.watch(periodProfitSummaryProvider(period));
    final allTxAsync = ref.watch(allTransactionsProvider);

    final summary = profitAsync.valueOrNull;
    final allTx = allTxAsync.valueOrNull ?? const <Transaction>[];
    final periodTx = allTx
        .where((tx) => period.contains(tx.transactionDate))
        .toList();

    final netProfit = summary?.netProfit ?? 0;
    final margin = summary?.marginPercent ?? 0.0;
    final totalIncome = summary?.totalIncome ?? 0;
    final totalExpense = summary?.totalExpense ?? 0;
    final breakdown = summary?.expenseByCategory ?? const <CategoryExpenseSummary>[];

    final isProfit = netProfit >= 0;

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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Laporan Keuangan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.pageTitle(
                                color: AppColors.textOnDark,
                              ),
                            ),
                          ),
                          if (_rangeMode == ReportRangeMode.monthly) ...[
                            const SizedBox(width: AppSpacing.sm),
                            InkWell(
                              onTap: () => showMonthPickerSheet(
                                context,
                                ref,
                                selectedMonth,
                              ),
                              borderRadius: AppRadius.smBorder,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
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
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Segmented Period Selector: Harian | Mingguan | Bulanan
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: AppRadius.buttonBorder,
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Row(
                          children: [
                            _PeriodTab(
                              label: 'Harian',
                              isSelected: _rangeMode == ReportRangeMode.daily,
                              onTap: () => setState(
                                () => _rangeMode = ReportRangeMode.daily,
                              ),
                            ),
                            _PeriodTab(
                              label: 'Mingguan',
                              isSelected: _rangeMode == ReportRangeMode.weekly,
                              onTap: () => setState(
                                () => _rangeMode = ReportRangeMode.weekly,
                              ),
                            ),
                            _PeriodTab(
                              label: 'Bulanan',
                              isSelected: _rangeMode == ReportRangeMode.monthly,
                              onTap: () => setState(
                                () => _rangeMode = ReportRangeMode.monthly,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Laba Bersih + Margin Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Laba Bersih · ${_periodSubtitle(selectedMonth)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(
                                color: AppColors.textOnDarkMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isProfit
                                          ? AppColors.incomeGreen
                                          : AppColors.expenseRed)
                                      .withValues(alpha: 0.16),
                              borderRadius: AppRadius.pillBorder,
                            ),
                            child: Text(
                              'Margin ${margin.toStringAsFixed(1).replaceAll('.', ',')}%',
                              style: AppTypography.labelSmall(
                                color: isProfit
                                    ? AppColors.incomeGreenLight
                                    : const Color(0xFFFCA5A5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        CurrencyFormatter.formatNetProfit(netProfit),
                        style: AppTypography.displayBalance(
                          color: AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Interactive Trend Line Chart
                      _CashflowTrendChart(
                        transactions: periodTx,
                        rangeMode: _rangeMode,
                        period: period,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // White Content Sheet
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: AppRadius.sheetTopBorder,
                ),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  AppSpacing.bottomNavClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2-Column Income vs Expense Cards
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Total Pemasukan',
                            amount: totalIncome,
                            amountColor: AppColors.incomeGreen,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _MetricCard(
                            label: 'Total Pengeluaran',
                            amount: totalExpense,
                            amountColor: AppColors.expenseRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Pengeluaran per Kategori',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sectionHeading(),
                          ),
                        ),
                        Text(
                          '${summary?.transactionCount ?? 0} transaksi',
                          style: AppTypography.caption(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (periodTx.isEmpty)
                      EmptyStateView(
                        icon: Icons.bar_chart_rounded,
                        title: 'Belum Ada Data Laporan',
                        description:
                            'Catat transaksi pada periode ini untuk melihat grafik arus kas dan rincian pengeluaran.',
                        actionLabel: 'Catat Transaksi',
                        onAction: () => context.push(AppRoutes.catat),
                      )
                    else if (breakdown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxl,
                        ),
                        child: Center(
                          child: Text(
                            'Belum ada pengeluaran pada periode ini.',
                            style: AppTypography.bodyRegular(),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: List.generate(breakdown.length, (i) {
                          final item = breakdown[i];
                          final barColor =
                              _categoryColors[i % _categoryColors.length];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.categoryName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodyMedium(),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      '${CurrencyFormatter.format(item.amount)} (${item.percentage.round()}%)',
                                      style: AppTypography.captionMedium(
                                        color: AppColors.textPrimary,
                                      ).copyWith(
                                        fontFeatures:
                                            AppTypography.tabularFeatures,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                ClipRRect(
                                  borderRadius: AppRadius.pillBorder,
                                  child: LinearProgressIndicator(
                                    value: (item.percentage / 100).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    minHeight: 7,
                                    backgroundColor: AppColors.surfaceMuted,
                                    valueColor: AlwaysStoppedAnimation(
                                      barColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
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
            color: isSelected
                ? AppColors.darkCardElevated
                : Colors.transparent,
            borderRadius: AppRadius.smBorder,
          ),
          child: Text(
            label,
            style: AppTypography.captionMedium(
              color: isSelected
                  ? AppColors.textOnDark
                  : AppColors.textOnDarkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final int amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption()),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyFormatter.format(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.amountMedium(color: amountColor),
          ),
        ],
      ),
    );
  }
}

class _CashflowTrendChart extends StatefulWidget {
  const _CashflowTrendChart({
    required this.transactions,
    required this.rangeMode,
    required this.period,
  });

  final List<Transaction> transactions;
  final ReportRangeMode rangeMode;
  final DatePeriod period;

  @override
  State<_CashflowTrendChart> createState() => _CashflowTrendChartState();
}

class _CashflowTrendChartState extends State<_CashflowTrendChart> {
  int? _touchedIndex;

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _dayMonth(DateTime date) =>
      '${date.day} ${_shortMonths[date.month - 1]}';

  String _formatCompactSigned(int netAmount) {
    final abs = netAmount.abs();
    final sign = netAmount > 0 ? '+' : (netAmount < 0 ? '-' : '');
    if (abs >= 1000000) {
      final jt = (abs / 1000000).toStringAsFixed(2).replaceAll('.', ',');
      return '${sign}Rp $jt jt';
    }
    if (abs >= 1000) {
      final rb = (abs / 1000).round();
      return '${sign}Rp $rb rb';
    }
    return '${sign}Rp $abs';
  }

  @override
  void didUpdateWidget(covariant _CashflowTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rangeMode != widget.rangeMode ||
        oldWidget.period != widget.period) {
      _touchedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bucketCount = widget.rangeMode == ReportRangeMode.daily ? 4 : 7;
    final incomeBuckets = List<double>.filled(bucketCount, 0);
    final expenseBuckets = List<double>.filled(bucketCount, 0);
    final bucketLabels = List<String>.filled(bucketCount, '');

    // Build human-readable bucket labels.
    if (widget.rangeMode == ReportRangeMode.daily) {
      const hourLabels = ['00:00', '06:00', '12:00', '18:00'];
      for (var i = 0; i < bucketCount; i++) {
        bucketLabels[i] = hourLabels[i];
      }
    } else if (widget.rangeMode == ReportRangeMode.weekly) {
      for (var i = 0; i < bucketCount; i++) {
        bucketLabels[i] = _dayMonth(
          widget.period.start.add(Duration(days: i)),
        );
      }
    } else {
      final totalDays = widget.period.end.day;
      for (var i = 0; i < bucketCount; i++) {
        final day = (1 + ((totalDays - 1) * i / (bucketCount - 1))).round();
        bucketLabels[i] = _dayMonth(
          DateTime(widget.period.start.year, widget.period.start.month, day),
        );
      }
    }

    // Aggregate transactions into buckets.
    for (final tx in widget.transactions) {
      int idx;
      if (widget.rangeMode == ReportRangeMode.daily) {
        idx = (tx.transactionDate.hour ~/ 6).clamp(0, bucketCount - 1);
      } else if (widget.rangeMode == ReportRangeMode.weekly) {
        idx = tx.transactionDate
            .difference(widget.period.start)
            .inDays
            .clamp(0, bucketCount - 1);
      } else {
        final totalDays = math.max(1, widget.period.end.day - 1);
        idx = (((tx.transactionDate.day - 1) / totalDays) * (bucketCount - 1))
            .round()
            .clamp(0, bucketCount - 1);
      }

      if (tx.type == TransactionTypes.income) {
        incomeBuckets[idx] += tx.amount.toDouble();
      } else {
        expenseBuckets[idx] += tx.amount.toDouble();
      }
    }

    final maxVal = math.max(
      incomeBuckets.reduce(math.max),
      expenseBuckets.reduce(math.max),
    );
    final chartMaxY = maxVal <= 0 ? 100000.0 : maxVal * 1.35;

    // Default active indicator points to the highest-activity bucket (or middle).
    int defaultIndex = bucketCount ~/ 2;
    double bestScore = -1;
    for (var i = 0; i < bucketCount; i++) {
      final score = incomeBuckets[i] + expenseBuckets[i];
      if (score > bestScore && score > 0) {
        bestScore = score;
        defaultIndex = i;
      }
    }
    final activeIndex = (_touchedIndex ?? defaultIndex).clamp(
      0,
      bucketCount - 1,
    );

    final incomeSpots = List.generate(
      bucketCount,
      (i) => FlSpot(i.toDouble(), incomeBuckets[i]),
    );
    final expenseSpots = List.generate(
      bucketCount,
      (i) => FlSpot(i.toDouble(), expenseBuckets[i]),
    );

    final incomeLine = LineChartBarData(
      spots: incomeSpots,
      isCurved: false,
      color: AppColors.textOnDark,
      barWidth: 2.4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, _) => spot.x.toInt() == activeIndex,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 4.5,
          color: AppColors.textOnDark,
          strokeWidth: 2.5,
          strokeColor: AppColors.darkBase,
        ),
      ),
    );

    final expenseLine = LineChartBarData(
      spots: expenseSpots,
      isCurved: false,
      color: const Color(0xFF64748B),
      barWidth: 2.0,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );

    final startLabel = widget.rangeMode == ReportRangeMode.daily
        ? '00:00'
        : _dayMonth(widget.period.start);
    final endLabel = widget.rangeMode == ReportRangeMode.daily
        ? '24:00'
        : _dayMonth(widget.period.end);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 136,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: chartMaxY,
                showingTooltipIndicators: [
                  ShowingTooltipIndicators([
                    LineBarSpot(
                      incomeLine,
                      0,
                      incomeSpots[activeIndex],
                    ),
                  ]),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    final spots = response?.lineBarSpots;
                    if (spots != null && spots.isNotEmpty) {
                      final tappedIdx = spots.first.x.toInt().clamp(
                        0,
                        bucketCount - 1,
                      );
                      if (tappedIdx != _touchedIndex) {
                        setState(() => _touchedIndex = tappedIdx);
                      }
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipMargin: 10,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipBorder: const BorderSide(
                      color: AppColors.darkBorder,
                      width: 1,
                    ),
                    getTooltipColor: (_) => AppColors.darkBase,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt().clamp(0, bucketCount - 1);
                        final net =
                            (incomeBuckets[idx] - expenseBuckets[idx]).round();
                        return LineTooltipItem(
                          '${bucketLabels[idx]}: ${_formatCompactSigned(net)}',
                          AppTypography.captionMedium(
                            color: AppColors.textOnDark,
                          ).copyWith(
                            fontFeatures: AppTypography.tabularFeatures,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMaxY / 2,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.darkBorder,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [incomeLine, expenseLine],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                startLabel,
                style: AppTypography.labelSmall(
                  color: AppColors.textOnDarkSubtle,
                ),
              ),
              Expanded(
                child: Text(
                  'Putih: Masuk · Abu: Keluar',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
              ),
              Text(
                endLabel,
                style: AppTypography.labelSmall(
                  color: AppColors.textOnDarkSubtle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
