import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/finance_summary.dart';

/// Tracks the currently selected month across Beranda, Transaksi, and Laporan.
class SelectedMonthNotifier extends StateNotifier<DateTime> {
  SelectedMonthNotifier()
    : super(DateTime(DateTime.now().year, DateTime.now().month, 1));

  void previousMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1, 1);
  }

  void setMonth(int year, int month) {
    state = DateTime(year, month, 1);
  }
}

final selectedMonthProvider =
    StateNotifierProvider<SelectedMonthNotifier, DateTime>((ref) {
      return SelectedMonthNotifier();
    });

/// Derived inclusive [DatePeriod] for the currently selected month.
final selectedMonthPeriodProvider = Provider<DatePeriod>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return DatePeriod.month(month.year, month.month);
});
