import 'package:flutter/material.dart';
import 'package:fintech_app/core/theme/app_colors.dart';
import 'package:fintech_app/features/exchange/presentation/pages/exchange_page.dart';
import 'package:fintech_app/features/beneficiary/presentation/pages/beneficiary_list_page.dart';
import 'package:fintech_app/features/transactions/presentation/pages/transaction_history_page.dart';
import 'package:fintech_app/features/settings/presentation/pages/settings_page.dart';

/// Bottom navigation shell with 4 tabs.
///
/// Uses [IndexedStack] to preserve state across tab switches
/// without rebuilding each page from scratch.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static const _pages = [
    ExchangePage(),
    BeneficiaryListPage(),
    TransactionHistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.currency_exchange_rounded),
              activeIcon: Icon(Icons.currency_exchange_rounded),
              label: 'Exchange',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Recipients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
