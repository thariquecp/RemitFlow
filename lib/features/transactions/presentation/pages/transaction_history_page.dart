import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/core/utils/date_formatter.dart';
import 'package:fintech_app/core/utils/masking_utils.dart';
import 'package:fintech_app/features/transactions/domain/entities/transaction.dart';
import 'package:fintech_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:fintech_app/features/transactions/presentation/widgets/filter_sheet.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(const TransactionLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: theme.textTheme.headlineMedium),
        actions: [
          BlocBuilder<TransactionBloc, TransactionState>(
            buildWhen: (p, c) => p.filter != c.filter,
            builder: (context, state) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _showFilterSheet(context),
                  ),
                  if (state.filter.hasActiveFilters)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.status == TransactionLoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 64,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3)),
                  const SizedBox(height: AppTheme.spacing16),
                  Text('No transactions found', style: theme.textTheme.titleLarge),
                ],
              ),
            );
          }

          // Group by date
          final grouped = _groupByDate(state.transactions);

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: grouped.length +
                (state.status == TransactionLoadStatus.loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == grouped.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppTheme.spacing16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }

              final entry = grouped[index];
              if (entry is String) {
                return Padding(
                  padding: const EdgeInsets.only(
                    top: AppTheme.spacing16, bottom: AppTheme.spacing8),
                  child: Text(entry, style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleLarge?.color,
                  )),
                );
              }

              final tx = entry as Transaction;
              return _TransactionTile(transaction: tx)
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideX(begin: 0.03, end: 0, duration: 200.ms);
            },
          );
        },
      ),
    );
  }

  List<dynamic> _groupByDate(List<Transaction> transactions) {
    final result = <dynamic>[];
    String? lastLabel;

    for (final tx in transactions) {
      final label = DateFormatter.groupLabel(tx.createdAt);
      if (label != lastLabel) {
        result.add(label);
        lastLabel = label;
      }
      result.add(tx);
    }
    return result;
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: const TransactionFilterSheet(),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          _StatusIcon(status: transaction.status),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.recipientName,
                  style: theme.textTheme.titleMedium, maxLines: 1,
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${MaskingUtils.maskTransactionId(transaction.id)} • ${DateFormatter.time(transaction.createdAt)}',
                  style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-${transaction.sendAmount.toStringAsFixed(2)} ${transaction.sendCurrency}',
                style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('+${transaction.receiveAmount.toStringAsFixed(2)} ${transaction.receiveCurrency}',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final TransactionStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      TransactionStatus.pending => (AppColors.statusPending, Icons.schedule_rounded),
      TransactionStatus.processing => (AppColors.statusProcessing, Icons.sync_rounded),
      TransactionStatus.completed => (AppColors.statusCompleted, Icons.check_circle_rounded),
      TransactionStatus.failed => (AppColors.statusFailed, Icons.cancel_rounded),
      TransactionStatus.refunded => (AppColors.statusRefunded, Icons.replay_rounded),
    };

    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
