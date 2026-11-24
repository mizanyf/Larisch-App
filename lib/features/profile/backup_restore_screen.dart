import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/local_backup_service.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/date_formatter.dart';

/// Local-only JSON Backup & Restore screen (zero cloud dependencies).
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isBusy = false;

  Future<void> _handleExport() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final fileName = await ref
          .read(localBackupServiceProvider)
          .exportAndShareFile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File backup lokal dibuat: $fileName'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat backup lokal: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleImport() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty || !mounted) return;

      final file = picked.files.single;
      String content;
      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        throw const FormatException('File tidak dapat dibaca.');
      }

      final service = ref.read(localBackupServiceProvider);
      final preview = service.parseAndValidate(content);

      if (!mounted) return;
      final confirmed = await _showRestoreConfirmDialog(preview);
      if (confirmed != true || !mounted) return;

      await service.restoreFromJsonString(content);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data ${preview.businessName} (${preview.transactionCount} transaksi) berhasil dipulihkan',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulihkan backup: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<bool?> _showRestoreConfirmDialog(BackupPreview preview) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text(
            'Pulihkan Data Backup?',
            style: AppTypography.sectionHeading(),
          ),
          content: Text(
            'Usaha: ${preview.businessName}\n'
            'Tanggal Backup: ${AppDateFormatter.shortDate(preview.exportedAt)}\n'
            'Transaksi: ${preview.transactionCount} data\n\n'
            'Seluruh data lokal saat ini akan diganti dengan isi file backup ini.',
            style: AppTypography.bodyRegular(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(minimumSize: const Size(110, 40)),
              child: const Text('Pulihkan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Backup & Restore Lokal',
          style: AppTypography.sectionHeading(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                color: AppColors.darkBase,
                borderRadius: AppRadius.cardBorder,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.incomeGreenLight,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Penyimpanan Lokal (Tanpa Cloud)',
                          style: AppTypography.bodyMedium(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Semua file backup berbentuk .json dan disimpan langsung di perangkatmu. Tidak ada data yang dikirim ke server.',
                          style: AppTypography.caption(
                            color: AppColors.textOnDarkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ActionCard(
              icon: Icons.upload_file_outlined,
              title: 'Export Backup Lokal (.json)',
              description:
                  'Simpan seluruh profil usaha, saldo awal, kategori, dan riwayat transaksi ke satu file JSON.',
              buttonLabel: 'Buat File Backup',
              isPrimary: true,
              onPressed: _isBusy ? null : _handleExport,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ActionCard(
              icon: Icons.download_for_offline_outlined,
              title: 'Restore dari File Lokal (.json)',
              description:
                  'Pilih file backup resmi Larisch untuk memulihkan catatan keuanganmu secara utuh.',
              buttonLabel: 'Pilih File Backup',
              isPrimary: false,
              onPressed: _isBusy ? null : _handleImport,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.isPrimary,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final bool isPrimary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title, style: AppTypography.sectionHeading()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: AppTypography.bodyRegular()),
          const SizedBox(height: AppSpacing.lg),
          if (isPrimary)
            FilledButton(onPressed: onPressed, child: Text(buttonLabel))
          else
            OutlinedButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}
