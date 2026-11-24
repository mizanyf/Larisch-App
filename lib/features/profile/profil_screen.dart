import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/seed_data.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/larisch_logo_badge.dart';
import '../onboarding/onboarding_state.dart';

/// Screen 5 - Profil & Pengaturan: Business identity, initial balances,
/// category management, local JSON backup/restore, and double-confirmed reset.
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    BusinessProfile? profile,
  ) async {
    final nameController = TextEditingController(
      text: profile?.businessName ?? '',
    );
    final typeController = TextEditingController(
      text: profile?.businessType ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text(
            'Edit Profil Usaha',
            style: AppTypography.sectionHeading(),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nama Usaha'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: typeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Usaha (Opsional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              style: FilledButton.styleFrom(minimumSize: const Size(96, 40)),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (saved == true && context.mounted) {
      await ref
          .read(financeRepositoryProvider)
          .saveBusinessProfile(
            businessName: nameController.text.trim(),
            businessType: typeController.text.trim(),
          );
    }

    nameController.dispose();
    typeController.dispose();
  }

  Future<void> _showEditInitialBalancesDialog(
    BuildContext context,
    WidgetRef ref,
    List<CashAccount> accounts,
  ) async {
    int initialFor(String id) {
      return accounts.where((a) => a.id == id).firstOrNull?.initialBalance ?? 0;
    }

    final cashCtrl = TextEditingController(
      text: CurrencyFormatter.format(
        initialFor(AccountIds.cash),
        withSymbol: false,
      ),
    );
    final qrisCtrl = TextEditingController(
      text: CurrencyFormatter.format(
        initialFor(AccountIds.qris),
        withSymbol: false,
      ),
    );
    final bankCtrl = TextEditingController(
      text: CurrencyFormatter.format(
        initialFor(AccountIds.bank),
        withSymbol: false,
      ),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text(
            'Atur Saldo Awal Manual',
            style: AppTypography.sectionHeading(),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cashCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsRupiahInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Tunai',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: qrisCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsRupiahInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'QRIS',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: bankCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsRupiahInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Rekening Bank',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(minimumSize: const Size(96, 40)),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (saved == true && context.mounted) {
      await ref
          .read(financeRepositoryProvider)
          .updateInitialBalances(
            cash: CurrencyFormatter.parse(cashCtrl.text),
            qris: CurrencyFormatter.parse(qrisCtrl.text),
            bank: CurrencyFormatter.parse(bankCtrl.text),
          );
    }

    cashCtrl.dispose();
    qrisCtrl.dispose();
    bankCtrl.dispose();
  }

  Future<void> _confirmDoubleReset(BuildContext context, WidgetRef ref) async {
    final step1 = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text(
            'Reset Semua Data Lokal?',
            style: AppTypography.sectionHeading(),
          ),
          content: Text(
            'Seluruh transaksi, kategori kustom, saldo awal, dan profil usaha akan dihapus dari perangkat ini. Pastikan kamu sudah membuat backup lokal terlebih dahulu.',
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
                minimumSize: const Size(110, 40),
              ),
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );

    if (step1 != true || !context.mounted) return;

    final step2 = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text(
            'Konfirmasi Akhir Reset',
            style: AppTypography.sectionHeading(color: AppColors.expenseRed),
          ),
          content: Text(
            'Tindakan ini tidak dapat dibatalkan. Yakin hapus semua data Larisch sekarang?',
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
                minimumSize: const Size(120, 40),
              ),
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );

    if (step2 != true || !context.mounted) return;

    await ref.read(financeRepositoryProvider).resetAllData();
    if (!context.mounted) return;
    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider).valueOrNull;
    final accounts = ref.watch(cashAccountsProvider).valueOrNull ?? const [];
    final hPad = AppResponsive.horizontalPadding(context);
    final bottomClearance = AppResponsive.bottomNavClearance(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        bottom: false,
        child: AppResponsive.constrain(
          ListView(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, bottomClearance),
            children: [
            Text('Profil & Pengaturan', style: AppTypography.pageTitle()),
            const SizedBox(height: AppSpacing.lg),
            // Business Identity Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkBase,
                borderRadius: AppRadius.cardLargeBorder,
              ),
              child: Row(
                children: [
                  const LarischLogoBadge(size: 44, borderRadius: 10),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.businessName ?? 'Usaha Saya',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.sectionHeading(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (profile?.businessType?.isNotEmpty ?? false)
                              ? profile!.businessType!
                              : 'UMKM Indonesia · Offline-First',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(
                            color: AppColors.textOnDarkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showEditProfileDialog(context, ref, profile),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textOnDarkMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Pengaturan Pembukuan', style: AppTypography.captionMedium()),
            const SizedBox(height: AppSpacing.sm),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.storefront_outlined,
                  title: 'Profil Usaha',
                  subtitle: 'Ubah nama dan jenis usahamu',
                  onTap: () => _showEditProfileDialog(context, ref, profile),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Saldo Awal Manual',
                  subtitle: 'Sesuaikan saldo awal Tunai, QRIS, Rekening Bank',
                  onTap: () =>
                      _showEditInitialBalancesDialog(context, ref, accounts),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.category_outlined,
                  title: 'Kelola Kategori',
                  subtitle: 'Tambah atau ubah kategori pemasukan & pengeluaran',
                  onTap: () => context.push(AppRoutes.kelolaKategori),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Data & Privasi Lokal', style: AppTypography.captionMedium()),
            const SizedBox(height: AppSpacing.sm),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.save_alt_rounded,
                  title: 'Backup & Restore Lokal',
                  subtitle: 'Export atau pulihkan file backup .json tanpa cloud',
                  onTap: () => context.push(AppRoutes.backupRestore),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Reset Semua Data',
                  subtitle: 'Hapus seluruh catatan lokal & mulai dari awal',
                  isDestructive: true,
                  onTap: () => _confirmDoubleReset(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Text(
                'Larisch v1.0.0 · Penyimpanan Lokal Offline',
                style: AppTypography.caption(),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorder,
        side: BorderSide(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive ? AppColors.expenseRed : AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: fg, size: 22),
      title: Text(title, style: AppTypography.bodyMedium(color: fg)),
      subtitle: Text(subtitle, style: AppTypography.caption()),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
        size: 20,
      ),
    );
  }
}
