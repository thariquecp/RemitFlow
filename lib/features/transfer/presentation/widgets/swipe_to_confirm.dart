import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintech_app/core/theme/app_colors.dart';

/// Swipe-to-confirm slider with progressive fill and haptic snap.
///
/// Provides a physical-feeling confirmation gesture for transfers,
/// preventing accidental taps on a standard button.
class SwipeToConfirm extends StatefulWidget {
  final VoidCallback onConfirmed;
  final String label;

  const SwipeToConfirm({
    super.key,
    required this.onConfirmed,
    this.label = 'Swipe to confirm',
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _confirmed = false;
  late AnimationController _resetController;

  static const double _thumbSize = 56;
  static const double _trackHeight = 64;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - _thumbSize - 8;

        return Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_trackHeight / 2),
            color: AppColors.darkElevated,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Stack(
            children: [
              // Progressive fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                width: _dragPosition + _thumbSize + 8,
                height: _trackHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_trackHeight / 2),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(
                        alpha: 0.05 + (_dragPosition / maxDrag) * 0.3,
                      ),
                    ],
                  ),
                ),
              ),

              // Label
              Center(
                child: AnimatedOpacity(
                  opacity: _confirmed ? 0 : 1 - (_dragPosition / maxDrag * 0.7),
                  duration: const Duration(milliseconds: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.textSecondaryDark,
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable thumb
              Positioned(
                left: 4 + _dragPosition,
                top: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_confirmed) return;
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(
                        0,
                        maxDrag,
                      );
                    });

                    // Light haptic at midpoint
                    if ((_dragPosition / maxDrag - 0.5).abs() < 0.02) {
                      HapticFeedback.selectionClick();
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_confirmed) return;

                    if (_dragPosition / maxDrag > 0.85) {
                      // Confirmed!
                      setState(() {
                        _confirmed = true;
                        _dragPosition = maxDrag;
                      });
                      HapticFeedback.heavyImpact();
                      widget.onConfirmed();
                    } else {
                      // Spring back
                      HapticFeedback.lightImpact();
                      _animateReset(maxDrag);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _confirmed
                          ? const LinearGradient(
                              colors: [AppColors.success, AppColors.success],
                            )
                          : AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _confirmed
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _animateReset(double maxDrag) {
    final startPosition = _dragPosition;
    _resetController.reset();
    _resetController.addListener(() {
      setState(() {
        _dragPosition = startPosition * (1 - _resetController.value);
      });
    });
    _resetController.forward();
  }
}
