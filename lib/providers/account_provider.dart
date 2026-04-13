import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/account_model.dart';

const _uuid = Uuid();

final currencyProvider = StateProvider<String>((ref) => '₴');

final accountBoxProvider = Provider<Box<AccountModel>>((ref) {
  return Hive.box<AccountModel>('accounts');
});

final accountsProvider =
    StateNotifierProvider<AccountNotifier, List<AccountModel>>((ref) {
  final box = ref.watch(accountBoxProvider);
  return AccountNotifier(box);
});

final selectedAccountProvider = StateProvider<String?>((ref) => null);

class AccountNotifier extends StateNotifier<List<AccountModel>> {
  final Box<AccountModel> _box;

  AccountNotifier(this._box) : super(_box.values.toList()) {
    if (state.isEmpty) _createDefaultAccount();
  }

  void _createDefaultAccount() {
    addAccount(name: 'Cash', balance: 0, currency: '₴', icon: '💵');
  }

  void addAccount({
    required String name,
    required double balance,
    required String currency,
    required String icon,
  }) {
    final account = AccountModel(
      id: _uuid.v4(),
      name: name,
      balance: balance,
      currency: currency,
      icon: icon,
    );
    _box.put(account.id, account);
    state = _box.values.toList();
  }

  void updateBalance(String id, double amount, bool isExpense) {
    final account = _box.get(id);
    if (account == null) return;
    account.balance += isExpense ? -amount : amount;
    account.save();
    state = _box.values.toList();
  }

  double getTotalBalance() {
    return state.fold(0, (sum, a) => sum + a.balance);
  }
}