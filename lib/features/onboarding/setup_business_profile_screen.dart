import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/theme.dart';
import 'onboarding_state.dart';

/// 02 - Setup Profil Usaha (Step 1 of 2).
class SetupBusinessProfileScreen extends ConsumerStatefulWidget {
  const SetupBusinessProfileScreen({super.key});

  @override
  ConsumerState<SetupBusinessProfileScreen> createState() =>
      _SetupBusinessProfileScreenState();
}

class _SetupBusinessProfileScreenState
    extends ConsumerState<SetupBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedType;

  static const List<String> _businessTypes = [
    'Kuliner & Minuman',
    'Toko & Retail',
    'Jasa',
    'Fashion',
    'Warung / Kelontong',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingDraftProvider);
    _nameController = TextEditingController(text: draft.businessName);
    _selectedType = _businessTypes.contains(draft.businessType)
        ? draft.businessType
        : _businessTypes.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(onboardingDraftProvider.notifier)
        .setProfile(
          businessName: _nameController.text.trim(),
          businessType: _selectedType,
        );
    context.push(AppRoutes.setupBalances);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Langkah 1 dari 2', style: AppTypography.captionMedium()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 4,
                borderRadius: AppRadius.pillBorder,
                backgroundColor: AppColors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation(AppColors.accentBlue),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Kenalkan Usahamu',
                        style: AppTypography.headlineLarge(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Nama usaha akan tampil di Beranda dan file backup lokalmu.',
                        style: AppTypography.bodyRegular(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text('Nama Usaha', style: AppTypography.bodyMedium()),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Kedai Kopi Budi',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Masukkan nama usaha terlebih dahulu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text('Jenis Usaha', style: AppTypography.bodyMedium()),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _businessTypes.map((type) {
                          final isSelected = type == _selectedType;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (_) {
                              setState(() => _selectedType = type);
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
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: FilledButton(
                onPressed: _handleNext,
                child: const Text('Lanjut ke Saldo Awal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
