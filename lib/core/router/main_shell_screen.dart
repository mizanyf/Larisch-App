import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';
import '../widgets/floating_bottom_nav.dart';
import 'app_routes.dart';

/// Main app shell hosting the 4 primary tabs with FloatingBottomNav + blue FAB `+`.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  int get _currentIndex {
    if (location.startsWith(AppRoutes.transaksi)) return 1;
    if (location.startsWith(AppRoutes.laporan)) return 2;
    if (location.startsWith(AppRoutes.profil)) return 3;
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.beranda);
      case 1:
        context.go(AppRoutes.transaksi);
      case 2:
        context.go(AppRoutes.laporan);
      case 3:
        context.go(AppRoutes.profil);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingBottomNav(
              currentIndex: _currentIndex,
              onTabSelected: (index) => _onTabSelected(context, index),
              onAddPressed: () => context.push(AppRoutes.catat),
            ),
          ),
        ],
      ),
    );
  }
}

/// Temporary placeholder tab screen used until Phase 4 & 5 UI slicing.
class TabPlaceholderScreen extends StatelessWidget {
  const TabPlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: AppTypography.pageTitle())),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTypography.sectionHeading()),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
