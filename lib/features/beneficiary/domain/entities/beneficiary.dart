import 'package:equatable/equatable.dart';

/// Represents a transfer beneficiary (recipient).
class Beneficiary extends Equatable {
  final String id;
  final String fullName;
  final String nickname;
  final String bankName;
  final String accountNumber;
  final String country;
  final String countryFlag;
  final String currency;
  final DateTime? lastTransferDate;
  final DateTime createdAt;

  const Beneficiary({
    required this.id,
    required this.fullName,
    required this.nickname,
    required this.bankName,
    required this.accountNumber,
    required this.country,
    required this.countryFlag,
    required this.currency,
    this.lastTransferDate,
    required this.createdAt,
  });

  /// Generates initials from the full name (max 2 letters).
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Whether a transfer was made in the last 7 days.
  bool get hasRecentTransfer {
    if (lastTransferDate == null) return false;
    return DateTime.now().difference(lastTransferDate!).inDays < 7;
  }

  Beneficiary copyWith({
    String? id,
    String? fullName,
    String? nickname,
    String? bankName,
    String? accountNumber,
    String? country,
    String? countryFlag,
    String? currency,
    DateTime? lastTransferDate,
    DateTime? createdAt,
  }) {
    return Beneficiary(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      country: country ?? this.country,
      countryFlag: countryFlag ?? this.countryFlag,
      currency: currency ?? this.currency,
      lastTransferDate: lastTransferDate ?? this.lastTransferDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'nickname': nickname,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'country': country,
        'countryFlag': countryFlag,
        'currency': currency,
        'lastTransferDate': lastTransferDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      nickname: json['nickname'] as String? ?? '',
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      country: json['country'] as String,
      countryFlag: json['countryFlag'] as String? ?? '🏳️',
      currency: json['currency'] as String? ?? 'USD',
      lastTransferDate: json['lastTransferDate'] != null
          ? DateTime.parse(json['lastTransferDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, fullName, accountNumber, bankName];
}
