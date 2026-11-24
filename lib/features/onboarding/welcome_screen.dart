import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/larisch_logo_badge.dart';

/// 01 - Welcome Screen: Introduces Larisch's offline-first UMKM value props.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBase,
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const LarischLogoBadge(size: 36),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Larisch',
                            style: AppTypography.pageTitle(
                              color: AppColors.textOnDark,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Pembukuan Usaha\nLebih Mudah & Terarah.',
                        style: AppTypography.displayBalance(
                          color: AppColors.textOnDark,
                        ).copyWith(fontSize: 30, height: 1.2),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Catat pemasukan, pantau pengeluaran, dan pahami kondisi kas usahamu dalam satu aplikasi offline yang sederhana.',
                        style: AppTypography.bodyRegular(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const _WelcomeFeatureRow(
                        icon: Icons.account_balance_wallet_outlined,
                        title: '3 Akun Kas Terpisah',
                        subtitle: 'Pantau Tunai, QRIS, dan Rekening Bank secara manual.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _WelcomeFeatureRow(
                        icon: Icons.insights_outlined,
                        title: 'Saldo Kas & Laba Bersih Jelas',
                        subtitle: 'Bedakan uang kas tersedia dengan keuntungan periode.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _WelcomeFeatureRow(
                        icon: Icons.lock_outline_rounded,
                        title: '100% Offline & Data Lokal',
                        subtitle: 'Semua catatan tersimpan aman di perangkatmu.',
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadius.sheetTopBorder,
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.setupProfile),
                      child: const Text('Mulai Atur Usaha'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tanpa login akun cloud · Gratis digunakan offline',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeFeatureRow extends StatelessWidget {
  const _WelcomeFeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: AppRadius.smBorder,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Icon(icon, color: AppColors.textOnDark, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium(color: AppColors.textOnDark),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: AppTypography.caption(color: AppColors.textOnDarkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
