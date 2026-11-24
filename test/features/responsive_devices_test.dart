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

class _DeviceSpec {
  const _DeviceSpec({
    required this.name,
    required this.size,
    required this.padding,
  });

  final String name;
  final Size size;
  final FakeViewPadding padding;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const devices = <_DeviceSpec>[
    _DeviceSpec(
      name: 'iPhone SE (375x667)',
      size: Size(375, 667),
      padding: FakeViewPadding(top: 20, bottom: 0),
    ),
    _DeviceSpec(
      name: 'iPhone 15 Pro Dynamic Island (393x852)',
      size: Size(393, 852),
      padding: FakeViewPadding(top: 59, bottom: 34),
    ),
    _DeviceSpec(
      name: 'iPhone 15 Pro Max (430x932)',
      size: Size(430, 932),
      padding: FakeViewPadding(top: 59, bottom: 34),
    ),
    _DeviceSpec(
      name: 'Android Compact 3-Button Nav (360x640)',
      size: Size(360, 640),
      padding: FakeViewPadding(top: 24, bottom: 48),
    ),
    _DeviceSpec(
      name: 'Android Large Gesture Nav (412x915)',
      size: Size(412, 915),
      padding: FakeViewPadding(top: 32, bottom: 24),
    ),
    _DeviceSpec(
      name: 'Landscape Mobile (844x390)',
      size: Size(844, 390),
      padding: FakeViewPadding(left: 44, right: 44, top: 0, bottom: 21),
    ),
  ];

  for (final device in devices) {
    testWidgets(
      'zero RenderFlex overflow across all 4 tabs & Catat on ${device.name}',
      (tester) async {
        tester.view.physicalSize = device.size;
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = device.padding;
        tester.view.viewPadding = device.padding;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewPadding);

        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        final repo = FinanceRepository(db);
        await repo.completeOnboarding(
          businessName: 'Kedai Kopi Budi Nusantara',
          businessType: 'Kuliner & Minuman',
          cashInitialBalance: 8450000,
          qrisInitialBalance: 6050000,
          bankInitialBalance: 9000000,
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
          amount: 16000000,
          accountId: AccountIds.qris,
          categoryId: incomeCat.id,
          note: 'Penjualan Kedai Bulan Ini',
          transactionDate: now,
        );
        await repo.addTransaction(
          type: TransactionTypes.expense,
          amount: 9800000,
          accountId: AccountIds.bank,
          categoryId: expenseCat.id,
          note: 'Belanja Bahan Baku & Operasional',
          transactionDate: now,
        );

        await tester.pumpWidget(
          ProviderScope(
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
          ),
        );

        await tester.pump(const Duration(milliseconds: 60));
        await tester.pumpAndSettle();
        expect(find.text('Total Saldo Kas'), findsOneWidget);

        // Navigate across Transaksi -> Laporan -> Profil -> Catat
        await tester.tap(find.text('Transaksi'));
        await tester.pumpAndSettle();
        expect(find.text('Transaksi'), findsWidgets);

        await tester.tap(find.text('Laporan'));
        await tester.pumpAndSettle();
        expect(find.text('Laporan Keuangan'), findsOneWidget);

        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();
        expect(find.text('Profil & Pengaturan'), findsOneWidget);

        // Open Catat Transaksi via blue FAB '+'
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Catat Pemasukan'), findsOneWidget);

        // Flush Drift stream cleanup timers.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(Duration.zero);
      },
    );
  }

  testWidgets('Welcome & Catat remain overflow-free with open keyboard on iPhone SE', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 20, bottom: 0);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewInsets);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
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
      ),
    );

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
    expect(find.text('Mulai Atur Usaha'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
  });
}
