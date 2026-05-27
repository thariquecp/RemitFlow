import 'package:fintech_app/features/exchange/domain/entities/exchange_rate.dart';

class RateResponse {
  final String base;
  final String quote;
  final String date;
  final double rate;

  const RateResponse({
    required this.base,
    required this.quote,
    required this.date,
    required this.rate,
  });

  factory RateResponse.fromJson(Map<String, dynamic> json) {
    return RateResponse(
      base: json['base'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
      date: json['date'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ExchangeRate toEntity() {
    return ExchangeRate(
      baseCurrency: base,
      quoteCurrency: quote,
      rate: rate,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'base': base, 'quote': quote, 'date': date, 'rate': rate};
  }
}

class BulkRatesResponse {
  final String base;
  final String date;
  final Map<String, double> rates;

  const BulkRatesResponse({
    required this.base,
    required this.date,
    required this.rates,
  });

  factory BulkRatesResponse.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final rates = rawRates.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return BulkRatesResponse(
      base: json['base'] as String? ?? '',
      date: json['date'] as String? ?? '',
      rates: rates,
    );
  }
}
