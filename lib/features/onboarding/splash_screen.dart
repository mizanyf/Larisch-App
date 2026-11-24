import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/finance_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/larisch_logo_badge.dart';

/// 00 - Splash Screen: Logo-only on pure black (#000000) matching FigCraft.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.splashDuration = const Duration(milliseconds: 1200),
  });

  final Duration splashDuration;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    bool isDone = false;
    try {
      final repo = ref.read(financeRepositoryProvider);
      final (_, profile) = await (
        Future<void>.delayed(widget.splashDuration),
        repo.getBusinessProfile(),
      ).wait;
      isDone = profile != null && profile.onboardingCompleted;
    } catch (error, stackTrace) {
      debugPrint('Splash bootstrap error: $error\n$stackTrace');
    }

    if (!mounted) return;
    context.go(isDone ? AppRoutes.beranda : AppRoutes.welcome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.splashBlack,
        body: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Image.asset(
              LarischLogoBadge.assetPath,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
