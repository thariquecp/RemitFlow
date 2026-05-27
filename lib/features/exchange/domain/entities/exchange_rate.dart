import 'package:equatable/equatable.dart';

class ExchangeRate extends Equatable {
  final String baseCurrency;
  final String quoteCurrency;
  final double rate;
  final DateTime timestamp;

  const ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.timestamp,
  });

  bool isExpired(Duration expiryDuration) {
    return DateTime.now().difference(timestamp) > expiryDuration;
  }

  int get ageInSeconds => DateTime.now().difference(timestamp).inSeconds;

  ExchangeRate copyWith({
    String? baseCurrency,
    String? quoteCurrency,
    double? rate,
    DateTime? timestamp,
  }) {
    return ExchangeRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      rate: rate ?? this.rate,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [baseCurrency, quoteCurrency, rate, timestamp];

  @override
  String toString() =>
      'ExchangeRate($baseCurrency/$quoteCurrency: $rate @ $timestamp)';
}
