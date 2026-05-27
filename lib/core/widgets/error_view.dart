import 'package:flutter/material.dart';
import 'package:fintech_app/core/theme/app_theme.dart';

/// A retry-able error display widget.
///
/// Shows an icon, message, and optional retry button for graceful
/// handling of network errors, timeouts, and parse failures.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 56,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing24,
                    vertical: AppTheme.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
