import 'package:drift/drift.dart';

/// Manual cash accounts: Tunai (`cash`), QRIS (`qris`), Rekening Bank (`bank`).
class CashAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
