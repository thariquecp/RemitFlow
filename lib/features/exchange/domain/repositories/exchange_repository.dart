import 'package:fintech_app/features/exchange/domain/entities/currency.dart';
import 'package:fintech_app/features/exchange/domain/entities/exchange_rate.dart';

abstract class ExchangeRepository {
  Future<ExchangeRate> getExchangeRate(String base, String quote);

  /// Fetches all available rates for a currency.
  Future<Map<String, double>> getAllRates(String base);

  /// Returns the list of supported currencies.
  Future<List<Currency>> getCurrencies();
}
