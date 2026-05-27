import 'package:fintech_app/core/errors/exceptions.dart';
import 'package:fintech_app/core/network/network_info.dart';
import 'package:fintech_app/features/exchange/data/datasources/exchange_local_source.dart';
import 'package:fintech_app/features/exchange/data/datasources/exchange_remote_source.dart';
import 'package:fintech_app/features/exchange/data/models/currency_model.dart';
import 'package:fintech_app/features/exchange/domain/entities/currency.dart';
import 'package:fintech_app/features/exchange/domain/entities/exchange_rate.dart';
import 'package:fintech_app/features/exchange/domain/repositories/exchange_repository.dart';

/// Repository implementation
class ExchangeRepositoryImpl implements ExchangeRepository {
  final ExchangeRemoteSource _remoteSource;
  final ExchangeLocalSource _localSource;
  final NetworkInfo _networkInfo;

  ExchangeRepositoryImpl({
    required this._remoteSource,
    required this._localSource,
    required this._networkInfo,
  });

  @override
  Future<ExchangeRate> getExchangeRate(String base, String quote) async {
    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      try {
        final response = await _remoteSource.getRate(base, quote);

        // Cache for offline use
        await _localSource.cacheRate(base, quote, response.toJson());

        return response.toEntity();
      } on ServerException {
        // Fall through to cache
      } on NetworkException {
        // Fall through to cache
      }
    }

    // Try cache fallback
    final cached = _localSource.getCachedRate(base, quote);
    if (cached != null) {
      final timestamp = _localSource.getCacheTimestamp(base, quote);
      return ExchangeRate(
        baseCurrency: base,
        quoteCurrency: quote,
        rate: (cached['rate'] as num).toDouble(),
        timestamp: timestamp ?? DateTime.now(),
      );
    }

    throw const NetworkException(
      'No internet connection and no cached data available',
    );
  }

  @override
  Future<Map<String, double>> getAllRates(String base) async {
    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      try {
        final response = await _remoteSource.getAllRates(base);
        await _localSource.cacheBulkRates(base, response.rates);
        return response.rates;
      } on ServerException {
        // Fall through to cache
      } on NetworkException {
        // Fall through to cache
      }
    }

    final cached = _localSource.getCachedBulkRates(base);
    if (cached != null) return cached;

    throw const NetworkException(
      'No internet connection and no cached rates available',
    );
  }

  @override
  Future<List<Currency>> getCurrencies() async {
    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      try {
        final models = await _remoteSource.getCurrencies();

        await _localSource.cacheCurrencies(
          models.map((m) => m.toJson()).toList(),
        );

        return models.map((m) => m.toEntity()).toList();
      } on ServerException {
        // Fall through to cache
      } on NetworkException {
        // Fall through to cache
      }
    }

    final cached = _localSource.getCachedCurrencies();
    if (cached != null) {
      return cached
          .map((json) => CurrencyModel.fromJson(json).toEntity())
          .toList();
    }

    throw const NetworkException(
      'No internet connection and no cached currencies available',
    );
  }
}
