import 'package:drift/drift.dart';

/// Single active business profile stored locally on the device.
class BusinessProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get businessName => text()();
  TextColumn get businessType => text().nullable()();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
