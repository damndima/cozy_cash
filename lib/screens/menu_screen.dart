import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../screens/balance_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/subscriptions_screen.dart';
import '../screens/premium_screen.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

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
                  const Text(
                    '✦ My Finance ✦',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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

              const Spacer(),

              _MenuItem(
                title: 'Balance',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BalanceScreen()),
                ),
              ),
              _MenuItem(
                title: 'Categories',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CategoriesScreen()),
                ),
              ),
              _MenuItem(
                title: 'Statistics',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StatisticsScreen()),
                ),
              ),

              // Subscriptions — заблоковано без преміум
              _LockedMenuItem(
                title: 'Subscriptions',
                isPremium: isPremium,
                onTap: () {
                  if (isPremium) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionsScreen()),
                    );
                  } else {
                    _showPremiumPrompt(context);
                  }
                },
              ),

              _MenuItem(
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✦ Premium Feature',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Subscription tracking is a Premium feature. Upgrade to track all your monthly subscriptions, see upcoming billing dates and never miss a payment.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PremiumScreen()),
                );
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
                    'Go Premium — \$1 / week',
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
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          '✦ $title ✦',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LockedMenuItem extends StatelessWidget {
  final String title;
  final bool isPremium;
  final VoidCallback onTap;

  const _LockedMenuItem({
    required this.title,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Text(
              '✦ $title ✦',
              style: TextStyle(
                color: isPremium
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isPremium) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.lock_outline,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}