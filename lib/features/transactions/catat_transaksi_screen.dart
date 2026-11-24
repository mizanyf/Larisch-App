import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/seed_data.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/account_selector_chips.dart';
import '../onboarding/onboarding_state.dart';

/// Screen 3 - Catat Transaksi (Create & Edit mode for Pemasukan / Pengeluaran).
class CatatTransaksiScreen extends ConsumerStatefulWidget {
  const CatatTransaksiScreen({
    super.key,
    this.initialType = TransactionTypes.income,
    this.editingTransaction,
  });

  final String initialType;
  final Transaction? editingTransaction;

  @override
  ConsumerState<CatatTransaksiScreen> createState() =>
      _CatatTransaksiScreenState();
}

class _CatatTransaksiScreenState extends ConsumerState<CatatTransaksiScreen> {
  late String _type;
  late String _selectedAccountId;
  int? _selectedCategoryId;
  late DateTime _selectedDate;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  final FocusNode _amountFocusNode = FocusNode();

  String? _amountError;
  bool _isSaving = false;

  bool get _isEditing => widget.editingTransaction != null;
  bool get _isIncome => _type == TransactionTypes.income;

  @override
  void initState() {
    super.initState();
    _amountFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    final editing = widget.editingTransaction;
    if (editing != null) {
      _type = editing.type;
      _selectedAccountId = editing.accountId;
      _selectedCategoryId = editing.categoryId;
      _selectedDate = editing.transactionDate;
      _amountController = TextEditingController(
        text: CurrencyFormatter.format(editing.amount, withSymbol: false),
      );
      _noteController = TextEditingController(text: editing.note ?? '');
    } else {
      _type =
          widget.initialType == TransactionTypes.income
          ? TransactionTypes.income
          : TransactionTypes.expense;
      _selectedAccountId = AccountIds.cash;
      _selectedDate = DateTime.now();
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _switchType(String nextType) {
    if (_type == nextType) return;
    setState(() {
      _type = nextType;
      _selectedCategoryId = null;
      _amountError = null;
    });
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (!mounted) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? _selectedDate.hour,
        pickedTime?.minute ?? _selectedDate.minute,
      );
    });
  }

  Future<void> _handleSave(List<Category> availableCategories) async {
    if (_isSaving) return;

    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0) {
      setState(() {
        _amountError = 'Masukkan nominal lebih dari Rp 0 sebelum menyimpan';
      });
      return;
    }

    final categoryId =
        _selectedCategoryId ??
        (availableCategories.isNotEmpty ? availableCategories.first.id : null);
    if (categoryId == null) return;

    setState(() {
      _amountError = null;
      _isSaving = true;
    });

    try {
      final repo = ref.read(financeRepositoryProvider);
      if (_isEditing) {
        await repo.updateTransaction(
          id: widget.editingTransaction!.id,
          type: _type,
          amount: amount,
          accountId: _selectedAccountId,
          categoryId: categoryId,
          note: _noteController.text,
          transactionDate: _selectedDate,
        );
      } else {
        await repo.addTransaction(
          type: _type,
          amount: amount,
          accountId: _selectedAccountId,
          categoryId: categoryId,
          note: _noteController.text,
          transactionDate: _selectedDate,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Perubahan transaksi berhasil disimpan'
                : _isIncome
                ? 'Pemasukan berhasil dicatat'
                : 'Pengeluaran berhasil dicatat',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(activeCategoriesByTypeProvider(_type));
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];

    final effectiveCategoryId =
        categories.any((c) => c.id == _selectedCategoryId)
        ? _selectedCategoryId
        : (categories.isNotEmpty ? categories.first.id : null);

    final screenTitle = _isEditing
        ? 'Edit Transaksi'
        : _isIncome
        ? 'Catat Pemasukan'
        : 'Catat Pengeluaran';

    final amountColor = _amountError != null
        ? const Color(0xFFFCA5A5)
        : AppColors.textOnDark;

    final submitColor = _isEditing
        ? AppColors.accentBlue
        : (_isIncome ? AppColors.incomeGreen : AppColors.expenseRed);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBase,
        body: Column(
          children: [
            // Dark Top Header + Type Toggle + Large Amount Input
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textOnDarkMuted,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 36),
                          ),
                          child: const Text('Batal'),
                        ),
                        Expanded(
                          child: Text(
                            screenTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.sectionHeading(
                              color: AppColors.textOnDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Segmented Type Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: AppRadius.buttonBorder,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TypeSegmentButton(
                              label: 'Pemasukan',
                              isSelected: _isIncome,
                              activeColor: AppColors.incomeGreen,
                              onTap: () => _switchType(TransactionTypes.income),
                            ),
                          ),
                          Expanded(
                            child: _TypeSegmentButton(
                              label: 'Pengeluaran',
                              isSelected: !_isIncome,
                              activeColor: AppColors.expenseRed,
                              onTap: () =>
                                  _switchType(TransactionTypes.expense),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _isIncome ? 'Nominal Pemasukan' : 'Nominal Pengeluaran',
                      style: AppTypography.caption(
                        color: AppColors.textOnDarkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => _amountFocusNode.requestFocus(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: AppRadius.cardBorder,
                          border: Border.all(
                            color: _amountError != null
                                ? AppColors.expenseRedLight
                                : _amountFocusNode.hasFocus
                                ? (_isIncome
                                      ? AppColors.incomeGreenLight
                                      : AppColors.expenseRedLight)
                                : AppColors.darkBorder,
                            width: _amountFocusNode.hasFocus ||
                                    _amountError != null
                                ? 1.5
                                : 1.0,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Rp ',
                                style: AppTypography.headlineLarge(
                                  color: amountColor,
                                ),
                              ),
                              IntrinsicWidth(
                                child: TextField(
                                  key: const Key('amount_field'),
                                  controller: _amountController,
                                  focusNode: _amountFocusNode,
                                  autofocus: !_isEditing,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  cursorColor: _isIncome
                                      ? AppColors.incomeGreenLight
                                      : AppColors.expenseRedLight,
                                  cursorWidth: 2.5,
                                  inputFormatters: [
                                    ThousandsRupiahInputFormatter(
                                      maxDigits: 12,
                                      onMaxDigitsExceeded: () {
                                        setState(() {
                                          _amountError =
                                              'Maksimal nominal adalah 12 digit (Rp 999.999.999.999)';
                                        });
                                      },
                                    ),
                                  ],
                                  onChanged: (_) {
                                    if (_amountError != null) {
                                      setState(() => _amountError = null);
                                    }
                                  },
                                  style: AppTypography.displayBalance(
                                    color: amountColor,
                                  ).copyWith(fontSize: 32),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: AppTypography.displayBalance(
                                      color: amountColor.withValues(alpha: 0.45),
                                    ).copyWith(fontSize: 32),
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (_amountError == null)
                      Text(
                        'Ketuk kolom di atas untuk mengisi nominal',
                        style: AppTypography.labelSmall(
                          color: AppColors.textOnDarkSubtle,
                        ),
                      ),
                    if (_amountError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1215),
                          borderRadius: AppRadius.smBorder,
                          border: Border.all(
                            color: AppColors.expenseRed.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          _amountError!,
                          textAlign: TextAlign.center,
                          style: AppTypography.captionMedium(
                            color: const Color(0xFFFCA5A5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Clean White Form Body
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: AppRadius.sheetTopBorder,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Akun Pembayaran',
                              style: AppTypography.bodyMedium(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AccountSelectorChips(
                              selectedAccountId: _selectedAccountId,
                              onSelected: (id) {
                                setState(() => _selectedAccountId = id);
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text('Kategori', style: AppTypography.bodyMedium()),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: categories.map((cat) {
                                final isSelected =
                                    cat.id == effectiveCategoryId;
                                return ChoiceChip(
                                  label: Text(cat.name),
                                  selected: isSelected,
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    setState(
                                      () => _selectedCategoryId = cat.id,
                                    );
                                  },
                                  selectedColor: AppColors.darkBase,
                                  backgroundColor: AppColors.surfaceMuted,
                                  labelStyle: AppTypography.captionMedium(
                                    color: isSelected
                                        ? AppColors.textOnDark
                                        : AppColors.textPrimary,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.darkBase
                                        : AppColors.borderLight,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.smBorder,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              'Tanggal & Waktu',
                              style: AppTypography.bodyMedium(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            InkWell(
                              onTap: _pickDateTime,
                              borderRadius: AppRadius.buttonBorder,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: AppRadius.buttonBorder,
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${AppDateFormatter.shortDate(_selectedDate)}, ${AppDateFormatter.time24(_selectedDate)}',
                                      style: AppTypography.bodyMedium(),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              'Catatan (Opsional)',
                              style: AppTypography.bodyMedium(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              key: const Key('note_field'),
                              controller: _noteController,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: _isIncome
                                    ? 'Contoh: Penjualan kedai pagi'
                                    : 'Contoh: Beli biji kopi & susu segar',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: FilledButton(
                        key: const Key('save_transaction_button'),
                        onPressed: _isSaving
                            ? null
                            : () => _handleSave(categories),
                        style: FilledButton.styleFrom(
                          backgroundColor: submitColor,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnDark,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Simpan Perubahan'
                                    : _isIncome
                                    ? 'Simpan Pemasukan'
                                    : 'Simpan Pengeluaran',
                              ),
                      ),
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

class _TypeSegmentButton extends StatelessWidget {
  const _TypeSegmentButton({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: AppRadius.smBorder,
        ),
        child: Text(
          label,
          style: AppTypography.captionMedium(
            color: isSelected
                ? AppColors.textOnDark
                : AppColors.textOnDarkMuted,
          ),
        ),
      ),
    );
  }
}
