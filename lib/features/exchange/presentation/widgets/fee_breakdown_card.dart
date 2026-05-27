import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/core/utils/currency_formatter.dart';
import 'package:fintech_app/features/exchange/domain/entities/fee_breakdown.dart';

class FeeBreakdownCard extends StatefulWidget {
  final FeeBreakdown? breakdown;

  const FeeBreakdownCard({super.key, required this.breakdown});

  @override
  State<FeeBreakdownCard> createState() => _FeeBreakdownCardState();
}

class _FeeBreakdownCardState extends State<FeeBreakdownCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final breakdown = widget.breakdown;

    if (breakdown == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Collapsed header — always visible
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text('Transfer fee', style: theme.textTheme.titleSmall),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${breakdown.totalFee.toStringAsFixed(2)} ${breakdown.sendCurrency}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded detail rows
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacing16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: AppTheme.spacing12),
                  _FeeRow(
                    label: 'Base fee',
                    value:
                        '${breakdown.baseFee.toStringAsFixed(2)} ${breakdown.sendCurrency}',
                    theme: theme,
                  ),
                  if (breakdown.hasWeekendSurcharge) ...[
                    const SizedBox(height: AppTheme.spacing8),
                    _FeeRow(
                      label: 'Weekend surcharge',
                      value:
                          '${breakdown.weekendSurcharge.toStringAsFixed(2)} ${breakdown.sendCurrency}',
                      theme: theme,
                      isHighlighted: true,
                    ),
                  ],
                  const SizedBox(height: AppTheme.spacing8),
                  _FeeRow(
                    label: 'Exchange rate',
                    value:
                        '1 ${breakdown.sendCurrency} = ${CurrencyFormatter.formatRate(breakdown.exchangeRate)} ${breakdown.receiveCurrency}',
                    theme: theme,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacing12),
                  _FeeRow(
                    label: 'Total you pay',
                    value:
                        '${breakdown.totalPayable.toStringAsFixed(2)} ${breakdown.sendCurrency}',
                    theme: theme,
                    isBold: true,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  _FeeRow(
                    label: 'Recipient gets',
                    value:
                        '${breakdown.recipientGets.toStringAsFixed(2)} ${breakdown.receiveCurrency}',
                    theme: theme,
                    isBold: true,
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.03, end: 0, duration: 300.ms);
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isBold;
  final bool isHighlighted;
  final Color? valueColor;

  const _FeeRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isBold = false,
    this.isHighlighted = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              (isBold ? theme.textTheme.titleSmall : theme.textTheme.bodySmall)
                  ?.copyWith(color: isHighlighted ? AppColors.warning : null),
        ),
        Text(
          value,
          style:
              (isBold ? theme.textTheme.titleMedium : theme.textTheme.bodySmall)
                  ?.copyWith(
                    color:
                        valueColor ??
                        (isHighlighted ? AppColors.warning : null),
                  ),
        ),
      ],
    );
  }
}
