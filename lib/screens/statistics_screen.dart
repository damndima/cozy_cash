import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';
import '../providers/subscription_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool _showExpenses = true;
  String _comparisonPeriod = 'TODAY';

  final List<String> _periods = [
    'TODAY',
    'THIS WEEK',
    'THIS MONTH',
    'THIS YEAR'
  ];

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final currency = ref.watch(currencyProvider);
    final subscriptions = ref.watch(subscriptionsProvider);
    final now = DateTime.now();

    // Chart — останні 6 місяців
    final List<FlSpot> spots = [];
    final List<String> monthLabels = [];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);
      final total = transactions
          .where((t) =>
              t.isExpense == _showExpenses &&
              t.date.isAfter(month) &&
              t.date.isBefore(nextMonth))
          .fold(0.0, (sum, t) => sum + t.amount);
      spots.add(FlSpot((5 - i).toDouble(), total));
      monthLabels.add(DateFormat('MMM').format(month));
    }

    // Порівняння за обраним періодом
    DateTime currentFrom;
    DateTime previousFrom;
    DateTime previousTo;

    switch (_comparisonPeriod) {
      case 'THIS WEEK':
        currentFrom = now.subtract(const Duration(days: 7));
        previousTo = currentFrom;
        previousFrom = now.subtract(const Duration(days: 14));
        break;
      case 'THIS MONTH':
        currentFrom = DateTime(now.year, now.month, 1);
        previousTo = currentFrom;
        previousFrom = DateTime(now.year, now.month - 1, 1);
        break;
      case 'THIS YEAR':
        currentFrom = DateTime(now.year, 1, 1);
        previousTo = currentFrom;
        previousFrom = DateTime(now.year - 1, 1, 1);
        break;
      default: // TODAY
        currentFrom = DateTime(now.year, now.month, now.day);
        previousTo = currentFrom;
        previousFrom = currentFrom.subtract(const Duration(days: 1));
    }

    final currentSpent = transactions
        .where((t) => t.isExpense && t.date.isAfter(currentFrom))
        .fold(0.0, (sum, t) => sum + t.amount);

    final previousSpent = transactions
        .where((t) =>
            t.isExpense &&
            t.date.isAfter(previousFrom) &&
            t.date.isBefore(previousTo))
        .fold(0.0, (sum, t) => sum + t.amount);

    final spentMore = currentSpent > previousSpent;

    final firstOfMonth = DateTime(now.year, now.month, 1);

    final transactionExpenses = transactions
    .where((t) => t.isExpense && t.date.isAfter(firstOfMonth))
    .fold(0.0, (sum, t) => sum + t.amount);

    final subscriptionsMonthly =
      subscriptions.fold(0.0, (sum, s) => sum + s.amount);

    final thisMonthExpenses = transactionExpenses + subscriptionsMonthly;

    final thisMonthIncome = transactions
        .where((t) => !t.isExpense && t.date.isAfter(firstOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);

    final fmt = NumberFormat('#,##0.00');
    final maxY =
        spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);

    final previousLabel = {
      'TODAY': 'YESTERDAY',
      'THIS WEEK': 'LAST WEEK',
      'THIS MONTH': 'LAST MONTH',
      'THIS YEAR': 'LAST YEAR',
    }[_comparisonPeriod]!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                      '✦ Statistics ✦',
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
                        style: TextStyle(
                            color: AppColors.textSecondary)),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Клікабельний період + spent more/less
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  GestureDetector(
                    onTap: () => _showPeriodPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _comparisonPeriod,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.accent, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const Text('spent',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  Text(
                    spentMore ? 'MORE' : 'LESS',
                    style: TextStyle(
                      color: spentMore
                          ? AppColors.accentRed
                          : AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'than $previousLabel',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '$currency${fmt.format(currentSpent)}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                  const Text(' vs ',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                  Text(
                    '$currency${fmt.format(previousSpent)}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Toggle Expenses / Income
              Row(
                children: [
                  _ToggleBtn(
                    label: 'Expenses',
                    selected: _showExpenses,
                    color: AppColors.accentRed,
                    onTap: () => setState(() => _showExpenses = true),
                  ),
                  const SizedBox(width: 12),
                  _ToggleBtn(
                    label: 'Income',
                    selected: !_showExpenses,
                    color: AppColors.accent,
                    onTap: () => setState(() => _showExpenses = false),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Chart
              SizedBox(
                height: 200,
                child: maxY == 0
                    ? const Center(
                        child: Text('No data yet',
                            style: TextStyle(
                                color: AppColors.textMuted)))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: AppColors.card,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 ||
                                      idx >= monthLabels.length) {
                                    return const SizedBox();
                                  }
                                  return Text(monthLabels[idx],
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: _showExpenses
                                  ? AppColors.accentRed
                                  : AppColors.accent,
                              barWidth: 2.5,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar,
                                        index) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: _showExpenses
                                      ? AppColors.accentRed
                                      : AppColors.accent,
                                  strokeWidth: 0,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: (_showExpenses
                                        ? AppColors.accentRed
                                        : AppColors.accent)
                                    .withOpacity(0.08),
                              ),
                            ),
                          ],
                          minY: 0,
                          maxY: maxY * 1.2,
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              const Text(
                'THIS MONTH',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Expenses',
                      value:
                          '$currency${fmt.format(thisMonthExpenses)}',
                      color: AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Income',
                      value: '$currency${fmt.format(thisMonthIncome)}',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPeriodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _periods.map((p) {
            final selected = _comparisonPeriod == p;
            return GestureDetector(
              onTap: () {
                setState(() => _comparisonPeriod = p);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: Text(
                  p,
                  style: TextStyle(
                    color: selected
                        ? AppColors.accent
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}