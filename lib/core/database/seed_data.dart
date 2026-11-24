import 'package:drift/drift.dart';

import 'app_database.dart';

/// Canonical account IDs for Larisch's 3 manual cash accounts.
abstract final class AccountIds {
  static const String cash = 'cash';
  static const String qris = 'qris';
  static const String bank = 'bank';

  static const List<String> all = [cash, qris, bank];
}

/// Canonical transaction/category types.
abstract final class TransactionTypes {
  static const String income = 'income';
  static const String expense = 'expense';
}

/// Default seed records inserted on first app launch or after data reset.
abstract final class DatabaseSeedData {
  static List<CashAccountsCompanion> defaultAccounts() {
    final now = DateTime.now();
    return [
      CashAccountsCompanion.insert(
        id: AccountIds.cash,
        name: 'Tunai',
        initialBalance: const Value(0),
        sortOrder: 1,
        updatedAt: Value(now),
      ),
      CashAccountsCompanion.insert(
        id: AccountIds.qris,
        name: 'QRIS',
        initialBalance: const Value(0),
        sortOrder: 2,
        updatedAt: Value(now),
      ),
      CashAccountsCompanion.insert(
        id: AccountIds.bank,
        name: 'Rekening Bank',
        initialBalance: const Value(0),
        sortOrder: 3,
        updatedAt: Value(now),
      ),
    ];
  }

  static List<CategoriesCompanion> defaultCategories() {
    return [
      // Income categories
      CategoriesCompanion.insert(
        name: 'Penjualan Tunai',
        type: TransactionTypes.income,
        iconKey: 'payments',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Penjualan QRIS/Transfer',
        type: TransactionTypes.income,
        iconKey: 'qr_code',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Pesanan/Katering',
        type: TransactionTypes.income,
        iconKey: 'shopping_bag',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Pemasukan Lainnya',
        type: TransactionTypes.income,
        iconKey: 'add_circle',
        isDefault: const Value(true),
      ),
      // Expense categories
      CategoriesCompanion.insert(
        name: 'Bahan Baku',
        type: TransactionTypes.expense,
        iconKey: 'inventory_2',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Gaji Karyawan',
        type: TransactionTypes.expense,
        iconKey: 'groups',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Sewa & Listrik',
        type: TransactionTypes.expense,
        iconKey: 'bolt',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Kemasan',
        type: TransactionTypes.expense,
        iconKey: 'takeout_dining',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Transportasi',
        type: TransactionTypes.expense,
        iconKey: 'local_shipping',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Operasional Lainnya',
        type: TransactionTypes.expense,
        iconKey: 'receipt_long',
        isDefault: const Value(true),
      ),
    ];
  }
}
