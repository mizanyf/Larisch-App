import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/finance_repository.dart';
import '../domain/finance_summary.dart';

/// Singleton local SQLite database provider.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Repository provider for all local CRUD & financial operations.
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.watch(appDatabaseProvider));
});

/// Reactive stream of the active business profile.
final businessProfileProvider = StreamProvider<BusinessProfile?>((ref) {
  return ref.watch(financeRepositoryProvider).watchBusinessProfile();
});

/// Reactive stream of the 3 manual cash accounts (Tunai, QRIS, Rekening Bank).
final cashAccountsProvider = StreamProvider<List<CashAccount>>((ref) {
  return ref.watch(financeRepositoryProvider).watchCashAccounts();
});

/// Reactive stream of all categories (including archived for historical lookup).
final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref
      .watch(financeRepositoryProvider)
      .watchCategories(includeArchived: true);
});

/// Reactive stream of active categories filtered by type ('income' | 'expense').
final activeCategoriesByTypeProvider =
    StreamProvider.family<List<Category>, String>((ref, type) {
      return ref
          .watch(financeRepositoryProvider)
          .watchCategories(type: type, includeArchived: false);
    });

/// Reactive stream of all financial transactions sorted newest-first.
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(financeRepositoryProvider).watchAllTransactions();
});

/// Live Total Saldo Kas & per-account balances (Tunai, QRIS, Rekening Bank).
final cashBalanceSummaryProvider = Provider<AsyncValue<CashBalanceSummary>>((
  ref,
) {
  final accountsAsync = ref.watch(cashAccountsProvider);
  final txAsync = ref.watch(allTransactionsProvider);

  return accountsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
    data: (accounts) => txAsync.when(
      loading: () => const AsyncValue.loading(),
      error: AsyncValue.error,
      data: (transactions) => AsyncValue.data(
        FinanceCalculator.calculateCashBalances(
          accounts: accounts,
          allTransactions: transactions,
        ),
      ),
    ),
  );
});

/// Live Laba Bersih, Pemasukan, Pengeluaran, Margin %, and category breakdown
/// for any selected [DatePeriod].
final periodProfitSummaryProvider =
    Provider.family<AsyncValue<PeriodProfitSummary>, DatePeriod>((ref, period) {
      final txAsync = ref.watch(allTransactionsProvider);
      final categoriesAsync = ref.watch(allCategoriesProvider);

      return txAsync.when(
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
        data: (transactions) => categoriesAsync.when(
          loading: () => const AsyncValue.loading(),
          error: AsyncValue.error,
          data: (categories) => AsyncValue.data(
            FinanceCalculator.calculatePeriodProfit(
              allTransactions: transactions,
              categories: categories,
              period: period,
            ),
          ),
        ),
      );
    });
