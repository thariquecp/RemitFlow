enum FeeType { flat, percentage }

class FeeTier {
  final double? maxAmount;
  final FeeType type;
  final double value;

  const FeeTier({
    required this.maxAmount,
    required this.type,
    required this.value,
  });
}

const List<FeeTier> feeTiers = [
  FeeTier(maxAmount: 100, type: FeeType.flat, value: 2.5),
  FeeTier(maxAmount: 1000, type: FeeType.percentage, value: 1.5),
  FeeTier(maxAmount: null, type: FeeType.percentage, value: 0.8),
];
const Duration rateExpiryDuration = Duration(seconds: 30);

const int transactionsPageSize = 20;

const double weekendSurchargePercent = 1.0;

const double sameCurrencyFlatFee = 1.0;

const int currencyDecimalPlaces = 2;

const int rateDecimalPlaces = 4;
