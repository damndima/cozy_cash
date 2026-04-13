import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';

class BalanceScreen extends ConsumerWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountsProvider);

    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);

    final incomeThisMonth = transactions
        .where((t) => !t.isExpense && t.date.isAfter(firstOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);

    final expensesThisMonth = transactions
        .where((t) => t.isExpense && t.date.isAfter(firstOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalBalance = accounts.fold(0.0, (sum, a) => sum + a.balance);
    final saved = incomeThisMonth - expensesThisMonth;

    final fmt = NumberFormat('#,##0.00');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      '✦ Balance ✦',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('• • •',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),

              const Spacer(),

              // You Have
              const Text(
                'YOU HAVE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${fmt.format(totalBalance)}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 48),

              // Accounts row
              if (accounts.length > 1) ...[
                const Text(
                  'ACCOUNTS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                ...accounts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(a.icon,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Text(
                                a.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${fmt.format(a.balance)}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 32),
              ],

              // Stats
              _StatRow(
                label: 'Income this month',
                value: '\$${fmt.format(incomeThisMonth)}',
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
              _StatRow(
                label: 'Expenses',
                value: '-\$${fmt.format(expensesThisMonth)}',
                color: AppColors.accentRed,
              ),
              const SizedBox(height: 16),
              _StatRow(
                label: 'Saved',
                value: '\$${fmt.format(saved < 0 ? 0 : saved)}',
                color: saved >= 0 ? AppColors.accent : AppColors.accentRed,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}