import 'package:flutter/material.dart';

import 'package:expense_tracker_app/model/expense.dart';

// the card for one expense
class ExpenseItem extends StatelessWidget {
  const ExpenseItem(this.expense, {super.key});

  // the expense this card is showing
  final Expense expense;

  // what the card looks like
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        // stacks the title on top of the details
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.title, 
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            // amount on the left, icon and date on the right
            Row(
              children: [
                // the amount with 2 decimals
                Text('\$${expense.amount.toStringAsFixed(2)}'),
                const Spacer(),
                Row(
                  children: [
                    Icon(categoryIcons[expense.category]),
                    const SizedBox(width: 8),
                    Text(expense.date.toString()),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
