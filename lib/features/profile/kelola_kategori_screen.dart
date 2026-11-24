import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/seed_data.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/theme/theme.dart';

/// Manage custom and default income/expense categories.
class KelolaKategoriScreen extends ConsumerStatefulWidget {
  const KelolaKategoriScreen({super.key});

  @override
  ConsumerState<KelolaKategoriScreen> createState() =>
      _KelolaKategoriScreenState();
}

class _KelolaKategoriScreenState extends ConsumerState<KelolaKategoriScreen> {
  String _selectedType = TransactionTypes.expense;

  Future<void> _showCategoryDialog({Category? existing}) async {
    final controller = TextEditingController(text: existing?.name ?? '');
    final isEdit = existing != null;

    final savedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text(
            isEdit ? 'Edit Kategori' : 'Tambah Kategori',
            style: AppTypography.sectionHeading(),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Contoh: Biaya Iklan',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(dialogContext).pop(text);
                }
              },
              style: FilledButton.styleFrom(minimumSize: const Size(96, 40)),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (savedName == null || !mounted) return;

    final repo = ref.read(financeRepositoryProvider);
    if (isEdit) {
      await repo.updateCategory(id: existing.id, name: savedName);
    } else {
      await repo.addCategory(name: savedName, type: _selectedType);
    }
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardBorder,
          ),
          title: Text('Hapus Kategori?', style: AppTypography.sectionHeading()),
          content: Text(
            'Kategori "${category.name}" akan dihapus dari daftar pilihan. Riwayat transaksi lama yang memakai kategori ini tetap aman.',
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

    if (confirmed != true || !mounted) return;
    await ref
        .read(financeRepositoryProvider)
        .deleteOrArchiveCategory(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(
      activeCategoriesByTypeProvider(_selectedType),
    );
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Kategori', style: AppTypography.sectionHeading()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showCategoryDialog(),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Kategori',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: AppRadius.buttonBorder,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _CatTab(
                      label: 'Pengeluaran',
                      isSelected: _selectedType == TransactionTypes.expense,
                      onTap: () => setState(
                        () => _selectedType = TransactionTypes.expense,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _CatTab(
                      label: 'Pemasukan',
                      isSelected: _selectedType == TransactionTypes.income,
                      onTap: () => setState(
                        () => _selectedType = TransactionTypes.income,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(cat.name, style: AppTypography.bodyMedium()),
                  subtitle: Text(
                    cat.isDefault ? 'Kategori bawaan' : 'Kategori kustom',
                    style: AppTypography.caption(),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => _showCategoryDialog(existing: cat),
                      ),
                      if (!cat.isDefault)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: AppColors.expenseRed,
                          ),
                          onPressed: () => _confirmDelete(cat),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatTab extends StatelessWidget {
  const _CatTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceWhite : Colors.transparent,
          borderRadius: AppRadius.smBorder,
        ),
        child: Text(
          label,
          style: AppTypography.captionMedium(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
