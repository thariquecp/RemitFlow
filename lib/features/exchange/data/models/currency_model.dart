import 'package:fintech_app/features/exchange/domain/entities/currency.dart';

/// API response format for /v2/currencies:

class CurrencyModel {
  final String code;
  final String name;

  const CurrencyModel({required this.code, required this.name});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: (json['iso_code'] ?? json['code']) as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Currency toEntity() {
    return Currency(code: code, name: name, flag: currencyToFlag(code));
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name};
  }

  static List<CurrencyModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
