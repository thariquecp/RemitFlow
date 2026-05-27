import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintech_app/core/theme/app_colors.dart';

class SwapButton extends StatefulWidget {
  final VoidCallback onSwap;

  const SwapButton({super.key, required this.onSwap});

  @override
  State<SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<SwapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  double _totalTurns = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  void _handleSwap() {
    //haptic feedback
    HapticFeedback.mediumImpact();
    _totalTurns += 0.5;
    _controller.forward(from: 0);
    widget.onSwap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleSwap,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, child) {
          return Transform.rotate(
            angle: (_totalTurns - 0.5 + _rotation.value) * 2 * 3.14159,
            child: child,
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.swap_vert_rounded,
            color: isDark ? AppColors.darkBg : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
