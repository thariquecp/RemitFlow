import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/core/utils/masking_utils.dart';
import 'package:fintech_app/features/beneficiary/domain/entities/beneficiary.dart';
import 'package:fintech_app/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:fintech_app/features/beneficiary/presentation/pages/add_beneficiary_page.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:fintech_app/features/transfer/presentation/widgets/transfer_review_sheet.dart';

class BeneficiarySelectionSheet extends StatelessWidget {
  const BeneficiarySelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXLarge),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: AppTheme.spacing24,
                    bottom: AppTheme.spacing20,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Add Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Recipient',
                      style: theme.textTheme.headlineMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        // Pop the sheet and navigate to AddBeneficiaryPage
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<BeneficiaryBloc>(),
                              child: const AddBeneficiaryPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_rounded),
                      color: AppColors.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Beneficiary List
              Expanded(
                child: BlocBuilder<BeneficiaryBloc, BeneficiaryState>(
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
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: AppTheme.spacing16),
                            Text(
                              'No beneficiaries yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppTheme.spacing8),
                            Text(
                              'Add someone to send money',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                      itemCount: state.beneficiaries.length,
                      itemBuilder: (context, index) {
                        final beneficiary = state.beneficiaries[index];
                        return _SelectionTile(
                          beneficiary: beneficiary,
                          onTap: () {
                            // Close this sheet and open Transfer Review Sheet
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => BlocProvider.value(
                                value: context.read<ExchangeBloc>(),
                                child: TransferReviewSheet(
                                  beneficiary: beneficiary,
                                ),
                              ),
                            );
                          },
                        )
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final Beneficiary beneficiary;
  final VoidCallback onTap;

  const _SelectionTile({required this.beneficiary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
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

            const SizedBox(width: AppTheme.spacing8),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}
