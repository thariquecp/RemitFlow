import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';

/// Skeleton loading placeholder with shimmer animation.
///
/// Provides a polished loading experience instead of spinners.
/// Use [ShimmerBox] for individual placeholders or [ShimmerLoading]
/// for a full-card skeleton.
class ShimmerLoading extends StatelessWidget {
  final int itemCount;

  const ShimmerLoading({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkElevated : const Color(0xFFE8ECF2),
      highlightColor: isDark ? AppColors.darkBorder : const Color(0xFFF5F7FA),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacing12),
        itemBuilder: (_, _) => const _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 40, height: 40, isCircle: true),
              SizedBox(width: AppTheme.spacing12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120, height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: 80, height: 10),
                ],
              ),
              Spacer(),
              ShimmerBox(width: 60, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single rectangular shimmer placeholder.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircle;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(6),
      ),
    );
  }
}
