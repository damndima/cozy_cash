import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription_model.dart';

const _uuid = Uuid();

final subscriptionBoxProvider = Provider<Box<SubscriptionModel>>((ref) {
  return Hive.box<SubscriptionModel>('subscriptions');
});

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionNotifier, List<SubscriptionModel>>(
        (ref) {
  final box = ref.watch(subscriptionBoxProvider);
  return SubscriptionNotifier(box);
});

class SubscriptionNotifier extends StateNotifier<List<SubscriptionModel>> {
  final Box<SubscriptionModel> _box;

  SubscriptionNotifier(this._box) : super(_box.values.toList());

  void addSubscription({
    required String name,
    required double amount,
    required String emoji,
    required int billingDay,
    required String currency,
  }) {
    final sub = SubscriptionModel(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      emoji: emoji,
      billingDay: billingDay,
      currency: currency,
    );
    _box.put(sub.id, sub);
    state = _box.values.toList();
  }

  void deleteSubscription(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  double getTotalMonthly() {
    return state.fold(0, (sum, s) => sum + s.amount);
  }
}