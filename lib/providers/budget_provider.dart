import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';

const _uuid = Uuid();

final budgetBoxProvider = Provider<Box<BudgetModel>>((ref) {
  return Hive.box<BudgetModel>('budgets');
});

final budgetsProvider =
    StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  final box = ref.watch(budgetBoxProvider);
  return BudgetNotifier(box);
});

class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  final Box<BudgetModel> _box;

  BudgetNotifier(this._box) : super(_box.values.toList());

  void addBudget({
    required String category,
    required double limit,
    required String period,
  }) {
    final budget = BudgetModel(
      id: _uuid.v4(),
      category: category,
      limit: limit,
      period: period,
    );
    _box.put(budget.id, budget);
    state = _box.values.toList();
  }

  void deleteBudget(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  BudgetModel? getBudgetForCategory(String category) {
    try {
      return state.firstWhere((b) => b.category == category);
    } catch (_) {
      return null;
    }
  }
}