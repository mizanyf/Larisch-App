import 'package:intl/intl.dart';

/// Utilities to format and parse integer Rupiah amounts consistently.
abstract final class CurrencyFormatter {
  static final NumberFormat _idrNumber = NumberFormat.decimalPattern('id_ID');

  /// Formats an integer Rupiah amount, e.g. `23500000` -> `Rp 23.500.000`.
  static String format(int amount, {bool withSymbol = true}) {
    final isNegative = amount < 0;
    final formatted = _idrNumber.format(amount.abs());
    final prefix = withSymbol ? 'Rp ' : '';
    return isNegative ? '- $prefix$formatted' : '$prefix$formatted';
  }

  /// Formats a signed cashflow amount:
  /// income -> `+ Rp 385.000`, expense -> `- Rp 450.000`.
  static String formatSigned(int amount, {required bool isIncome}) {
    final formatted = _idrNumber.format(amount.abs());
    return isIncome ? '+ Rp $formatted' : '- Rp $formatted';
  }

  /// Formats net profit/loss with explicit `+` or `-` sign.
  static String formatNetProfit(int netAmount) {
    final formatted = _idrNumber.format(netAmount.abs());
    if (netAmount > 0) return '+ Rp $formatted';
    if (netAmount < 0) return '- Rp $formatted';
    return 'Rp 0';
  }

  /// Strips all non-digit characters and parses into an integer Rupiah value.
  /// Returns `0` for empty or invalid input.
  static int parse(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.tryParse(digits) ?? 0;
  }
}
