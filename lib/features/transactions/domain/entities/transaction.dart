import 'package:equatable/equatable.dart';

/// Status of a transfer transaction.
enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  refunded;

  String get displayName => switch (this) {
        pending => 'Pending',
        processing => 'Processing',
        completed => 'Completed',
        failed => 'Failed',
        refunded => 'Refunded',
      };
}

/// Represents a single transfer transaction.
class Transaction extends Equatable {
  final String id;
  final String recipientName;
  final String recipientAccount;
  final double sendAmount;
  final String sendCurrency;
  final double receiveAmount;
  final String receiveCurrency;
  final double exchangeRate;
  final double fee;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? referenceNote;

  const Transaction({
    required this.id,
    required this.recipientName,
    required this.recipientAccount,
    required this.sendAmount,
    required this.sendCurrency,
    required this.receiveAmount,
    required this.receiveCurrency,
    required this.exchangeRate,
    required this.fee,
    required this.status,
    required this.createdAt,
    this.referenceNote,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientName': recipientName,
        'recipientAccount': recipientAccount,
        'sendAmount': sendAmount,
        'sendCurrency': sendCurrency,
        'receiveAmount': receiveAmount,
        'receiveCurrency': receiveCurrency,
        'exchangeRate': exchangeRate,
        'fee': fee,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'referenceNote': referenceNote,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      recipientName: json['recipientName'] as String,
      recipientAccount: json['recipientAccount'] as String,
      sendAmount: (json['sendAmount'] as num).toDouble(),
      sendCurrency: json['sendCurrency'] as String,
      receiveAmount: (json['receiveAmount'] as num).toDouble(),
      receiveCurrency: json['receiveCurrency'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceNote: json['referenceNote'] as String?,
    );
  }

  @override
  List<Object?> get props => [id];
}
