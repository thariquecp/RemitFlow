import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/exchange/domain/entities/currency.dart';

class CurrencyInputTile extends StatelessWidget {
  final Currency currency;
  final String amount;
  final String label;
  final bool isEditing;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onCurrencyTap;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  const CurrencyInputTile({
    super.key,
    required this.currency,
    required this.amount,
    required this.label,
    required this.onAmountChanged,
    required this.onCurrencyTap,
    this.onTap,
    this.isEditing = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.lightBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isEditing
              ? AppColors.primary.withValues(alpha: 0.5)
              : isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),

          // Currency selector + amount input
          Row(
            children: [
              // Currency selector button
              GestureDetector(
                onTap: onCurrencyTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: AppTheme.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currency.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(currency.code, style: theme.textTheme.titleMedium),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppTheme.spacing12),

              // Amount input
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onAmountChanged,
                  onTap: onTap,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  textAlign: TextAlign.right,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.00',
                    hintStyle: theme.textTheme.displaySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
