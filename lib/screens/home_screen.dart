import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';
import 'menu_screen.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final currency = ref.watch(currencyProvider);

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final lastWeekAgo = now.subtract(const Duration(days: 14));

    final thisWeekExpenses = transactions
        .where((t) => t.isExpense && t.date.isAfter(weekAgo))
        .fold(0.0, (sum, t) => sum + t.amount);

    final lastWeekExpenses = transactions
        .where((t) =>
            t.isExpense &&
            t.date.isAfter(lastWeekAgo) &&
            t.date.isBefore(weekAgo))
        .fold(0.0, (sum, t) => sum + t.amount);

    final spentMore = thisWeekExpenses > lastWeekExpenses;

    final recentTransactions = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final displayed = recentTransactions.take(5).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < -300) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen()),
              );
            } else if (details.primaryVelocity! > 300) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MenuScreen()),
                      ),
                      child: const Text(
                        '✦ My Finance ✦',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('• • •',
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 22),
                          children: [
                            const TextSpan(
                              text: 'SPENT ',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: spentMore ? 'MORE' : 'LESS',
                              style: TextStyle(
                                color: spentMore
                                    ? AppColors.accentRed
                                    : AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '\nthan last week',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (displayed.isEmpty)
                        const Text(
                          'Swipe left to add\nyour first transaction',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                        )
                      else
                        Column(
                          children: displayed.map((t) {
                            return _TransactionRow(
                              title: t.title,
                              amount: t.amount,
                              isExpense: t.isExpense,
                              currency: currency,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String title;
  final double amount;
  final bool isExpense;
  final String currency;

  const _TransactionRow({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                '${isExpense ? '-' : '+'}$currency${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color:
                    isExpense ? AppColors.accentRed : AppColors.accent,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}