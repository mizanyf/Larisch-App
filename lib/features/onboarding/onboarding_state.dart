import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';

/// Holds transient onboarding draft data between Step 1 (Profile) and Step 2 (Balances).
class OnboardingDraft {
  const OnboardingDraft({
    this.businessName = '',
    this.businessType = 'Kuliner & Minuman',
    this.cashInitialBalance = 0,
    this.qrisInitialBalance = 0,
    this.bankInitialBalance = 0,
  });

  final String businessName;
  final String businessType;
  final int cashInitialBalance;
  final int qrisInitialBalance;
  final int bankInitialBalance;

  int get totalInitialCash =>
      cashInitialBalance + qrisInitialBalance + bankInitialBalance;

  OnboardingDraft copyWith({
    String? businessName,
    String? businessType,
    int? cashInitialBalance,
    int? qrisInitialBalance,
    int? bankInitialBalance,
  }) {
    return OnboardingDraft(
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      cashInitialBalance: cashInitialBalance ?? this.cashInitialBalance,
      qrisInitialBalance: qrisInitialBalance ?? this.qrisInitialBalance,
      bankInitialBalance: bankInitialBalance ?? this.bankInitialBalance,
    );
  }
}

class OnboardingDraftNotifier extends StateNotifier<OnboardingDraft> {
  OnboardingDraftNotifier() : super(const OnboardingDraft());

  void setProfile({required String businessName, required String businessType}) {
    state = state.copyWith(
      businessName: businessName.trim(),
      businessType: businessType.trim(),
    );
  }

  void setInitialBalances({
    required int cash,
    required int qris,
    required int bank,
  }) {
    state = state.copyWith(
      cashInitialBalance: cash,
      qrisInitialBalance: qris,
      bankInitialBalance: bank,
    );
  }

  void reset() {
    state = const OnboardingDraft();
  }
}

final onboardingDraftProvider =
    StateNotifierProvider<OnboardingDraftNotifier, OnboardingDraft>((ref) {
      return OnboardingDraftNotifier();
    });

/// Formats numeric text input live with Indonesian thousands dots (e.g. 5.000.000).
class ThousandsRupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final parsed = int.tryParse(digits);
    if (parsed == null) return oldValue;

    final formatted = CurrencyFormatter.format(parsed, withSymbol: false);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
