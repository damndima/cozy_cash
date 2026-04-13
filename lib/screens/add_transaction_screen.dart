import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_theme.dart';

const List<String> kCategories = [
  'Food',
  'Transport',
  'Entertainment',
  'Salary',
  'Health',
  'Shopping',
  'Subscriptions',
  'Other',
];

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = kCategories[0];
  bool _isExpense = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final accounts = ref.read(accountsProvider);
    if (accounts.isEmpty) return;

    final accountId = accounts.first.id;

    ref.read(transactionsProvider.notifier).addTransaction(
          title: _titleController.text.isEmpty
              ? _selectedCategory
              : _titleController.text,
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
          isExpense: _isExpense,
          accountId: accountId,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );

    ref
        .read(accountsProvider.notifier)
        .updateBalance(accountId, amount, _isExpense);

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 300) {
              Navigator.pop(context);
            }
          },
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
                      'Add transaction',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('• • •',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                    ),
                  ],
                ),

                const Spacer(),

                // SAVE button
                GestureDetector(
                  onTap: _save,
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Income / Expense toggle
                Row(
                  children: [
                    _TypeButton(
                      label: 'Expense',
                      selected: _isExpense,
                      color: AppColors.accentRed,
                      onTap: () => setState(() => _isExpense = true),
                    ),
                    const SizedBox(width: 12),
                    _TypeButton(
                      label: 'Income',
                      selected: !_isExpense,
                      color: AppColors.accent,
                      onTap: () => setState(() => _isExpense = false),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Amount
                _FieldRow(
                  label: 'Amount',
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '\$',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Category
                _FieldRow(
                  label: 'Category',
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: AppColors.card,
                    underline: const SizedBox(),
                    isDense: true,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 16),
                    items: kCategories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v!),
                  ),
                ),

                const SizedBox(height: 16),

                // Note
                _FieldRow(
                  label: 'Note',
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Optional',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Date
                _FieldRow(
                  label: 'Date',
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      DateFormat('dd.MM.yyyy').format(_selectedDate),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 16),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}