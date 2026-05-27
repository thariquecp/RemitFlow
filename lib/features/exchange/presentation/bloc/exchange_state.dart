import 'package:equatable/equatable.dart';
import 'package:fintech_app/features/exchange/domain/entities/currency.dart';
import 'package:fintech_app/features/exchange/domain/entities/exchange_rate.dart';
import 'package:fintech_app/features/exchange/domain/entities/fee_breakdown.dart';

/// Status of the exchange bloc.
enum ExchangeStatus { initial, loading, loaded, error }

/// Immutable state for the exchange rate calculator.
///
/// Holds all the data needed to render the exchange dashboard
/// without any derived state — everything is pre-computed.
class ExchangeState extends Equatable {
  final ExchangeStatus status;
  final String errorMessage;

  // Selected currencies
  final Currency sendCurrency;
  final Currency receiveCurrency;
  final List<Currency> availableCurrencies;

  // Amounts (stored as strings for text field binding)
  final String sendAmount;
  final String receiveAmount;

  // Rate data
  final ExchangeRate? currentRate;
  final bool isRateStale;
  final DateTime? lastUpdated;

  // Fee breakdown
  final FeeBreakdown? feeBreakdown;

  // UI state
  final bool isSwapping;

  const ExchangeState({
    this.status = ExchangeStatus.initial,
    this.errorMessage = '',
    this.sendCurrency = const Currency(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
    this.receiveCurrency = const Currency(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
    this.availableCurrencies = const [],
    this.sendAmount = '1000',
    this.receiveAmount = '',
    this.currentRate,
    this.isRateStale = false,
    this.lastUpdated,
    this.feeBreakdown,
    this.isSwapping = false,
  });

  ExchangeState copyWith({
    ExchangeStatus? status,
    String? errorMessage,
    Currency? sendCurrency,
    Currency? receiveCurrency,
    List<Currency>? availableCurrencies,
    String? sendAmount,
    String? receiveAmount,
    ExchangeRate? currentRate,
    bool? isRateStale,
    DateTime? lastUpdated,
    FeeBreakdown? feeBreakdown,
    bool? isSwapping,
  }) {
    return ExchangeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      sendCurrency: sendCurrency ?? this.sendCurrency,
      receiveCurrency: receiveCurrency ?? this.receiveCurrency,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      sendAmount: sendAmount ?? this.sendAmount,
      receiveAmount: receiveAmount ?? this.receiveAmount,
      currentRate: currentRate ?? this.currentRate,
      isRateStale: isRateStale ?? this.isRateStale,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      feeBreakdown: feeBreakdown ?? this.feeBreakdown,
      isSwapping: isSwapping ?? this.isSwapping,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        sendCurrency,
        receiveCurrency,
        availableCurrencies,
        sendAmount,
        receiveAmount,
        currentRate,
        isRateStale,
        lastUpdated,
        feeBreakdown,
        isSwapping,
      ];
}
