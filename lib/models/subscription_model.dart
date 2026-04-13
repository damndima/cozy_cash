import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 3)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String emoji;

  @HiveField(4)
  late int billingDay; // день місяця списання (1-31)

  @HiveField(5)
  late String currency;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.emoji,
    required this.billingDay,
    required this.currency,
  });
}