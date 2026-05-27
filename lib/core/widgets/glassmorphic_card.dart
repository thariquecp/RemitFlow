import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double blurAmount;
  final bool showGradientBorder;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurAmount = 10,
    this.showGradientBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppTheme.radiusLarge;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: showGradientBorder
              ? LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.glassBorder,
                          AppColors.glassBorder.withValues(alpha: 0.05),
                        ]
                      : [
                          AppColors.glassBorderLight,
                          AppColors.glassBorderLight.withValues(alpha: 0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - 1),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
              child: Container(
                padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard.withValues(alpha: 0.8)
                      : AppColors.lightCard.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(radius - 1),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
