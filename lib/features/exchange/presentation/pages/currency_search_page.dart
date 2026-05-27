import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/core/theme/app_theme.dart';
import 'package:fintech_app/features/exchange/domain/entities/currency.dart';

class CurrencySearchPage extends StatefulWidget {
  final List<Currency> currencies;
  final String selectedCode;
  final ValueChanged<Currency> onSelected;

  const CurrencySearchPage({
    super.key,
    required this.currencies,
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  State<CurrencySearchPage> createState() => _CurrencySearchPageState();
}

class _CurrencySearchPageState extends State<CurrencySearchPage> {
  late TextEditingController _searchController;
  late List<Currency> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filtered = widget.currencies;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.currencies;
      } else {
        final lower = query.toLowerCase();
        _filtered = widget.currencies.where((c) {
          return c.code.toLowerCase().contains(lower) ||
              c.name.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacing12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Text(
              'Select Currency',
              style: theme.textTheme.headlineSmall,
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacing12),

          // Currency list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'No currencies found',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                    ),
                    itemBuilder: (context, index) {
                      final currency = _filtered[index];
                      final isSelected = currency.code == widget.selectedCode;

                      return _CurrencyListTile(
                            currency: currency,
                            isSelected: isSelected,
                            onTap: () => widget.onSelected(currency),
                          )
                          .animate()
                          .fadeIn(
                            duration: 200.ms,
                            delay: Duration(
                              milliseconds: (30 * index).clamp(0, 400),
                            ),
                          )
                          .slideX(begin: 0.05, end: 0, duration: 200.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyListTile extends StatelessWidget {
  final Currency currency;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyListTile({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.08)
                : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Row(
            children: [
              // Flag
              Text(currency.flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppTheme.spacing12),

              // Name + code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.textTheme.titleLarge?.color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(currency.code, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
