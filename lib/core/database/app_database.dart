import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seed_data.dart';
import 'tables/business_profiles.dart';
import 'tables/cash_accounts.dart';
import 'tables/categories.dart';
import 'tables/transactions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    BusinessProfiles,
    CashAccounts,
    Categories,
    Transactions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory constructor for fast, isolated unit & widget tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaults();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await seedDefaults();
    },
  );

  /// Idempotently seeds the 3 manual cash accounts and default categories.
  Future<void> seedDefaults() async {
    final existingAccounts = await select(cashAccounts).get();
    if (existingAccounts.isEmpty) {
      await batch((b) {
        b.insertAll(cashAccounts, DatabaseSeedData.defaultAccounts());
      });
    }

    final existingCategories = await select(categories).get();
    if (existingCategories.isEmpty) {
      await batch((b) {
        b.insertAll(categories, DatabaseSeedData.defaultCategories());
      });
    }
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'larisch_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
