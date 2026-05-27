import 'package:dio/dio.dart';
import 'package:fintech_app/core/constants/api_constants.dart';
import 'package:fintech_app/core/errors/exceptions.dart';
import 'package:fintech_app/features/exchange/data/models/currency_model.dart';
import 'package:fintech_app/features/exchange/data/models/rate_response.dart';

/// Thrown when the API response cannot be parsed.
class ParseFailure implements Exception {
  final String message;
  const ParseFailure(this.message);
  @override
  String toString() => 'ParseFailure($message)';
}

/// Remote data source that calls the Frankfurter API v2.
class ExchangeRemoteSource {
  final Dio _dio;

  ExchangeRemoteSource(this._dio);

  /// Fetches the exchange rate for a single currency pair.
  Future<RateResponse> getRate(String base, String quote) async {
    try {
      final response = await _dio.get(ApiConstants.pairRate(base, quote));

      if (response.data == null) {
        throw const ParseFailure('Empty response from rate API');
      }

      return RateResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      // Re-thrown by the error interceptor as ServerException/NetworkException
      rethrow;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ParseFailure('Failed to parse rate response: $e');
    }
  }

  /// Fetches all exchange rates for a given base currency.
  Future<BulkRatesResponse> getAllRates(String base) async {
    try {
      final response = await _dio.get(
        ApiConstants.latestRates,
        queryParameters: {'base': base},
      );

      if (response.data == null) {
        throw const ParseFailure('Empty response from rates API');
      }

      return BulkRatesResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ParseFailure('Failed to parse rates response: $e');
    }
  }

  /// Fetches the list of supported currencies.
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      final response = await _dio.get(ApiConstants.currencies);

      if (response.data == null) {
        throw const ParseFailure('Empty response from currencies API');
      }

      return CurrencyModel.fromJsonList(response.data as List<dynamic>);
    } on DioException {
      rethrow;
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ParseFailure('Failed to parse currencies response: $e');
    }
  }
}
