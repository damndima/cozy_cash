import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction_model.dart';
import 'models/account_model.dart';
import 'models/budget_model.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'models/subscription_model.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(AccountModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());
  Hive.registerAdapter(SubscriptionModelAdapter());
  await Hive.openBox<SubscriptionModel>('subscriptions');

  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<AccountModel>('accounts');
  await Hive.openBox<BudgetModel>('budgets');
  await Hive.openBox('settings');
  await SubscriptionService.processSubscriptions();

  runApp(
    const ProviderScope(
      child: CozyCashApp(),
    ),
  );
}

class CozyCashApp extends StatelessWidget {
  const CozyCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingDone =
        Hive.box('settings').get('onboarding_done', defaultValue: false);

    return MaterialApp(
      title: 'CozyCash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: onboardingDone ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}