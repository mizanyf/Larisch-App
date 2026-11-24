import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larisch_app/core/database/app_database.dart';
import 'package:larisch_app/core/database/finance_repository.dart';
import 'package:larisch_app/core/database/local_backup_service.dart';
import 'package:larisch_app/core/database/seed_data.dart';
import 'package:larisch_app/core/domain/finance_summary.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository repo;
  late LocalBackupService backupService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = FinanceRepository(db);
    backupService = LocalBackupService(db);
    await repo.getCashAccounts();
  });

  tearDown(() async {
    await db.close();
  });

  test('exports and restores full local dataset atomically', () async {
    await repo.completeOnboarding(
      businessName: 'Kedai Kopi Budi',
      businessType: 'Kuliner & Minuman',
      cashInitialBalance: 2000000,
      qrisInitialBalance: 1000000,
      bankInitialBalance: 5000000,
    );

    final customCatId = await repo.addCategory(
      name: 'Biji Kopi Arabika',
      type: TransactionTypes.expense,
    );
    final incomeCat = (await repo.getCategories(
      type: TransactionTypes.income,
    )).first;

    await repo.addTransaction(
      type: TransactionTypes.income,
      amount: 750000,
      accountId: AccountIds.qris,
      categoryId: incomeCat.id,
      note: 'Penjualan Weekend',
      transactionDate: DateTime(2026, 11, 24, 10, 0),
    );
    await repo.addTransaction(
      type: TransactionTypes.expense,
      amount: 250000,
      accountId: AccountIds.cash,
      categoryId: customCatId,
      note: 'Restock Arabika',
      transactionDate: DateTime(2026, 11, 24, 12, 0),
    );

    final jsonBackup = await backupService.exportToJsonString();

    // Wipe everything locally.
    await repo.resetAllData();
    expect(await repo.getBusinessProfile(), isNull);
    expect(await repo.getAllTransactions(), isEmpty);

    // Restore from JSON backup.
    final preview = await backupService.restoreFromJsonString(jsonBackup);
    expect(preview.businessName, 'Kedai Kopi Budi');
    expect(preview.transactionCount, 2);

    final restoredProfile = await repo.getBusinessProfile();
    expect(restoredProfile?.businessName, 'Kedai Kopi Budi');
    expect(restoredProfile?.onboardingCompleted, isTrue);

    final cashSummary = FinanceCalculator.calculateCashBalances(
      accounts: await repo.getCashAccounts(),
      allTransactions: await repo.getAllTransactions(),
    );
    expect(cashSummary.cashBalance, 1750000);
    expect(cashSummary.qrisBalance, 1750000);
    expect(cashSummary.bankBalance, 5000000);
    expect(cashSummary.totalCashBalance, 8500000);
  });

  test('rejects invalid or non-Larisch JSON without corrupting local data', () {
    expect(
      () => backupService.parseAndValidate('not valid json'),
      throwsFormatException,
    );
    expect(
      () => backupService.parseAndValidate('{"app":"OtherApp","schemaVersion":1}'),
      throwsFormatException,
    );
    expect(
      () => backupService.parseAndValidate(
        '{"app":"Larisch","schemaVersion":1,"cashAccounts":[],"categories":[],"transactions":[{"type":"income","amount":0,"accountId":"cash","categoryId":1}]}',
      ),
      throwsFormatException,
    );
  });
}
