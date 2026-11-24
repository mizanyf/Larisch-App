import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:larisch_app/app.dart';
import 'package:larisch_app/core/database/app_database.dart';
import 'package:larisch_app/core/database/finance_repository.dart';
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
      qrisInitialBalance: 500000,
      bankInitialBalance: 0,
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

  testWidgets(
    'Beranda empty state -> Catat validation -> Create -> Detail -> Edit -> Delete',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      // Beranda displays initial Total Saldo Kas & empty state.
      expect(find.text('Kedai Kopi Budi'), findsOneWidget);
      expect(find.text('Rp 1.500.000'), findsOneWidget);
      expect(find.text('Belum Ada Transaksi'), findsOneWidget);

      // Open + Pemasukan from Quick Action.
      await tester.tap(find.text('+ Pemasukan'));
      await tester.pumpAndSettle();
      expect(find.text('Catat Pemasukan'), findsOneWidget);

      // Try saving Rp 0 -> inline validation appears.
      await tester.tap(find.byKey(const Key('save_transaction_button')));
      await tester.pumpAndSettle();
      expect(
        find.text('Masukkan nominal lebih dari Rp 0 sebelum menyimpan'),
        findsOneWidget,
      );

      // Enter valid income amount & note, then save.
      await tester.enterText(find.byKey(const Key('amount_field')), '385000');
      await tester.enterText(
        find.byKey(const Key('note_field')),
        'Penjualan Kedai',
      );
      await tester.tap(find.byKey(const Key('save_transaction_button')));
      await tester.pumpAndSettle();

      // Dismiss SnackBar so it does not cover the transaction row.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Back on Beranda: Total Saldo Kas updated (1.500.000 + 385.000 = 1.885.000).
      expect(find.text('Rp 1.885.000'), findsOneWidget);
      expect(find.text('Penjualan Kedai'), findsOneWidget);

      // Open Detail Transaksi.
      await tester.ensureVisible(find.text('Penjualan Kedai'));
      await tester.tap(find.text('Penjualan Kedai'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Transaksi'), findsOneWidget);

      // Edit transaction amount to 500.000.
      await tester.tap(find.text('Edit Transaksi'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Transaksi'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('amount_field')), '500000');
      await tester.tap(find.byKey(const Key('save_transaction_button')));
      await tester.pumpAndSettle();

      // Detail screen reflects updated + Rp 500.000.
      expect(find.text('+ Rp 500.000'), findsOneWidget);

      // Dismiss SnackBar then delete transaction via confirmation dialog.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Transaksi?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      // Back on Beranda: balance restored to Rp 1.500.000 and empty state returns.
      expect(find.text('Rp 1.500.000'), findsOneWidget);
      expect(find.text('Belum Ada Transaksi'), findsOneWidget);

      // Flush Drift stream cleanup timers before test teardown.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    },
  );
}
