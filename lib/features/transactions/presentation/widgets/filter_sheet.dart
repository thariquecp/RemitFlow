import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/transactions/domain/entities/transaction.dart';
import 'package:fintech_app/features/transactions/presentation/bloc/transaction_bloc.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  TransactionStatus? _status;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = context.read<TransactionBloc>().state.filter;
    _status = filter.status;
    _searchQuery = filter.searchQuery ?? '';
    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Text('Filter Transactions', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppTheme.spacing20),

          // Search
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(
              hintText: 'Search by name, ID, currency...',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),

          // Status chips
          Text('Status', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.spacing8),
          Wrap(
            spacing: AppTheme.spacing8,
            children: [
              _buildChip(null, 'All'),
              ...TransactionStatus.values.map(
                (s) => _buildChip(s, s.displayName),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<TransactionBloc>().add(
                      const TransactionFilterChanged(TransactionFilter()),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<TransactionBloc>().add(
                      TransactionFilterChanged(
                        TransactionFilter(
                          status: _status,
                          searchQuery: _searchQuery.isEmpty
                              ? null
                              : _searchQuery,
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
        ],
      ),
    );
  }

  Widget _buildChip(TransactionStatus? status, String label) {
    final isSelected = _status == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _status = status),
      showCheckmark: false,
    );
  }
}
