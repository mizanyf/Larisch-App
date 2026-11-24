import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:larisch_app/app.dart';
import 'package:larisch_app/core/database/app_database.dart';
import 'package:larisch_app/core/database/finance_repository.dart';
import 'package:larisch_app/core/database/seed_data.dart';
import 'package:larisch_app/core/providers/finance_providers.dart';
import 'package:larisch_app/core/router/app_router.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = FinanceRepository(db);
    await repo.completeOnboarding(
      businessName: 'Kedai Kopi Budi',
      businessType: 'Kuliner & Minuman',
      cashInitialBalance: 1000000,
      qrisInitialBalance: 0,
      bankInitialBalance: 0,
    );

    final incomeCat = (await repo.getCategories(
      type: TransactionTypes.income,
    )).first;
    final expenseCat = (await repo.getCategories(
      type: TransactionTypes.expense,
    )).first;

    final now = DateTime.now();
    await repo.addTransaction(
      type: TransactionTypes.income,
      amount: 1000000,
      accountId: AccountIds.cash,
      categoryId: incomeCat.id,
      note: 'Penjualan Harian',
      transactionDate: now,
    );
    await repo.addTransaction(
      type: TransactionTypes.expense,
      amount: 400000,
      accountId: AccountIds.cash,
      categoryId: expenseCat.id,
      note: 'Belanja Bahan',
      transactionDate: now,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appRouterProvider.overrideWith((ref) {
          final router = createAppRouter(
            splashDuration: const Duration(milliseconds: 20),
          );
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: const LarischApp(),
    );
  }

  testWidgets('Laporan shows profit/margin/chart & Profil navigates to sub-screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    // Switch to Laporan tab.
    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Laporan Keuangan'), findsOneWidget);
    expect(find.text('+ Rp 600.000'), findsOneWidget);
    expect(find.text('Margin 60,0%'), findsOneWidget);
    expect(find.text('Bahan Baku'), findsOneWidget);

    // Switch to Profil tab.
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profil & Pengaturan'), findsOneWidget);
    expect(find.text('Kedai Kopi Budi'), findsOneWidget);

    // Open Kelola Kategori.
    await tester.tap(find.text('Kelola Kategori'));
    await tester.pumpAndSettle();
    expect(find.text('Bahan Baku'), findsOneWidget);

    // Go back and open Backup & Restore Lokal.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Backup & Restore Lokal'));
    await tester.pumpAndSettle();
    expect(find.text('100% Penyimpanan Lokal (Tanpa Cloud)'), findsOneWidget);

    // Flush Drift stream cleanup timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
