import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/core/widgets/error_view.dart';
import 'package:fintech_app/core/widgets/shimmer_loading.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_event.dart';
import 'package:fintech_app/features/exchange/presentation/bloc/exchange_state.dart';
import 'package:fintech_app/features/exchange/presentation/pages/currency_search_page.dart';
import 'package:fintech_app/features/exchange/presentation/widgets/currency_input_tile.dart';
import 'package:fintech_app/features/exchange/presentation/widgets/fee_breakdown_card.dart';
import 'package:fintech_app/features/exchange/presentation/widgets/rate_card.dart';
import 'package:fintech_app/features/exchange/presentation/widgets/swap_button.dart';
import 'package:fintech_app/features/transfer/presentation/widgets/beneficiary_selection_sheet.dart';

/// Main exchange rate dashboard page.

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  late TextEditingController _sendController;
  late TextEditingController _receiveController;
  bool _isSendEditing = true;
  ExchangeState? _currentState;

  @override
  void initState() {
    super.initState();
    _sendController = TextEditingController(text: '1000');
    _receiveController = TextEditingController();
  }

  @override
  void dispose() {
    _sendController.dispose();
    _receiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Exchange', style: theme.textTheme.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<ExchangeBloc, ExchangeState>(
        listenWhen: (prev, curr) =>
            prev.receiveAmount != curr.receiveAmount && _isSendEditing ||
            prev.sendAmount != curr.sendAmount && !_isSendEditing,
        listener: (context, state) {
          if (_isSendEditing) {
            _receiveController.text = state.receiveAmount;
          } else {
            _sendController.text = state.sendAmount;
          }
        },
        builder: (context, state) {
          _currentState = state;

          if (state.status == ExchangeStatus.initial) {
            return const Center(child: ShimmerLoading(itemCount: 3));
          }

          if (state.status == ExchangeStatus.error &&
              state.currentRate == null) {
            return ErrorView(
              message:
                  'Could not load exchange rates.\nPlease check your connection.',
              icon: Icons.cloud_off_rounded,
              onRetry: () {
                context.read<ExchangeBloc>().add(const ExchangeStarted());
              },
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _rateCard,
                const SizedBox(height: AppTheme.spacing24),
                _youSendTile,
                _swapButton,
                _recipientGetsTile,
                const SizedBox(height: AppTheme.spacing20),
                _feeBreakdownCard,
                const SizedBox(height: AppTheme.spacing24),
                _continueButton,
                const SizedBox(height: AppTheme.spacing32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget get _rateCard {
    if (_currentState == null) return const SizedBox.shrink();
    return RateCard(
      rate: _currentState!.currentRate,
      isStale: _currentState!.isRateStale,
      lastUpdated: _currentState!.lastUpdated,
      onRefresh: () {
        context.read<ExchangeBloc>().add(const RateRefreshRequested());
      },
    );
  }

  Widget get _youSendTile {
    if (_currentState == null) return const SizedBox.shrink();
    return CurrencyInputTile(
      currency: _currentState!.sendCurrency,
      amount: _currentState!.sendAmount,
      label: 'You send',
      controller: _sendController,
      isEditing: _isSendEditing,
      onAmountChanged: (val) {
        _isSendEditing = true;
        context.read<ExchangeBloc>().add(SendAmountChanged(val));
      },
      onCurrencyTap: () => _openCurrencySearch(context, isSend: true),
    );
  }

  Widget get _swapButton {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Center(
        child: SwapButton(
          onSwap: () {
            context.read<ExchangeBloc>().add(const CurrenciesSwapped());
          },
        ),
      ),
    );
  }

  Widget get _recipientGetsTile {
    if (_currentState == null) return const SizedBox.shrink();
    return CurrencyInputTile(
      currency: _currentState!.receiveCurrency,
      amount: _currentState!.receiveAmount,
      label: 'Recipient gets',
      controller: _receiveController,
      isEditing: !_isSendEditing,
      onAmountChanged: (val) {
        _isSendEditing = false;
        context.read<ExchangeBloc>().add(ReceiveAmountChanged(val));
      },
      onCurrencyTap: () => _openCurrencySearch(context, isSend: false),
    );
  }

  Widget get _feeBreakdownCard {
    if (_currentState == null) return const SizedBox.shrink();
    return FeeBreakdownCard(breakdown: _currentState!.feeBreakdown);
  }

  Widget get _continueButton {
    if (_currentState == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _currentState!.status == ExchangeStatus.loaded
                ? () => _showTransferSheet(context)
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, size: 20),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  'Continue to Send',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  void _openCurrencySearch(BuildContext context, {required bool isSend}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CurrencySearchPage(
        currencies: context.read<ExchangeBloc>().state.availableCurrencies,
        selectedCode: isSend
            ? context.read<ExchangeBloc>().state.sendCurrency.code
            : context.read<ExchangeBloc>().state.receiveCurrency.code,
        onSelected: (currency) {
          if (isSend) {
            context.read<ExchangeBloc>().add(SendCurrencySelected(currency));
          } else {
            context.read<ExchangeBloc>().add(ReceiveCurrencySelected(currency));
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTransferSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ExchangeBloc>(),
        child: const BeneficiarySelectionSheet(),
      ),
    );
  }
}
