import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/core/widgets/glassmorphic_card.dart';
import 'package:fintech_app/core/widgets/animated_counter.dart';
import 'package:fintech_app/core/utils/date_formatter.dart';
import 'package:fintech_app/features/exchange/domain/entities/exchange_rate.dart';

/// Premium glassmorphic rate display card with pulse animation.
///
/// Shows the current exchange rate with a subtle pulse indicator
/// when rates are live, and a warning state when rates are stale.
class RateCard extends StatelessWidget {
  final ExchangeRate? rate;
  final bool isStale;
  final DateTime? lastUpdated;
  final VoidCallback? onRefresh;

  const RateCard({
    super.key,
    required this.rate,
    this.isStale = false,
    this.lastUpdated,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _PulseIndicator(isLive: !isStale),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    isStale ? 'Rate Expired' : 'Live Rate',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isStale
                          ? AppColors.warning
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (onRefresh != null)
                _RefreshButton(
                  onPressed: onRefresh!,
                  isStale: isStale,
                ),
            ],
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Rate display
          if (rate != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '1 ${rate!.baseCurrency} = ',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                AnimatedCounter(
                  value: rate!.rate,
                  decimalPlaces: rate!.rate >= 100 ? 2 : 4,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  rate!.quoteCurrency,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppTheme.spacing12),

          // Last updated timestamp
          if (lastUpdated != null)
            Text(
              'Updated ${DateFormatter.timeAgo(lastUpdated!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isStale
                    ? AppColors.warning.withValues(alpha: 0.8)
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }
}

/// Pulsing green dot indicating live rate feed.
class _PulseIndicator extends StatelessWidget {
  final bool isLive;

  const _PulseIndicator({required this.isLive});

  @override
  Widget build(BuildContext context) {
    final color = isLive ? AppColors.success : AppColors.warning;

    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          if (isLive)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(2, 2),
                  duration: 1500.ms,
                )
                .fadeOut(duration: 1500.ms),
        ],
      ),
    );
  }
}

/// Refresh button with rotation animation.
class _RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isStale;

  const _RefreshButton({
    required this.onPressed,
    required this.isStale,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.refresh_rounded,
        size: 20,
        color: isStale ? AppColors.warning : AppColors.primary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: (isStale ? AppColors.warning : AppColors.primary)
            .withValues(alpha: 0.1),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
    );
  }
}
