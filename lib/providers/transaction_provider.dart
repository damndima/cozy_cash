import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

const _uuid = Uuid();

final transactionBoxProvider = Provider<Box<TransactionModel>>((ref) {
  return Hive.box<TransactionModel>('transactions');
});

final transactionsProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final box = ref.watch(transactionBoxProvider);
  return TransactionNotifier(box);
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final Box<TransactionModel> _box;

  TransactionNotifier(this._box) : super(_box.values.toList());

  void addTransaction({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isExpense,
    required String accountId,
    String? note,
  }) {
    final transaction = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      isExpense: isExpense,
      accountId: accountId,
      note: note,
    );
    _box.put(transaction.id, transaction);
    state = _box.values.toList();
  }

  void deleteTransaction(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  List<TransactionModel> getByCategory(String category) {
    return state.where((t) => t.category == category).toList();
  }

  List<TransactionModel> getByDateRange(DateTime from, DateTime to) {
    return state.where((t) =>
      t.date.isAfter(from) && t.date.isBefore(to)
    ).toList();
  }

  double getTotalExpenses() {
    return state
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalIncome() {
    return state
        .where((t) => !t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }
}