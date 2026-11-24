import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/finance_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/larisch_logo_badge.dart';

/// 00 - Splash Screen: Logo-only on pure black (#000000) with smooth
/// fade-in -> hold -> fade-out sequence before entering the app.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
    this.splashDuration = const Duration(milliseconds: 1600),
  });

  final Duration splashDuration;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.splashDuration,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 32,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 36,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 32,
      ),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.94,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 32,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 36,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.03,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 32,
      ),
    ]).animate(_controller);

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    bool isDone = false;
    try {
      final repo = ref.read(financeRepositoryProvider);
      final (_, profile) = await (
        _controller.forward().orCancel.catchError((_) {}),
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
    final logoSize = (MediaQuery.sizeOf(context).shortestSide * 0.40).clamp(
      112.0,
      168.0,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.splashBlack,
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  LarischLogoBadge.assetPath,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
