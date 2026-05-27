class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.frankfurter.dev';

  static const String latestRates = '/v2/rates';
  static const String currencies = '/v2/currencies';

  static String pairRate(String base, String quote) => '/v2/rate/$base/$quote';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
}
