import 'package:drift/drift.dart';

import 'app_database.dart';
import 'seed_data.dart';

/// Repository encapsulating all local SQLite read/write operations for Larisch.
class FinanceRepository {
  const FinanceRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // Business Profile & Onboarding
  // ---------------------------------------------------------------------------

  Stream<BusinessProfile?> watchBusinessProfile() {
    return (_db.select(_db.businessProfiles)
          ..where((t) => t.id.equals(1)))
        .watchSingleOrNull();
  }

  Future<BusinessProfile?> getBusinessProfile() {
    return (_db.select(_db.businessProfiles)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
  }

  Future<void> saveBusinessProfile({
    required String businessName,
    String? businessType,
    bool? onboardingCompleted,
  }) async {
    final trimmedName = businessName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Nama usaha tidak boleh kosong.');
    }

    final existing = await getBusinessProfile();
    final now = DateTime.now();

    await _db.into(_db.businessProfiles).insertOnConflictUpdate(
      BusinessProfilesCompanion(
        id: const Value(1),
        businessName: Value(trimmedName),
        businessType: Value(businessType?.trim()),
        onboardingCompleted: Value(
          onboardingCompleted ?? existing?.onboardingCompleted ?? false,
        ),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> completeOnboarding({
    required String businessName,
    String? businessType,
    required int cashInitialBalance,
    required int qrisInitialBalance,
    required int bankInitialBalance,
  }) async {
    await _db.transaction(() async {
      await saveBusinessProfile(
        businessName: businessName,
        businessType: businessType,
        onboardingCompleted: true,
      );
      await updateInitialBalances(
        cash: cashInitialBalance,
        qris: qrisInitialBalance,
        bank: bankInitialBalance,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Manual Cash Accounts (Tunai, QRIS, Rekening Bank)
  // ---------------------------------------------------------------------------

  Stream<List<CashAccount>> watchCashAccounts() {
    return (_db.select(_db.cashAccounts)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<List<CashAccount>> getCashAccounts() {
    return (_db.select(_db.cashAccounts)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> updateInitialBalances({
    required int cash,
    required int qris,
    required int bank,
  }) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.cashAccounts)
            ..where((t) => t.id.equals(AccountIds.cash)))
          .write(
        CashAccountsCompanion(
          initialBalance: Value(cash),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.cashAccounts)
            ..where((t) => t.id.equals(AccountIds.qris)))
          .write(
        CashAccountsCompanion(
          initialBalance: Value(qris),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(_db.cashAccounts)
            ..where((t) => t.id.equals(AccountIds.bank)))
          .write(
        CashAccountsCompanion(
          initialBalance: Value(bank),
          updatedAt: Value(now),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  Stream<List<Category>> watchCategories({
    String? type,
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.categories);
    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.watch();
  }

  Future<List<Category>> getCategories({
    String? type,
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.categories);
    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.get();
  }

  Future<int> addCategory({
    required String name,
    required String type,
    String iconKey = 'label',
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama kategori tidak boleh kosong.');
    }
    _validateType(type);

    return _db.into(_db.categories).insert(
      CategoriesCompanion.insert(
        name: trimmed,
        type: type,
        iconKey: iconKey,
        isDefault: const Value(false),
        isArchived: const Value(false),
      ),
    );
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    String? iconKey,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama kategori tidak boleh kosong.');
    }
    await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(trimmed),
        iconKey: iconKey != null ? Value(iconKey) : const Value.absent(),
      ),
    );
  }

  /// Archives category if referenced by any transaction; otherwise deletes it.
  Future<void> deleteOrArchiveCategory(int id) async {
    final usedCount = await (_db.select(_db.transactions)
          ..where((t) => t.categoryId.equals(id)))
        .get()
        .then((rows) => rows.length);

    if (usedCount > 0) {
      await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        const CategoriesCompanion(isArchived: Value(true)),
      );
    } else {
      await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
    }
  }

  // ---------------------------------------------------------------------------
  // Transactions
  // ---------------------------------------------------------------------------

  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
          ..orderBy([
            (t) => OrderingTerm.desc(t.transactionDate),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<List<Transaction>> getAllTransactions() {
    return (_db.select(_db.transactions)
          ..orderBy([
            (t) => OrderingTerm.desc(t.transactionDate),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<int> addTransaction({
    required String type,
    required int amount,
    required String accountId,
    required int categoryId,
    String? note,
    DateTime? transactionDate,
  }) {
    _validateType(type);
    _validateAmount(amount);
    _validateAccountId(accountId);

    final now = DateTime.now();
    return _db.into(_db.transactions).insert(
      TransactionsCompanion.insert(
        type: type,
        amount: amount,
        accountId: accountId,
        categoryId: categoryId,
        note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
        transactionDate: transactionDate ?? now,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateTransaction({
    required int id,
    required String type,
    required int amount,
    required String accountId,
    required int categoryId,
    String? note,
    required DateTime transactionDate,
  }) async {
    _validateType(type);
    _validateAmount(amount);
    _validateAccountId(accountId);

    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        type: Value(type),
        amount: Value(amount),
        accountId: Value(accountId),
        categoryId: Value(categoryId),
        note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
        transactionDate: Value(transactionDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteTransaction(int id) {
    return (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Reset Local Data
  // ---------------------------------------------------------------------------

  Future<void> resetAllData() async {
    await _db.transaction(() async {
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.cashAccounts).go();
      await _db.delete(_db.businessProfiles).go();
      await _db.seedDefaults();
    });
  }

  // ---------------------------------------------------------------------------
  // Domain Validation Helpers
  // ---------------------------------------------------------------------------

  void _validateAmount(int amount) {
    if (amount <= 0) {
      throw ArgumentError('Nominal transaksi harus lebih dari Rp 0.');
    }
  }

  void _validateType(String type) {
    if (type != TransactionTypes.income && type != TransactionTypes.expense) {
      throw ArgumentError('Jenis transaksi tidak valid: $type');
    }
  }

  void _validateAccountId(String accountId) {
    if (!AccountIds.all.contains(accountId)) {
      throw ArgumentError('Akun kas tidak valid: $accountId');
    }
  }
}
