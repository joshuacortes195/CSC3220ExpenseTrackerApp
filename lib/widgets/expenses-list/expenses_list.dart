import 'package:expense_tracker_app/model/expense.dart';
import 'package:expense_tracker_app/widgets/expenses-list/expense_item.dart';
import 'package:flutter/material.dart';

// the scrollable list of expenses
class ExpensesList extends StatelessWidget {
  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onRemoveExpense,
    });

  // the expenses we got from the main screen
  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;

  // syling of how the list will look 
  @override
  Widget build (BuildContext context) {
    return ListView.builder(
      // how many items are in the list
      itemCount: expenses.length,
      // makes a card for each expense
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(expenses[index]),
        background: Container(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75),
          // lines the red background up with the card
          margin: EdgeInsets.symmetric(
            horizontal: Theme.of(context).cardTheme.margin!.horizontal,
          ),
        ),
        onDismissed: (direction) {
          onRemoveExpense(expenses[index]);
        },
        child: ExpenseItem
          (expenses[index],
        ),
      ),
    );
  }
}
