import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/subscription_model.dart';
import '../models/account_model.dart';

const _uuid = Uuid();

class SubscriptionService {
  static Future<void> processSubscriptions() async {
    final subBox = Hive.box<SubscriptionModel>('subscriptions');
    final txBox = Hive.box<TransactionModel>('transactions');
    final accBox = Hive.box<AccountModel>('accounts');
    final settings = Hive.box('settings');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheck = settings.get('last_subscription_check');

    // Якщо вже перевіряли сьогодні — пропускаємо
    if (lastCheck != null) {
      final lastDate = DateTime.parse(lastCheck);
      if (lastDate.year == today.year &&
          lastDate.month == today.month &&
          lastDate.day == today.day) {
        return;
      }
    }

    final account =
        accBox.values.isNotEmpty ? accBox.values.first : null;
    if (account == null) return;

    for (final sub in subBox.values) {
      // Перевіряємо чи сьогодні день списання
      if (now.day == sub.billingDay) {
        // Перевіряємо чи вже була транзакція сьогодні для цієї підписки
        final alreadyCharged = txBox.values.any((t) =>
            t.title == sub.name &&
            t.category == 'Subscriptions' &&
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day);

        if (!alreadyCharged) {
          // Створюємо транзакцію
          final tx = TransactionModel(
            id: _uuid.v4(),
            title: sub.name,
            amount: sub.amount,
            category: 'Subscriptions',
            date: now,
            isExpense: true,
            accountId: account.id,
            note: 'Auto-charged subscription',
          );
          txBox.put(tx.id, tx);

          // Списуємо з балансу
          account.balance -= sub.amount;
          account.save();
        }
      }
    }

    // Зберігаємо дату перевірки
    settings.put('last_subscription_check', today.toIso8601String());
  }
}