import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_success_screen.dart';
import '../../features/onboarding/setup_business_profile_screen.dart';
import '../../features/onboarding/setup_initial_balances_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
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
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TabPlaceholderScreen(
                title: 'Beranda',
                subtitle: 'Layar Beranda siap di-slicing pada Phase 4.',
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.transaksi,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TabPlaceholderScreen(
                title: 'Transaksi',
                subtitle: 'Layar Riwayat Transaksi siap di-slicing pada Phase 4.',
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.laporan,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TabPlaceholderScreen(
                title: 'Laporan',
                subtitle: 'Layar Laporan Keuangan siap di-slicing pada Phase 5.',
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.profil,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TabPlaceholderScreen(
                title: 'Profil',
                subtitle: 'Layar Profil & Backup Lokal siap di-slicing pada Phase 5.',
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.catat,
        builder: (context, state) => const TabPlaceholderScreen(
          title: 'Catat Transaksi',
          subtitle: 'Form Catat Pemasukan & Pengeluaran siap di-slicing pada Phase 4.',
        ),
      ),
    ],
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});
