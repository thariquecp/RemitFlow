import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_app/core/constants/app_constants.dart';
import 'package:fintech_app/core/utils/fee_calculator.dart';
import 'package:fintech_app/features/exchange/domain/entities/exchange_rate.dart';
import 'package:fintech_app/features/exchange/domain/entities/fee_breakdown.dart';
import 'package:fintech_app/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_event.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_state.dart';

/// Manages the exchange rate calculator logic.
///

class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  final ExchangeRepository _repository;

  Timer? _expiryTimer;
  Timer? _fluctuationTimer;
  final _random = Random();

  ExchangeBloc({required this._repository}) : super(const ExchangeState()) {
    on<ExchangeStarted>(_onStarted);
    on<SendAmountChanged>(_onSendAmountChanged);
    on<ReceiveAmountChanged>(_onReceiveAmountChanged);
    on<SendCurrencySelected>(_onSendCurrencySelected);
    on<ReceiveCurrencySelected>(_onReceiveCurrencySelected);
    on<CurrenciesSwapped>(_onCurrenciesSwapped);
    on<RateRefreshRequested>(_onRateRefresh);
    on<RateFluctuationReceived>(_onRateFluctuation);
    on<RateExpired>(_onRateExpired);
  }

  Future<void> _onStarted(
    ExchangeStarted event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(state.copyWith(status: ExchangeStatus.loading));

    try {
      // Fetch currencies and initial rate in parallel
      final currencies = await _repository.getCurrencies();
      final rate = await _repository.getExchangeRate(
        state.sendCurrency.code,
        state.receiveCurrency.code,
      );

      final breakdown = _calculateBreakdown(
        sendAmount: double.tryParse(state.sendAmount) ?? 0,
        rate: rate,
      );

      emit(
        state.copyWith(
          status: ExchangeStatus.loaded,
          availableCurrencies: currencies,
          currentRate: rate,
          lastUpdated: DateTime.now(),
          isRateStale: false,
          feeBreakdown: breakdown,
          receiveAmount: breakdown.recipientGets.toStringAsFixed(2),
        ),
      );

      _startTimers();
    } catch (e) {
      emit(
        state.copyWith(
          status: ExchangeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSendAmountChanged(
    SendAmountChanged event,
    Emitter<ExchangeState> emit,
  ) async {
    final amount = double.tryParse(event.amount) ?? 0;
    final rate = state.currentRate;
    if (rate == null) return;

    final breakdown = _calculateBreakdown(sendAmount: amount, rate: rate);

    emit(
      state.copyWith(
        sendAmount: event.amount,
        receiveAmount: breakdown.recipientGets.toStringAsFixed(2),
        feeBreakdown: breakdown,
      ),
    );
  }

  Future<void> _onReceiveAmountChanged(
    ReceiveAmountChanged event,
    Emitter<ExchangeState> emit,
  ) async {
    final receiveAmount = double.tryParse(event.amount) ?? 0;
    final rate = state.currentRate;
    if (rate == null || rate.rate == 0) return;

    final rawSendAmount = receiveAmount / rate.rate;
    final isSameCurrency =
        state.sendCurrency.code == state.receiveCurrency.code;
    final isWeekend = _isWeekend();

    double sendAmount = rawSendAmount;
    for (int i = 0; i < 5; i++) {
      final feeResult = FeeCalculator.calculate(
        amount: sendAmount,
        isSameCurrency: isSameCurrency,
        isWeekend: isWeekend,
      );
      sendAmount = rawSendAmount + feeResult.totalFee;
    }

    sendAmount = _roundCurrency(sendAmount);

    final breakdown = _calculateBreakdown(sendAmount: sendAmount, rate: rate);

    emit(
      state.copyWith(
        receiveAmount: event.amount,
        sendAmount: sendAmount.toStringAsFixed(2),
        feeBreakdown: breakdown,
      ),
    );
  }

  Future<void> _onSendCurrencySelected(
    SendCurrencySelected event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(
      state.copyWith(
        sendCurrency: event.currency,
        status: ExchangeStatus.loading,
      ),
    );

    await _fetchAndRecalculate(emit);
  }

  Future<void> _onReceiveCurrencySelected(
    ReceiveCurrencySelected event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(
      state.copyWith(
        receiveCurrency: event.currency,
        status: ExchangeStatus.loading,
      ),
    );

    await _fetchAndRecalculate(emit);
  }

  Future<void> _onCurrenciesSwapped(
    CurrenciesSwapped event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(
      state.copyWith(
        sendCurrency: state.receiveCurrency,
        receiveCurrency: state.sendCurrency,
        isSwapping: true,
        status: ExchangeStatus.loading,
      ),
    );

    await _fetchAndRecalculate(emit);

    emit(state.copyWith(isSwapping: false));
  }

  Future<void> _onRateRefresh(
    RateRefreshRequested event,
    Emitter<ExchangeState> emit,
  ) async {
    await _fetchAndRecalculate(emit);
  }

  void _onRateFluctuation(
    RateFluctuationReceived event,
    Emitter<ExchangeState> emit,
  ) {
    if (state.currentRate == null) return;

    final updatedRate = state.currentRate!.copyWith(
      rate: event.newRate,
      timestamp: DateTime.now(),
    );

    final amount = double.tryParse(state.sendAmount) ?? 0;
    final breakdown = _calculateBreakdown(
      sendAmount: amount,
      rate: updatedRate,
    );

    emit(
      state.copyWith(
        currentRate: updatedRate,
        feeBreakdown: breakdown,
        receiveAmount: breakdown.recipientGets.toStringAsFixed(2),
        lastUpdated: DateTime.now(),
        isRateStale: false,
      ),
    );
  }

  void _onRateExpired(RateExpired event, Emitter<ExchangeState> emit) {
    emit(state.copyWith(isRateStale: true));
  }

  Future<void> _fetchAndRecalculate(Emitter<ExchangeState> emit) async {
    try {
      final rate = await _repository.getExchangeRate(
        state.sendCurrency.code,
        state.receiveCurrency.code,
      );

      final amount = double.tryParse(state.sendAmount) ?? 0;
      final breakdown = _calculateBreakdown(sendAmount: amount, rate: rate);

      emit(
        state.copyWith(
          status: ExchangeStatus.loaded,
          currentRate: rate,
          lastUpdated: DateTime.now(),
          isRateStale: false,
          feeBreakdown: breakdown,
          receiveAmount: breakdown.recipientGets.toStringAsFixed(2),
          errorMessage: '',
        ),
      );

      _restartTimers();
    } catch (e) {
      emit(
        state.copyWith(
          status: state.currentRate != null
              ? ExchangeStatus.loaded
              : ExchangeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  FeeBreakdown _calculateBreakdown({
    required double sendAmount,
    required ExchangeRate rate,
  }) {
    final isSameCurrency =
        state.sendCurrency.code == state.receiveCurrency.code;
    final isWeekend = _isWeekend();

    final feeResult = FeeCalculator.calculate(
      amount: sendAmount,
      isSameCurrency: isSameCurrency,
      isWeekend: isWeekend,
    );

    final totalPayable = _roundCurrency(sendAmount + feeResult.totalFee);
    final recipientGets = _roundCurrency(sendAmount * rate.rate);

    return FeeBreakdown(
      sendAmount: sendAmount,
      baseFee: feeResult.baseFee,
      weekendSurcharge: feeResult.weekendSurcharge,
      totalFee: feeResult.totalFee,
      totalPayable: totalPayable,
      exchangeRate: rate.rate,
      recipientGets: recipientGets,
      sendCurrency: state.sendCurrency.code,
      receiveCurrency: state.receiveCurrency.code,
    );
  }

  void _startTimers() {
    // Rate expiry timer — marks rate as stale after 30 seconds
    _expiryTimer?.cancel();
    _expiryTimer = Timer(rateExpiryDuration, () {
      add(const RateExpired());
      add(const RateRefreshRequested());
    });

    // Rate fluctuation timer — simulates live updates
    _fluctuationTimer?.cancel();
    _fluctuationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (state.currentRate == null) return;
      final currentRate = state.currentRate!.rate;
      final fluctuation = currentRate * 0.003 * (_random.nextDouble() * 2 - 1);
      final newRate = currentRate + fluctuation;
      add(RateFluctuationReceived(newRate));
    });
  }

  void _restartTimers() {
    _expiryTimer?.cancel();
    _fluctuationTimer?.cancel();
    _startTimers();
  }

  bool _isWeekend() {
    final weekday = DateTime.now().weekday;
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  double _roundCurrency(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  @override
  Future<void> close() {
    _expiryTimer?.cancel();
    _fluctuationTimer?.cancel();
    return super.close();
  }
}
