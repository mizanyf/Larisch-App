import '../database/app_database.dart';
import '../database/seed_data.dart';

/// Calculated balance breakdown for a single manual cash account.
class AccountBalanceSummary {
  const AccountBalanceSummary({
    required this.accountId,
    required this.name,
    required this.initialBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.currentBalance,
  });

  final String accountId;
  final String name;
  final int initialBalance;
  final int totalIncome;
  final int totalExpense;
  final int currentBalance;
}

/// Combined cash balance across Tunai, QRIS, and Rekening Bank.
/// Strictly distinct from period Net Profit (Laba Bersih).
class CashBalanceSummary {
  const CashBalanceSummary({
    required this.totalCashBalance,
    required this.accounts,
  });

  final int totalCashBalance;
  final List<AccountBalanceSummary> accounts;

  int balanceFor(String accountId) {
    for (final acc in accounts) {
      if (acc.accountId == accountId) return acc.currentBalance;
    }
    return 0;
  }

  int get cashBalance => balanceFor(AccountIds.cash);
  int get qrisBalance => balanceFor(AccountIds.qris);
  int get bankBalance => balanceFor(AccountIds.bank);
}

/// Category expense breakdown row for Reports.
class CategoryExpenseSummary {
  const CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.amount,
    required this.percentage,
  });

  final int categoryId;
  final String categoryName;
  final String iconKey;
  final int amount;
  final double percentage;
}

/// Period Profit & Loss summary (Laba Bersih = Pemasukan - Pengeluaran).
class PeriodProfitSummary {
  const PeriodProfitSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.marginPercent,
    required this.transactionCount,
    required this.expenseByCategory,
  });

  final int totalIncome;
  final int totalExpense;
  final int netProfit;
  final double marginPercent;
  final int transactionCount;
  final List<CategoryExpenseSummary> expenseByCategory;
}

/// Inclusive date range [start, end] for filtering reports & summaries.
class DatePeriod {
  const DatePeriod({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  factory DatePeriod.month(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return DatePeriod(start: start, end: end);
  }

  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  bool operator ==(Object other) {
    return other is DatePeriod && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

/// Pure, deterministic integer-Rupiah calculation engine matching ARCHITECTURE.md.
abstract final class FinanceCalculator {
  static CashBalanceSummary calculateCashBalances({
    required List<CashAccount> accounts,
    required List<Transaction> allTransactions,
  }) {
    final incomeByAccount = <String, int>{};
    final expenseByAccount = <String, int>{};

    for (final tx in allTransactions) {
      if (tx.type == TransactionTypes.income) {
        incomeByAccount[tx.accountId] =
            (incomeByAccount[tx.accountId] ?? 0) + tx.amount;
      } else if (tx.type == TransactionTypes.expense) {
        expenseByAccount[tx.accountId] =
            (expenseByAccount[tx.accountId] ?? 0) + tx.amount;
      }
    }

    final sortedAccounts = [...accounts]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    var totalCash = 0;
    final summaries = <AccountBalanceSummary>[];

    for (final acc in sortedAccounts) {
      final income = incomeByAccount[acc.id] ?? 0;
      final expense = expenseByAccount[acc.id] ?? 0;
      final current = acc.initialBalance + income - expense;
      totalCash += current;

      summaries.add(
        AccountBalanceSummary(
          accountId: acc.id,
          name: acc.name,
          initialBalance: acc.initialBalance,
          totalIncome: income,
          totalExpense: expense,
          currentBalance: current,
        ),
      );
    }

    return CashBalanceSummary(
      totalCashBalance: totalCash,
      accounts: summaries,
    );
  }

  static PeriodProfitSummary calculatePeriodProfit({
    required List<Transaction> allTransactions,
    required List<Category> categories,
    required DatePeriod period,
  }) {
    final categoryMap = {for (final c in categories) c.id: c};

    var totalIncome = 0;
    var totalExpense = 0;
    var count = 0;
    final expensePerCategory = <int, int>{};

    for (final tx in allTransactions) {
      if (!period.contains(tx.transactionDate)) continue;
      count++;
      if (tx.type == TransactionTypes.income) {
        totalIncome += tx.amount;
      } else if (tx.type == TransactionTypes.expense) {
        totalExpense += tx.amount;
        expensePerCategory[tx.categoryId] =
            (expensePerCategory[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    final netProfit = totalIncome - totalExpense;
    final marginPercent = totalIncome > 0
        ? (netProfit / totalIncome) * 100.0
        : 0.0;

    final breakdown = expensePerCategory.entries.map((entry) {
      final cat = categoryMap[entry.key];
      final pct = totalExpense > 0 ? (entry.value / totalExpense) * 100.0 : 0.0;
      return CategoryExpenseSummary(
        categoryId: entry.key,
        categoryName: cat?.name ?? 'Lainnya',
        iconKey: cat?.iconKey ?? 'receipt_long',
        amount: entry.value,
        percentage: pct,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return PeriodProfitSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netProfit: netProfit,
      marginPercent: marginPercent,
      transactionCount: count,
      expenseByCategory: breakdown,
    );
  }
}
