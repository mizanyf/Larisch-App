import 'package:drift/drift.dart';

/// Income and expense categories (default system categories + user custom).
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get iconKey => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}
