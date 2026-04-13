import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import 'category_detail_screen.dart';

enum PeriodFilter { today, week, month, year, allTime }

extension PeriodFilterLabel on PeriodFilter {
  String get label {
    switch (this) {
      case PeriodFilter.today:
        return 'Today';
      case PeriodFilter.week:
        return 'Week';
      case PeriodFilter.month:
        return 'Month';
      case PeriodFilter.year:
        return 'Year';
      case PeriodFilter.allTime:
        return 'All Time';
    }
  }
}

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  PeriodFilter _period = PeriodFilter.month;

  DateTime _getFrom() {
    final now = DateTime.now();
    switch (_period) {
      case PeriodFilter.today:
        return DateTime(now.year, now.month, now.day);
      case PeriodFilter.week:
        return now.subtract(const Duration(days: 7));
      case PeriodFilter.month:
        return DateTime(now.year, now.month, 1);
      case PeriodFilter.year:
        return DateTime(now.year, 1, 1);
      case PeriodFilter.allTime:
        return DateTime(2000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final budgets = ref.watch(budgetsProvider);
    final from = _getFrom();

    final filtered = transactions.where(
      (t) => t.isExpense && t.date.isAfter(from),
    );

    final Map<String, double> categoryTotals = {};
    for (final t in filtered) {
      categoryTotals[t.category] =
          (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sorted.isNotEmpty ? sorted.first.key : null;

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
                      '✦ Categories ✦',
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
                        style:
                            TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),

              const Spacer(),

              // Top category
              if (topCategory != null) ...[
                const Text(
                  'Most of all spent on',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  topCategory,
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Period filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: PeriodFilter.values.map((p) {
                    final selected = _period == p;
                    return GestureDetector(
                      onTap: () => setState(() => _period = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          p.label,
                          style: TextStyle(
                            color: selected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Category list
              if (sorted.isEmpty)
                const Text(
                  'No expenses for this period',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                )
              else
                ...sorted.map((entry) {
                  final budget = budgets
                      .where((b) => b.category == entry.key)
                      .isNotEmpty
                      ? budgets.firstWhere((b) => b.category == entry.key)
                      : null;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(
                          category: entry.key,
                        ),
                      ),
                    ),
                    child: _CategoryItem(
                      category: entry.key,
                      amount: entry.value,
                      budgetLimit: budget?.limit,
                    ),
                  );
                }),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String category;
  final double amount;
  final double? budgetLimit;

  const _CategoryItem({
    required this.category,
    required this.amount,
    this.budgetLimit,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final hasLimit = budgetLimit != null && budgetLimit! > 0;
    final progress = hasLimit ? (amount / budgetLimit!).clamp(0.0, 1.0) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                '-\$${fmt.format(amount)}',
                style: const TextStyle(
                  color: AppColors.accentRed,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (hasLimit) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.card,
                color: progress! >= 1.0
                    ? AppColors.accentRed
                    : AppColors.accent,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${fmt.format(amount)} / \$${fmt.format(budgetLimit!)}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}