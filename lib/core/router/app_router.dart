import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/beranda_screen.dart';
import '../../features/onboarding/onboarding_success_screen.dart';
import '../../features/onboarding/setup_business_profile_screen.dart';
import '../../features/onboarding/setup_initial_balances_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/profile/backup_restore_screen.dart';
import '../../features/profile/kelola_kategori_screen.dart';
import '../../features/profile/profil_screen.dart';
import '../../features/reports/laporan_screen.dart';
import '../../features/transactions/catat_transaksi_screen.dart';
import '../../features/transactions/detail_transaksi_screen.dart';
import '../../features/transactions/transaksi_screen.dart';
import '../database/seed_data.dart';
import 'app_routes.dart';
import 'main_shell_screen.dart';

/// Creates the GoRouter instance; [splashDuration] can be shortened in tests.
GoRouter createAppRouter({
  Duration splashDuration = const Duration(milliseconds: 1200),
}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            SplashScreen(splashDuration: splashDuration),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.setupProfile,
        builder: (context, state) => const SetupBusinessProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.setupBalances,
        builder: (context, state) => const SetupInitialBalancesScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSuccess,
        builder: (context, state) => const OnboardingSuccessScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.beranda,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BerandaScreen()),
          ),
          GoRoute(
            path: AppRoutes.transaksi,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TransaksiScreen()),
          ),
          GoRoute(
            path: AppRoutes.laporan,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LaporanScreen()),
          ),
          GoRoute(
            path: AppRoutes.profil,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.catat,
        builder: (context, state) {
          final type =
              state.uri.queryParameters['type'] ?? TransactionTypes.expense;
          return CatatTransaksiScreen(initialType: type);
        },
      ),
      GoRoute(
        path: '${AppRoutes.transaksi}/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
          return DetailTransaksiScreen(transactionId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.kelolaKategori,
        builder: (context, state) => const KelolaKategoriScreen(),
      ),
      GoRoute(
        path: AppRoutes.backupRestore,
        builder: (context, state) => const BackupRestoreScreen(),
      ),
    ],
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});
