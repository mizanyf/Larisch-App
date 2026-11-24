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

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
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
            splashDuration: const Duration(milliseconds: 50),
          );
          ref.onDispose(router.dispose);
          return router;
        }),
      ],
      child: const LarischApp(),
    );
  }

  testWidgets(
    'new user goes Splash (logo-only) -> Welcome -> Profile -> Balances -> Success -> Beranda',
    (tester) async {
      await tester.pumpWidget(buildApp());

      // Splash Screen is logo-only (no wordmark text).
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Larisch'), findsNothing);

      // Advance past splash delay -> lands on Welcome Screen.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Mulai Atur Usaha'), findsOneWidget);

      // Go to Step 1: Setup Profil Usaha.
      await tester.tap(find.text('Mulai Atur Usaha'));
      await tester.pumpAndSettle();
      expect(find.text('Kenalkan Usahamu'), findsOneWidget);

      // Validation blocks empty business name.
      await tester.tap(find.text('Lanjut ke Saldo Awal'));
      await tester.pumpAndSettle();
      expect(find.text('Masukkan nama usaha terlebih dahulu'), findsOneWidget);

      // Enter valid business name and proceed.
      await tester.enterText(find.byType(TextFormField), 'Kedai Kopi Budi');
      await tester.tap(find.text('Lanjut ke Saldo Awal'));
      await tester.pumpAndSettle();
      expect(find.text('Atur Saldo Kas Awal'), findsOneWidget);

      // Enter initial balances for Tunai, QRIS, Rekening Bank.
      final balanceFields = find.byType(TextField);
      await tester.enterText(balanceFields.at(0), '5000000');
      await tester.enterText(balanceFields.at(1), '3000000');
      await tester.enterText(balanceFields.at(2), '9300000');
      await tester.pump();
      expect(find.text('Rp 17.300.000'), findsOneWidget);

      // Complete onboarding -> lands on Onboarding Success.
      await tester.tap(find.text('Simpan & Selesai'));
      await tester.pumpAndSettle();
      expect(find.text('Kedai Kopi Budi Siap Dicatat!'), findsOneWidget);

      // Verify persisted in SQLite.
      final repo = FinanceRepository(db);
      final profile = await repo.getBusinessProfile();
      expect(profile?.businessName, 'Kedai Kopi Budi');
      expect(profile?.onboardingCompleted, isTrue);

      // Enter Beranda shell.
      await tester.tap(find.text('Masuk ke Beranda'));
      await tester.pumpAndSettle();
      expect(find.text('Beranda'), findsWidgets);

      // Flush Drift stream cleanup timers before test teardown.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    },
  );

  testWidgets('returning user skips onboarding directly to Beranda', (
    tester,
  ) async {
    final repo = FinanceRepository(db);
    await repo.completeOnboarding(
      businessName: 'Kedai Kopi Budi',
      businessType: 'Kuliner & Minuman',
      cashInitialBalance: 1000000,
      qrisInitialBalance: 0,
      bankInitialBalance: 0,
    );

    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Mulai Atur Usaha'), findsNothing);
    expect(find.text('Beranda'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
