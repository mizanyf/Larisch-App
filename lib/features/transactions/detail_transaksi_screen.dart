import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/seed_data.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import 'catat_transaksi_screen.dart';

/// Detail Transaksi screen with Edit and Delete (with confirmation dialog).
class DetailTransaksiScreen extends ConsumerWidget {
  const DetailTransaksiScreen({super.key, required this.transactionId});

  final int transactionId;

  String _accountLabel(String accountId) {
    switch (accountId) {
      case AccountIds.cash:
        return 'Tunai';
      case AccountIds.qris:
        return 'QRIS';
      case AccountIds.bank:
        return 'Rekening Bank';
      default:
        return accountId;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction tx,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text('Hapus Transaksi?', style: AppTypography.sectionHeading()),
          content: Text(
            'Transaksi sebesar ${CurrencyFormatter.format(tx.amount)} akan dihapus permanen dan saldo akun ${_accountLabel(tx.accountId)} akan otomatis disesuaikan kembali.',
            style: AppTypography.bodyRegular(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
                minimumSize: const Size(96, 40),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(financeRepositoryProvider).deleteTransaction(tx.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil dihapus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(allTransactionsProvider);
    final catAsync = ref.watch(allCategoriesProvider);

    final transactions = txAsync.valueOrNull ?? const <Transaction>[];
    final tx = transactions
        .where((item) => item.id == transactionId)
        .firstOrNull;

    if (tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Transaksi')),
        body: Center(
          child: Text(
            'Transaksi tidak ditemukan.',
            style: AppTypography.bodyRegular(),
          ),
        ),
      );
    }

    final categories = catAsync.valueOrNull ?? const <Category>[];
    final categoryName =
        categories.where((c) => c.id == tx.categoryId).firstOrNull?.name ??
        'Lainnya';
    final isIncome = tx.type == TransactionTypes.income;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi', style: AppTypography.sectionHeading()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Hero Amount Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.darkBase,
                        borderRadius: AppRadius.cardLargeBorder,
                      ),
                      child: Column(
                        children: [
                          Text(
                            isIncome ? 'Pemasukan' : 'Pengeluaran',
                            style: AppTypography.captionMedium(
                              color: isIncome
                                  ? AppColors.incomeGreenLight
                                  : const Color(0xFFFCA5A5),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            CurrencyFormatter.formatSigned(
                              tx.amount,
                              isIncome: isIncome,
                            ),
                            style: AppTypography.displayBalance(
                              color: AppColors.textOnDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            categoryName,
                            style: AppTypography.bodyRegular(
                              color: AppColors.textOnDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Metadata Card
                    Container(
                      width: double.infinity,
                      padding: AppSpacing.cardInsets,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppRadius.cardBorder,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Akun Pembayaran',
                            value: _accountLabel(tx.accountId),
                          ),
                          const Divider(height: 24),
                          _DetailRow(label: 'Kategori', value: categoryName),
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Tanggal & Waktu',
                            value:
                                '${AppDateFormatter.shortDate(tx.transactionDate)}, ${AppDateFormatter.time24(tx.transactionDate)}',
                          ),
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Catatan',
                            value: (tx.note != null && tx.note!.isNotEmpty)
                                ? tx.note!
                                : '-',
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmDelete(context, ref, tx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expenseRed,
                        side: const BorderSide(color: AppColors.dangerBorder),
                      ),
                      child: const Text('Hapus'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                CatatTransaksiScreen(editingTransaction: tx),
                          ),
                        );
                      },
                      child: const Text('Edit Transaksi'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: AppTypography.caption()),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.bodyMedium(),
          ),
        ),
      ],
    );
  }
}
