import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 1)
class AccountModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double balance;

  @HiveField(3)
  late String currency;

  @HiveField(4)
  late String icon;

  AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.icon,
  });
}