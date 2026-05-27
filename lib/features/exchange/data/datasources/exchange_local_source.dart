import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:fintech_app/core/errors/exceptions.dart';

class ExchangeLocalSource {
  static const String _rateBoxName = 'exchange_rates';
  static const String _currencyBoxName = 'currencies';

  Box? _rateBox;
  Box? _currencyBox;

  Future<void> init() async {
    _rateBox = await Hive.openBox(_rateBoxName);
    _currencyBox = await Hive.openBox(_currencyBoxName);
  }

  Future<void> cacheRate(
    String base,
    String quote,
    Map<String, dynamic> rateJson,
  ) async {
    try {
      final key = '${base}_$quote';
      final entry = {
        'data': rateJson,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      await _rateBox?.put(key, jsonEncode(entry));
    } catch (e) {
      throw CacheException('Failed to cache rate: $e');
    }
  }

  Map<String, dynamic>? getCachedRate(String base, String quote) {
    try {
      final key = '${base}_$quote';
      final raw = _rateBox?.get(key) as String?;
      if (raw == null) return null;

      final entry = jsonDecode(raw) as Map<String, dynamic>;
      return entry['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  DateTime? getCacheTimestamp(String base, String quote) {
    try {
      final key = '${base}_$quote';
      final raw = _rateBox?.get(key) as String?;
      if (raw == null) return null;

      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = entry['cachedAt'] as String?;
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheCurrencies(List<Map<String, dynamic>> currencies) async {
    try {
      await _currencyBox?.put('all', jsonEncode(currencies));
    } catch (e) {
      throw CacheException('Failed to cache currencies: $e');
    }
  }

  List<Map<String, dynamic>>? getCachedCurrencies() {
    try {
      final raw = _currencyBox?.get('all') as String?;
      if (raw == null) return null;

      final list = jsonDecode(raw) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheBulkRates(String base, Map<String, double> rates) async {
    try {
      final entry = {
        'rates': rates,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      await _rateBox?.put('bulk_$base', jsonEncode(entry));
    } catch (e) {
      throw CacheException('Failed to cache bulk rates: $e');
    }
  }

  Map<String, double>? getCachedBulkRates(String base) {
    try {
      final raw = _rateBox?.get('bulk_$base') as String?;
      if (raw == null) return null;

      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final rates = entry['rates'] as Map<String, dynamic>?;
      return rates?.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return null;
    }
  }
}
