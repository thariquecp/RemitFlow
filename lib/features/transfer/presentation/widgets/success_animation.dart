import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';

class SuccessAnimation extends StatelessWidget {
  final String amount;
  final String currency;
  final String recipientName;
  final VoidCallback onDone;

  const SuccessAnimation({
    super.key,
    required this.amount,
    required this.currency,
    required this.recipientName,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated checkmark circle
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .shimmer(duration: 1000.ms),

          const SizedBox(height: AppTheme.spacing32),

          // "Transfer Sent!" text
          Text(
                'Transfer Sent!',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppTheme.spacing12),

          // Amount
          Text(
                '$amount $currency',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppTheme.spacing8),

          Text(
            'sent to $recipientName',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

          const SizedBox(height: AppTheme.spacing48),

          // Done button
          SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onDone,
                  child: const Text('Done'),
                ),
              )
              .animate()
              .fadeIn(delay: 800.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
