import 'package:equatable/equatable.dart';

/// Represents a supported currency with its metadata.
///
/// Includes the ISO code, full name, and a flag emoji
/// derived from the country code for zero-dependency rendering.
class Currency extends Equatable {
  final String code;
  final String name;
  final String flag;
  final bool isFavorite;

  const Currency({
    required this.code,
    required this.name,
    required this.flag,
    this.isFavorite = false,
  });

  Currency copyWith({
    String? code,
    String? name,
    String? flag,
    bool? isFavorite,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      flag: flag ?? this.flag,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [code, name, flag, isFavorite];

  @override
  String toString() => 'Currency($code, $name)';
}

/// Maps ISO 4217 currency codes to country flag emojis.
///
/// Uses Unicode regional indicator symbols — works on both iOS and Android
/// without requiring image assets.
String currencyToFlag(String currencyCode) {
  // Most currency codes share the first two letters with their country code.
  // Handle exceptions explicitly.
  const overrides = {
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'USD': '🇺🇸',
    'JPY': '🇯🇵',
    'AUD': '🇦🇺',
    'CAD': '🇨🇦',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
    'HKD': '🇭🇰',
    'NZD': '🇳🇿',
    'SGD': '🇸🇬',
    'KRW': '🇰🇷',
    'INR': '🇮🇳',
    'BRL': '🇧🇷',
    'ZAR': '🇿🇦',
    'MXN': '🇲🇽',
    'AED': '🇦🇪',
    'SAR': '🇸🇦',
    'TRY': '🇹🇷',
    'RUB': '🇷🇺',
    'PLN': '🇵🇱',
    'THB': '🇹🇭',
    'IDR': '🇮🇩',
    'MYR': '🇲🇾',
    'PHP': '🇵🇭',
    'SEK': '🇸🇪',
    'NOK': '🇳🇴',
    'DKK': '🇩🇰',
    'CZK': '🇨🇿',
    'HUF': '🇭🇺',
    'ILS': '🇮🇱',
    'CLP': '🇨🇱',
    'ARS': '🇦🇷',
    'COP': '🇨🇴',
    'PEN': '🇵🇪',
    'EGP': '🇪🇬',
    'NGN': '🇳🇬',
    'KES': '🇰🇪',
    'PKR': '🇵🇰',
    'BDT': '🇧🇩',
    'LKR': '🇱🇰',
    'VND': '🇻🇳',
    'TWD': '🇹🇼',
    'RON': '🇷🇴',
    'BGN': '🇧🇬',
    'HRK': '🇭🇷',
    'ISK': '🇮🇸',
  };

  if (overrides.containsKey(currencyCode)) {
    return overrides[currencyCode]!;
  }

  if (currencyCode.length < 2) return '🌍';

  // Fallback: derive flag from first two characters of the currency code
  final countryCode = currencyCode.substring(0, 2).toUpperCase();
  final flagOffset = 0x1F1E6;
  final asciiOffset = 0x41;

  final firstChar = countryCode.codeUnitAt(0) - asciiOffset + flagOffset;
  final secondChar = countryCode.codeUnitAt(1) - asciiOffset + flagOffset;

  return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
}
