import 'package:fintech_app/core/constants/app_constants.dart';

class FeeCalculator {
  FeeCalculator._();

  static FeeResult calculate({
    required double amount,
    required bool isSameCurrency,
    bool? isWeekend,
  }) {
    final weekend = isWeekend ?? _isCurrentlyWeekend();

    if (isSameCurrency) {
      return const FeeResult(
        baseFee: sameCurrencyFlatFee,
        weekendSurcharge: 0,
        totalFee: sameCurrencyFlatFee,
      );
    }

    double baseFee = 0;
    for (final tier in feeTiers) {
      final withinTier = tier.maxAmount == null || amount < tier.maxAmount!;
      if (withinTier) {
        baseFee = switch (tier.type) {
          FeeType.flat => tier.value,
          FeeType.percentage => _roundCurrency(amount * tier.value / 100),
        };
        break;
      }
    }

    // Weekend surcharge
    double surcharge = 0;
    if (weekend) {
      surcharge = _roundCurrency(amount * weekendSurchargePercent / 100);
    }

    final totalFee = _roundCurrency(baseFee + surcharge);

    return FeeResult(
      baseFee: baseFee,
      weekendSurcharge: surcharge,
      totalFee: totalFee,
    );
  }

  static double _roundCurrency(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  static bool _isCurrentlyWeekend() {
    final weekday = DateTime.now().weekday;
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }
}

class FeeResult {
  final double baseFee;
  final double weekendSurcharge;
  final double totalFee;

  const FeeResult({
    required this.baseFee,
    required this.weekendSurcharge,
    required this.totalFee,
  });

  @override
  String toString() =>
      'FeeResult(base: $baseFee, weekend: $weekendSurcharge, total: $totalFee)';
}
