import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    double amount,
    String currencyCode, {
    bool compact = false,
    bool showSymbol = true,
  }) {
    if (compact) {
      final formatter = NumberFormat.compactCurrency(
        symbol: showSymbol ? null : '',
        name: currencyCode,
      );
      return formatter.format(amount);
    }

    final formatter = NumberFormat.currency(
      name: showSymbol ? null : '',
      symbol: showSymbol ? null : '',
      decimalDigits: _decimalDigitsFor(currencyCode),
    );

    final formatted = formatter.format(amount);
    return showSymbol ? '$formatted $currencyCode' : formatted.trim();
  }

  static String formatRate(double rate) {
    if (rate >= 1000) {
      return rate.toStringAsFixed(2);
    } else if (rate >= 1) {
      return rate.toStringAsFixed(4);
    } else {
      return rate.toStringAsFixed(6);
    }
  }

  static int _decimalDigitsFor(String code) {
    const zeroDecimalCurrencies = {
      'JPY',
      'KRW',
      'VND',
      'CLP',
      'ISK',
      'HUF',
      'UGX',
      'RWF',
      'DJF',
      'GNF',
      'PYG',
    };
    return zeroDecimalCurrencies.contains(code.toUpperCase()) ? 0 : 2;
  }
}
