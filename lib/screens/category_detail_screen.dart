import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState
    extends ConsumerState<CategoryDetailScreen> {
  String _period = 'Today';
  final List<String> _periods = ['Today', 'Week', 'Month', 'Year', 'All Time'];

  DateTime _getFrom() {
    final now = DateTime.now();
    switch (_period) {
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'Week':
        return now.subtract(const Duration(days: 7));
      case 'Month':
        return DateTime(now.year, now.month, 1);
      case 'Year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(2000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final from = _getFrom();

    final filtered = transactions
        .where((t) =>
            t.category == widget.category &&
            t.isExpense &&
            t.date.isAfter(from))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final total =
        filtered.fold(0.0, (sum, t) => sum + t.amount);

    final fmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat('dd.MM.yyyy');

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 300) {
              Navigator.pop(context);
            } else if (details.primaryVelocity! < -300) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTransactionScreen(),
                ),
              );
            }
          },
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
                      child: Text(
                        '✦ ${widget.category} ✦',
                        style: const TextStyle(
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
                          style: TextStyle(
                              color: AppColors.textSecondary)),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Period filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods.map((p) {
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
                            p,
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

                // Total
                Text(
                  _period,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '-\$${fmt.format(total)}',
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Transaction list
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final t = filtered[i];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        dateFmt.format(t.date),
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '-\$${fmt.format(t.amount)}',
                                    style: const TextStyle(
                                      color: AppColors.accentRed,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}