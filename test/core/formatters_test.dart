import 'package:flutter_test/flutter_test.dart';
import 'package:larisch_app/core/utils/currency_formatter.dart';
import 'package:larisch_app/core/utils/date_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats positive and negative Rupiah amounts', () {
      expect(CurrencyFormatter.format(23500000), 'Rp 23.500.000');
      expect(CurrencyFormatter.format(0), 'Rp 0');
      expect(CurrencyFormatter.format(-450000), '- Rp 450.000');
      expect(CurrencyFormatter.format(125000, withSymbol: false), '125.000');
    });

    test('formats signed income and expense amounts', () {
      expect(
        CurrencyFormatter.formatSigned(385000, isIncome: true),
        '+ Rp 385.000',
      );
      expect(
        CurrencyFormatter.formatSigned(450000, isIncome: false),
        '- Rp 450.000',
      );
    });

    test('formats net profit/loss accurately', () {
      expect(CurrencyFormatter.formatNetProfit(6200000), '+ Rp 6.200.000');
      expect(CurrencyFormatter.formatNetProfit(-150000), '- Rp 150.000');
      expect(CurrencyFormatter.formatNetProfit(0), 'Rp 0');
    });

    test('parses formatted strings into integer Rupiah', () {
      expect(CurrencyFormatter.parse('Rp 23.500.000'), 23500000);
      expect(CurrencyFormatter.parse('125.000'), 125000);
      expect(CurrencyFormatter.parse(''), 0);
      expect(CurrencyFormatter.parse('abc'), 0);
    });
  });

  group('AppDateFormatter', () {
    final now = DateTime(2026, 11, 24, 15, 0);

    test('formats monthYear and shortDate in Indonesian', () {
      expect(AppDateFormatter.monthYear(now), 'Nov 2026');
      expect(AppDateFormatter.shortDate(now), '24 Nov 2026');
    });

    test('formats relativeDateTime for today, yesterday, and older dates', () {
      expect(
        AppDateFormatter.relativeDateTime(DateTime(2026, 11, 24, 14, 20), now: now),
        'Hari ini, 14:20',
      );
      expect(
        AppDateFormatter.relativeDateTime(DateTime(2026, 11, 23, 9, 5), now: now),
        'Kemarin, 09:05',
      );
      expect(
        AppDateFormatter.relativeDateTime(DateTime(2026, 11, 20, 8, 30), now: now),
        '20 Nov 2026, 08:30',
      );
    });
  });
}
