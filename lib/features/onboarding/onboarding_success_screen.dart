import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';
import 'onboarding_state.dart';

/// 04 - Onboarding Success Screen: Confirms setup completion before entering Beranda.
class OnboardingSuccessScreen extends ConsumerWidget {
  const OnboardingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final businessName = draft.businessName.isEmpty
        ? 'Usaha Kamu'
        : draft.businessName;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBase,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.incomeGreen.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.incomeGreenLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.incomeGreenLight,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '$businessName Siap Dicatat!',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLarge(
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Saldo awal kas sudah tersimpan di perangkatmu. Mulai catat pemasukan dan pengeluaran harian kapan saja secara offline.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyRegular(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.cardInsets,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: AppRadius.cardBorder,
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Saldo Kas Awal',
                        style: AppTypography.caption(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        CurrencyFormatter.format(draft.totalInitialCash),
                        style: AppTypography.displayBalance(
                          color: AppColors.textOnDark,
                        ).copyWith(fontSize: 26),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    ref.read(onboardingDraftProvider.notifier).reset();
                    context.go(AppRoutes.beranda);
                  },
                  child: const Text('Masuk ke Beranda'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
