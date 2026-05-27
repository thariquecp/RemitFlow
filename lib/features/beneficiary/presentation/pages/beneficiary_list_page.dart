import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/core/utils/masking_utils.dart';
import 'package:fintech_app/features/beneficiary/domain/entities/beneficiary.dart';
import 'package:fintech_app/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:fintech_app/features/beneficiary/presentation/pages/add_beneficiary_page.dart';

class BeneficiaryListPage extends StatelessWidget {
  const BeneficiaryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Beneficiaries', style: theme.textTheme.headlineMedium),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddBeneficiary(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Add New'),
      ),
      body: BlocBuilder<BeneficiaryBloc, BeneficiaryState>(
        builder: (context, state) {
          if (state.status == BeneficiaryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.beneficiaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  Text(
                    'No beneficiaries yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Add someone to get started',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: state.beneficiaries.length,
            itemBuilder: (context, index) {
              final beneficiary = state.beneficiaries[index];
              return _BeneficiaryTile(beneficiary: beneficiary)
                  .animate()
                  .fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: (50 * index).clamp(0, 500)),
                  )
                  .slideX(begin: 0.05, end: 0, duration: 300.ms);
            },
          );
        },
      ),
    );
  }

  void _openAddBeneficiary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BeneficiaryBloc>(),
          child: const AddBeneficiaryPage(),
        ),
      ),
    );
  }
}

class _BeneficiaryTile extends StatelessWidget {
  final Beneficiary beneficiary;

  const _BeneficiaryTile({required this.beneficiary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Initials avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Center(
              child: Text(
                beneficiary.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spacing12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        beneficiary.nickname.isNotEmpty
                            ? beneficiary.nickname
                            : beneficiary.fullName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (beneficiary.hasRecentTransfer) ...[
                      const SizedBox(width: AppTheme.spacing8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Recent',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${beneficiary.bankName} • ${MaskingUtils.maskAccount(beneficiary.accountNumber)}',
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Country flag
          Text(beneficiary.countryFlag, style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
