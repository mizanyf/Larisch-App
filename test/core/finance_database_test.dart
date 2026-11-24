import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larisch_app/core/database/app_database.dart';
import 'package:larisch_app/core/database/finance_repository.dart';
import 'package:larisch_app/core/database/seed_data.dart';
import 'package:larisch_app/core/domain/finance_summary.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FinanceRepository(db);
    // Trigger database open & seed defaults.
    await repo.getCashAccounts();
  });

  tearDown(() async {
    await db.close();
  });

  test('seeds 3 manual cash accounts and default categories on init', () async {
    final accounts = await repo.getCashAccounts();
    final incomeCats = await repo.getCategories(type: TransactionTypes.income);
    final expenseCats = await repo.getCategories(
      type: TransactionTypes.expense,
    );

    expect(accounts.map((a) => a.id).toList(), [
      AccountIds.cash,
      AccountIds.qris,
      AccountIds.bank,
    ]);
    expect(accounts.every((a) => a.initialBalance == 0), isTrue);
    expect(incomeCats.length, 4);
    expect(expenseCats.length, 6);
  });

  test(
    'separates Total Saldo Kas from Laba Bersih and tracks 3 manual accounts',
    () async {
      await repo.completeOnboarding(
        businessName: 'Kedai Kopi Budi',
        businessType: 'Kuliner & Minuman',
        cashInitialBalance: 5000000,
        qrisInitialBalance: 3000000,
        bankInitialBalance: 9300000,
      );

      final incomeCat = (await repo.getCategories(
        type: TransactionTypes.income,
      )).first;
      final expenseCat = (await repo.getCategories(
        type: TransactionTypes.expense,
      )).first;

      // Income in Nov 2026: 16.000.000 total across accounts
      await repo.addTransaction(
        type: TransactionTypes.income,
        amount: 6000000,
        accountId: AccountIds.cash,
        categoryId: incomeCat.id,
        note: 'Penjualan Tunai',
        transactionDate: DateTime(2026, 11, 10),
      );
      await repo.addTransaction(
        type: TransactionTypes.income,
        amount: 5000000,
        accountId: AccountIds.qris,
        categoryId: incomeCat.id,
        note: 'Penjualan QRIS',
        transactionDate: DateTime(2026, 11, 15),
      );
      await repo.addTransaction(
        type: TransactionTypes.income,
        amount: 5000000,
        accountId: AccountIds.bank,
        categoryId: incomeCat.id,
        note: 'Transfer Pesanan',
        transactionDate: DateTime(2026, 11, 20),
      );

      // Expense in Nov 2026: 9.800.000 total across accounts
      await repo.addTransaction(
        type: TransactionTypes.expense,
        amount: 2550000,
        accountId: AccountIds.cash,
        categoryId: expenseCat.id,
        note: 'Belanja Harian',
        transactionDate: DateTime(2026, 11, 12),
      );
      await repo.addTransaction(
        type: TransactionTypes.expense,
        amount: 1950000,
        accountId: AccountIds.qris,
        categoryId: expenseCat.id,
        note: 'Supplier Susu',
        transactionDate: DateTime(2026, 11, 18),
      );
      await repo.addTransaction(
        type: TransactionTypes.expense,
        amount: 5300000,
        accountId: AccountIds.bank,
        categoryId: expenseCat.id,
        note: 'Gaji & Sewa',
        transactionDate: DateTime(2026, 11, 22),
      );

      final accounts = await repo.getCashAccounts();
      final transactions = await repo.getAllTransactions();
      final categories = await repo.getCategories(includeArchived: true);

      final cashSummary = FinanceCalculator.calculateCashBalances(
        accounts: accounts,
        allTransactions: transactions,
      );
      final novProfit = FinanceCalculator.calculatePeriodProfit(
        allTransactions: transactions,
        categories: categories,
        period: DatePeriod.month(2026, 11),
      );

      // Total Saldo Kas includes initial balances (17.300.000 + 6.200.000 = 23.500.000)
      expect(cashSummary.cashBalance, 8450000);
      expect(cashSummary.qrisBalance, 6050000);
      expect(cashSummary.bankBalance, 9000000);
      expect(cashSummary.totalCashBalance, 23500000);

      // Laba Bersih only measures Nov 2026 income - expense (6.200.000), NOT initial cash
      expect(novProfit.totalIncome, 16000000);
      expect(novProfit.totalExpense, 9800000);
      expect(novProfit.netProfit, 6200000);
      expect(novProfit.marginPercent, closeTo(38.75, 0.01));
    },
  );

  test(
    'recalculates balances accurately on edit, account transfer, and delete',
    () async {
      await repo.updateInitialBalances(cash: 1000000, qris: 500000, bank: 0);
      final incomeCat = (await repo.getCategories(
        type: TransactionTypes.income,
      )).first;

      final txId = await repo.addTransaction(
        type: TransactionTypes.income,
        amount: 300000,
        accountId: AccountIds.cash,
        categoryId: incomeCat.id,
        transactionDate: DateTime(2026, 11, 24),
      );

      // Edit amount and move from Tunai -> QRIS
      await repo.updateTransaction(
        id: txId,
        type: TransactionTypes.income,
        amount: 450000,
        accountId: AccountIds.qris,
        categoryId: incomeCat.id,
        transactionDate: DateTime(2026, 11, 24),
      );

      var cashSummary = FinanceCalculator.calculateCashBalances(
        accounts: await repo.getCashAccounts(),
        allTransactions: await repo.getAllTransactions(),
      );
      expect(cashSummary.cashBalance, 1000000);
      expect(cashSummary.qrisBalance, 950000);
      expect(cashSummary.totalCashBalance, 1950000);

      // Delete transaction -> restores exact initial balances
      await repo.deleteTransaction(txId);
      cashSummary = FinanceCalculator.calculateCashBalances(
        accounts: await repo.getCashAccounts(),
        allTransactions: await repo.getAllTransactions(),
      );
      expect(cashSummary.cashBalance, 1000000);
      expect(cashSummary.qrisBalance, 500000);
      expect(cashSummary.totalCashBalance, 1500000);
    },
  );

  test('rejects zero or negative transaction amounts', () async {
    final incomeCat = (await repo.getCategories(
      type: TransactionTypes.income,
    )).first;

    expect(
      () => repo.addTransaction(
        type: TransactionTypes.income,
        amount: 0,
        accountId: AccountIds.cash,
        categoryId: incomeCat.id,
      ),
      throwsArgumentError,
    );

    expect(
      () => repo.addTransaction(
        type: TransactionTypes.expense,
        amount: -50000,
        accountId: AccountIds.cash,
        categoryId: incomeCat.id,
      ),
      throwsArgumentError,
    );
  });

  test('returns zero profit and 0% margin for empty period', () async {
    final summary = FinanceCalculator.calculatePeriodProfit(
      allTransactions: await repo.getAllTransactions(),
      categories: await repo.getCategories(),
      period: DatePeriod.month(2026, 12),
    );

    expect(summary.totalIncome, 0);
    expect(summary.totalExpense, 0);
    expect(summary.netProfit, 0);
    expect(summary.marginPercent, 0.0);
    expect(summary.transactionCount, 0);
    expect(summary.expenseByCategory, isEmpty);
  });
}
