import 'package:equatable/equatable.dart';

class FeeBreakdown extends Equatable {
  final double sendAmount;
  final double baseFee;
  final double weekendSurcharge;
  final double totalFee;
  final double totalPayable;
  final double exchangeRate;
  final double recipientGets;
  final String sendCurrency;
  final String receiveCurrency;

  const FeeBreakdown({
    required this.sendAmount,
    required this.baseFee,
    required this.weekendSurcharge,
    required this.totalFee,
    required this.totalPayable,
    required this.exchangeRate,
    required this.recipientGets,
    required this.sendCurrency,
    required this.receiveCurrency,
  });

  /// Whether a weekend surcharge was applied.
  bool get hasWeekendSurcharge => weekendSurcharge > 0;

  @override
  List<Object?> get props => [
    sendAmount,
    baseFee,
    weekendSurcharge,
    totalFee,
    totalPayable,
    exchangeRate,
    recipientGets,
    sendCurrency,
    receiveCurrency,
  ];
}
