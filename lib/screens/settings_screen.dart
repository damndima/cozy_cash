import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import 'premium_screen.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/budget_model.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_provider.dart';
import '../screens/onboarding_screen.dart';

const List<Map<String, String>> kCurrencies = [
  {'symbol': '\$', 'name': 'USD — US Dollar'},
  {'symbol': '€', 'name': 'EUR — Euro'},
  {'symbol': '₴', 'name': 'UAH — Ukrainian Hryvnia'},
  {'symbol': '£', 'name': 'GBP — British Pound'},
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);

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
                      '✦ Settings ✦',
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

              const SizedBox(height: 40),

              // PREMIUM
              const Text(
                'PREMIUM',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _ActionRow(
                  label: 'Go Premium ✦  \$1 / week',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PremiumScreen()),
                  ),
                  showDivider: false,
                  color: AppColors.accent,
                ),
              ),

              const SizedBox(height: 32),

              // CURRENCY
              const Text(
                'CURRENCY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: kCurrencies.map((c) {
                    final isSelected = currency == c['symbol'];
                    final isLast = c == kCurrencies.last;
                    return GestureDetector(
                      onTap: () => ref
                          .read(currencyProvider.notifier)
                          .state = c['symbol']!,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                    color: AppColors.background,
                                    width: 1,
                                  ),
                                ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c['name']!,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppColors.accent,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // HELP US IMPROVE
              const Text(
                'HELP US IMPROVE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _ActionRow(
                      label: 'Buy us a coffee ☕',
                      onTap: () {},
                      showDivider: true,
                    ),
                    _ActionRow(
                      label: 'Report a Bug 🐛',
                      onTap: () {},
                      showDivider: true,
                    ),
                    _ActionRow(
                      label: 'Review on the App Store ⭐',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // DATA
              const Text(
                'DATA',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _ActionRow(
                  label: 'Clear all data',
                  onTap: () => _confirmClear(context, ref),
                  showDivider: false,
                  color: AppColors.accentRed,
                ),
              ),

              const Spacer(),

              const Center(
                child: Text(
                  'CozyCash v1.0.0',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Clear all data?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will delete all transactions, accounts and budgets. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final txBox = Hive.box<TransactionModel>('transactions');
              final accBox = Hive.box<AccountModel>('accounts');
              final budBox = Hive.box<BudgetModel>('budgets');
              final subBox = Hive.box<SubscriptionModel>('subscriptions');
              final settings = Hive.box('settings');

              await txBox.clear();
              await accBox.clear();
              await budBox.clear();
              await subBox.clear();
              await settings.clear(); // скидає і преміум і онбординг

              ref.invalidate(transactionsProvider);
              ref.invalidate(accountsProvider);
              ref.invalidate(budgetsProvider);
              ref.invalidate(subscriptionsProvider);
              ref.invalidate(isPremiumProvider);

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool showDivider;
  final Color color;

  const _ActionRow({
    required this.label,
    required this.onTap,
    required this.showDivider,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(
                    color: AppColors.background,
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(color: color, fontSize: 15)),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}