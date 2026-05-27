import 'package:equatable/equatable.dart';
import 'package:fintech_app/features/exchange/domain/entities/currency.dart';

/// Events dispatched to the [ExchangeBloc].
sealed class ExchangeEvent extends Equatable {
  const ExchangeEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data (currencies list + default rate).
class ExchangeStarted extends ExchangeEvent {
  const ExchangeStarted();
}

/// User changed the send amount — recalculate everything.
class SendAmountChanged extends ExchangeEvent {
  final String amount;
  const SendAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// User changed the receive amount — reverse-calculate send amount.
class ReceiveAmountChanged extends ExchangeEvent {
  final String amount;
  const ReceiveAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// User selected a new sending currency.
class SendCurrencySelected extends ExchangeEvent {
  final Currency currency;
  const SendCurrencySelected(this.currency);

  @override
  List<Object?> get props => [currency];
}

/// User selected a new receiving currency.
class ReceiveCurrencySelected extends ExchangeEvent {
  final Currency currency;
  const ReceiveCurrencySelected(this.currency);

  @override
  List<Object?> get props => [currency];
}

/// Swap the send and receive currencies.
class CurrenciesSwapped extends ExchangeEvent {
  const CurrenciesSwapped();
}

/// Refresh the exchange rate (manual or auto-triggered).
class RateRefreshRequested extends ExchangeEvent {
  const RateRefreshRequested();
}

/// Simulated rate fluctuation arrived from the stream.
class RateFluctuationReceived extends ExchangeEvent {
  final double newRate;
  const RateFluctuationReceived(this.newRate);

  @override
  List<Object?> get props => [newRate];
}

/// Rate has gone stale (>30 seconds old).
class RateExpired extends ExchangeEvent {
  const RateExpired();
}
