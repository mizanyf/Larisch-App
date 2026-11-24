import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/finance_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';
import 'onboarding_state.dart';

/// 03 - Setup Saldo Awal Manual (Step 2 of 2) for Tunai, QRIS, and Rekening Bank.
class SetupInitialBalancesScreen extends ConsumerStatefulWidget {
  const SetupInitialBalancesScreen({super.key});

  @override
  ConsumerState<SetupInitialBalancesScreen> createState() =>
      _SetupInitialBalancesScreenState();
}

class _SetupInitialBalancesScreenState
    extends ConsumerState<SetupInitialBalancesScreen> {
  late final TextEditingController _cashController;
  late final TextEditingController _qrisController;
  late final TextEditingController _bankController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    _cashController = TextEditingController(
      text: draft.cashInitialBalance > 0
          ? CurrencyFormatter.format(draft.cashInitialBalance, withSymbol: false)
          : '',
    );
    _qrisController = TextEditingController(
      text: draft.qrisInitialBalance > 0
          ? CurrencyFormatter.format(draft.qrisInitialBalance, withSymbol: false)
          : '',
    );
    _bankController = TextEditingController(
      text: draft.bankInitialBalance > 0
          ? CurrencyFormatter.format(draft.bankInitialBalance, withSymbol: false)
          : '',
    );
  }

  @override
  void dispose() {
    _cashController.dispose();
    _qrisController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  int get _cashAmount => CurrencyFormatter.parse(_cashController.text);
  int get _qrisAmount => CurrencyFormatter.parse(_qrisController.text);
  int get _bankAmount => CurrencyFormatter.parse(_bankController.text);
  int get _totalAmount => _cashAmount + _qrisAmount + _bankAmount;

  Future<void> _handleComplete() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final draft = ref.read(onboardingDraftProvider);
      final businessName = draft.businessName.isEmpty
          ? 'Usaha Saya'
          : draft.businessName;

      ref
          .read(onboardingDraftProvider.notifier)
          .setInitialBalances(
            cash: _cashAmount,
            qris: _qrisAmount,
            bank: _bankAmount,
          );

      await ref
          .read(financeRepositoryProvider)
          .completeOnboarding(
            businessName: businessName,
            businessType: draft.businessType,
            cashInitialBalance: _cashAmount,
            qrisInitialBalance: _qrisAmount,
            bankInitialBalance: _bankAmount,
          );

      if (!mounted) return;
      context.go(AppRoutes.onboardingSuccess);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Langkah 2 dari 2', style: AppTypography.captionMedium()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: 1.0,
                minHeight: 4,
                borderRadius: AppRadius.pillBorder,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(AppColors.accentBlue),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Atur Saldo Kas Awal',
                      style: AppTypography.headlineLarge(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Masukkan perkiraan saldo manual saat ini untuk masing-masing akun. Kosongkan jika ingin mulai dari Rp 0.',
                      style: AppTypography.bodyRegular(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _BalanceField(
                      label: 'Tunai',
                      helper: 'Uang tunai di kasir atau laci usaha',
                      icon: Icons.payments_outlined,
                      controller: _cashController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BalanceField(
                      label: 'QRIS',
                      helper: 'Saldo tercatat manual dari pembayaran QRIS',
                      icon: Icons.qr_code_2_rounded,
                      controller: _qrisController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BalanceField(
                      label: 'Rekening Bank',
                      helper: 'Saldo tercatat manual di rekening usaha',
                      icon: Icons.account_balance_outlined,
                      controller: _bankController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Container(
                      width: double.infinity,
                      padding: AppSpacing.cardInsets,
                      decoration: BoxDecoration(
                        color: AppColors.darkBase,
                        borderRadius: AppRadius.cardBorder,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Saldo Kas Awal',
                                style: AppTypography.caption(
                                  color: AppColors.textOnDarkMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                CurrencyFormatter.format(_totalAmount),
                                style: AppTypography.cardMetric(
                                  color: AppColors.textOnDark,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Tercatat manual',
                            style: AppTypography.labelSmall(
                              color: AppColors.textOnDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: FilledButton(
                onPressed: _isSaving ? null : _handleComplete,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnDark,
                        ),
                      )
                    : const Text('Simpan & Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceField extends StatelessWidget {
  const _BalanceField({
    required this.label,
    required this.helper,
    required this.icon,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String helper;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTypography.bodyMedium()),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(helper, style: AppTypography.caption()),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsRupiahInputFormatter()],
          onChanged: onChanged,
          style: AppTypography.amountMedium(),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: AppTypography.amountMedium(
              color: AppColors.textSecondary,
            ),
            hintText: '0',
          ),
        ),
      ],
    );
  }
}
