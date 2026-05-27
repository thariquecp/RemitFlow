import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/core/utils/currency_formatter.dart';
import 'package:fintech_app/core/utils/masking_utils.dart';
import 'package:fintech_app/features/beneficiary/domain/entities/beneficiary.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_state.dart';
import 'package:fintech_app/features/transactions/domain/entities/transaction.dart';
import 'package:fintech_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:fintech_app/features/transfer/presentation/widgets/swipe_to_confirm.dart';
import 'package:fintech_app/features/transfer/presentation/widgets/success_animation.dart';

/// Draggable bottom sheet for transfer review and confirmation.
///
/// Flow: Review details → Swipe to confirm → Success animation
class TransferReviewSheet extends StatefulWidget {
  final Beneficiary beneficiary;

  const TransferReviewSheet({super.key, required this.beneficiary});

  @override
  State<TransferReviewSheet> createState() => _TransferReviewSheetState();
}

class _TransferReviewSheetState extends State<TransferReviewSheet> {
  bool _isConfirmed = false;

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
        if (_isConfirmed) {
          return BlocBuilder<ExchangeBloc, ExchangeState>(
            builder: (context, state) {
              return SuccessAnimation(
                amount:
                    state.feeBreakdown?.recipientGets.toStringAsFixed(2) ?? '0',
                currency: state.receiveCurrency.code,
                recipientName: widget.beneficiary.nickname.isNotEmpty
                    ? widget.beneficiary.nickname
                    : widget.beneficiary.fullName,
                onDone: () => Navigator.pop(context),
              );
            },
          );
        }

        return BlocBuilder<ExchangeBloc, ExchangeState>(
          builder: (context, state) {
            final breakdown = state.feeBreakdown;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXLarge),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppTheme.spacing24),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    'Review Transfer',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Recipient Profile Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.beneficiary.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.beneficiary.nickname.isNotEmpty
                                ? widget.beneficiary.nickname
                                : widget.beneficiary.fullName,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.beneficiary.bankName} • ${MaskingUtils.maskAccount(widget.beneficiary.accountNumber)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Amount summary card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.cardGradient : null,
                      color: isDark ? null : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'You send',
                          value:
                              '${breakdown?.sendAmount.toStringAsFixed(2) ?? '0'} ${state.sendCurrency.code}',
                          valueStyle: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing12,
                              ),
                              child: Icon(
                                Icons.arrow_downward_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        _DetailRow(
                          label: 'Recipient gets',
                          value:
                              '${breakdown?.recipientGets.toStringAsFixed(2) ?? '0'} ${state.receiveCurrency.code}',
                          valueStyle: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing20),

                  // Details
                  _DetailRow(
                    label: 'Exchange rate',
                    value:
                        '1 ${state.sendCurrency.code} = ${CurrencyFormatter.formatRate(breakdown?.exchangeRate ?? 0)} ${state.receiveCurrency.code}',
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _DetailRow(
                    label: 'Transfer fee',
                    value:
                        '${breakdown?.totalFee.toStringAsFixed(2) ?? '0'} ${state.sendCurrency.code}',
                  ),
                  if (breakdown?.hasWeekendSurcharge ?? false) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    _DetailRow(
                      label: 'Weekend surcharge',
                      value:
                          '${breakdown!.weekendSurcharge.toStringAsFixed(2)} ${state.sendCurrency.code}',
                      valueColor: AppColors.warning,
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacing12),
                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  _DetailRow(
                    label: 'Total payable',
                    value:
                        '${breakdown?.totalPayable.toStringAsFixed(2) ?? '0'} ${state.sendCurrency.code}',
                    valueStyle: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing32),

                  // Swipe to confirm
                  SwipeToConfirm(
                    onConfirmed: () {
                      if (breakdown != null) {
                        final tx = Transaction(
                          id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
                          recipientName: widget.beneficiary.nickname.isNotEmpty
                              ? widget.beneficiary.nickname
                              : widget.beneficiary.fullName,
                          recipientAccount: widget.beneficiary.accountNumber,
                          sendAmount: breakdown.sendAmount,
                          sendCurrency: state.sendCurrency.code,
                          receiveAmount: breakdown.recipientGets,
                          receiveCurrency: state.receiveCurrency.code,
                          exchangeRate: breakdown.exchangeRate,
                          fee: breakdown.totalFee,
                          status: TransactionStatus.completed,
                          createdAt: DateTime.now(),
                          referenceNote:
                              'Transfer to ${widget.beneficiary.fullName}',
                        );
                        context.read<TransactionBloc>().add(
                          TransactionAdded(tx),
                        );
                      }
                      setState(() => _isConfirmed = true);
                    },
                  ),

                  const SizedBox(height: AppTheme.spacing16),

                  // Cancel
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: AppTheme.spacing8),
        Text(
          value,
          style: (valueStyle ?? theme.textTheme.titleSmall)?.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
