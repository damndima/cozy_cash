import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

final isPremiumProvider = StateProvider<bool>((ref) {
  return Hive.box('settings').get('is_premium', defaultValue: false);
});

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '✦ CozyCash ✦',
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
                      child: const Text('✕',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              if (isPremium) ...[
                // Already premium
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You\'re Premium!',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thank you for supporting CozyCash.\nAll features are unlocked.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ] else ...[
                // Premium pitch
                const Text(
                  'Go Premium',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$1 / week',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 40),

                // Features list
                _FeatureRow(
                  icon: '📊',
                  title: 'Home screen widgets',
                  subtitle: 'Quick access to your balance and spending',
                ),
                const SizedBox(height: 20),
                _FeatureRow(
                  icon: '🎯',
                  title: 'Budget limits',
                  subtitle: 'Set spending limits per category',
                ),
                const SizedBox(height: 20),
                _FeatureRow(
                  icon: '🏦',
                  title: 'Multiple accounts',
                  subtitle: 'Track cash, cards and savings separately',
                ),
                const SizedBox(height: 20),
                _FeatureRow(
                  icon: '♾️',
                  title: 'Unlimited history',
                  subtitle: 'Access all your past transactions',
                ),
                const SizedBox(height: 20),
                _FeatureRow(
                  icon: '📋',
                  title: 'Subscription tracker',
                  subtitle: 'Track all your subscriptions and billing dates',
                ),

                const SizedBox(height: 48),

                // Subscribe button
                GestureDetector(
                  onTap: () => _subscribe(context, ref),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Subscribe — \$1 / week',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Restore
                GestureDetector(
                  onTap: () => _restore(context, ref),
                  child: const Center(
                    child: Text(
                      'Restore purchase',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Cancel anytime. Billed weekly.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
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

  void _subscribe(BuildContext context, WidgetRef ref) {
    // В реальному застосунку тут буде In-App Purchase
    // Для демо просто активуємо преміум
    Hive.box('settings').put('is_premium', true);
    ref.read(isPremiumProvider.notifier).state = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Welcome to Premium! 🎉'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _restore(BuildContext context, WidgetRef ref) {
    final isPremium =
        Hive.box('settings').get('is_premium', defaultValue: false);
    if (isPremium) {
      ref.read(isPremiumProvider.notifier).state = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase restored! 🎉'),
          backgroundColor: AppColors.accent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No previous purchase found.'),
        ),
      );
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}