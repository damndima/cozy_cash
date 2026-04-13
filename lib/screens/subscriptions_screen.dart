import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';

// Популярні підписки для швидкого додавання
const List<Map<String, String>> kPopularSubs = [
  {'name': 'Netflix', 'emoji': '🎬'},
  {'name': 'Spotify', 'emoji': '🎵'},
  {'name': 'YouTube Premium', 'emoji': '▶️'},
  {'name': 'Apple Music', 'emoji': '🎧'},
  {'name': 'iCloud', 'emoji': '☁️'},
  {'name': 'ChatGPT', 'emoji': '🤖'},
  {'name': 'Adobe', 'emoji': '🎨'},
  {'name': 'Other', 'emoji': '📦'},
];

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final currency = ref.watch(currencyProvider);
    final fmt = NumberFormat('#,##0.00');
    final totalMonthly = subscriptions.fold(0.0, (sum, s) => sum + s.amount);
    final now = DateTime.now();

    // Сортуємо по даті наступного списання
    final sorted = [...subscriptions]
      ..sort((a, b) => a.billingDay.compareTo(b.billingDay));

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
                      '✦ Subscriptions ✦',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddSheet(context, ref, currency),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: const Text(
                        '+ Add',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              if (subscriptions.isEmpty) ...[
                const Text(
                  'No subscriptions yet.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap "+ Add" to track your\nmonthly subscriptions.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ] else ...[
                // Total
                const Text(
                  'MONTHLY TOTAL',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$currency${fmt.format(totalMonthly)}',
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                // List
                Expanded(
                  child: ListView.builder(
                    itemCount: sorted.length,
                    itemBuilder: (context, i) {
                      final sub = sorted[i];

                      // Наступна дата списання
                      DateTime nextBilling = DateTime(
                          now.year, now.month, sub.billingDay);
                      if (nextBilling.isBefore(now)) {
                        nextBilling = DateTime(
                            now.year, now.month + 1, sub.billingDay);
                      }
                      final daysLeft =
                          nextBilling.difference(now).inDays;

                      return Dismissible(
                        key: Key(sub.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: AppColors.accentRed),
                        ),
                        onDismissed: (_) => ref
                            .read(subscriptionsProvider.notifier)
                            .deleteSubscription(sub.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              // Emoji
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(sub.emoji,
                                      style: const TextStyle(
                                          fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name + billing date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      daysLeft == 0
                                          ? 'Billing today'
                                          : daysLeft == 1
                                              ? 'Tomorrow'
                                              : 'In $daysLeft days',
                                      style: TextStyle(
                                        color: daysLeft <= 3
                                            ? AppColors.accentRed
                                            : AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Amount
                              Text(
                                '$currency${fmt.format(sub.amount)}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSheet(
      BuildContext context, WidgetRef ref, String currency) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dayController = TextEditingController();
    String selectedEmoji = '📦';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Subscription',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Quick select popular
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: kPopularSubs.map((s) {
                    final selected = selectedEmoji == s['emoji'] &&
                        nameController.text == s['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedEmoji = s['emoji']!;
                          nameController.text = s['name']!;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accent.withOpacity(0.15)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(s['emoji']!,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              s['name']!,
                              style: TextStyle(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Name field
              _SheetField(
                label: 'Name',
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Netflix',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Amount
              _SheetField(
                label: 'Amount',
                child: TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: '$currency 0.00',
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Billing day
              _SheetField(
                label: 'Billing day',
                child: TextField(
                  controller: dayController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: '1 – 31',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              GestureDetector(
                onTap: () {
                  final name = nameController.text.isEmpty
                      ? 'Subscription'
                      : nameController.text;
                  final amount = double.tryParse(
                          amountController.text.replaceAll(',', '.')) ??
                      0;
                  final day =
                      int.tryParse(dayController.text)?.clamp(1, 31) ??
                          1;

                  ref
                      .read(subscriptionsProvider.notifier)
                      .addSubscription(
                        name: name,
                        amount: amount,
                        emoji: selectedEmoji,
                        billingDay: day,
                        currency: currency,
                      );
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _SheetField extends StatelessWidget {
  final String label;
  final Widget child;

  const _SheetField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}