import 'package:drift/drift.dart';

import 'cash_accounts.dart';
import 'categories.dart';

/// Financial transactions stored as integer Rupiah amounts (`amount > 0`).
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'income' | 'expense'
  IntColumn get amount => integer()();
  TextColumn get accountId => text().references(CashAccounts, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
