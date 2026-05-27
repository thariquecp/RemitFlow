import 'package:flutter/material.dart';

/// Used for exchange rates and amounts

class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 2,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        final formatted = animatedValue.toStringAsFixed(decimalPlaces);
        return Text(
          '$prefix$formatted$suffix',
          style: style ?? Theme.of(context).textTheme.displayMedium,
        );
      },
    );
  }
}
