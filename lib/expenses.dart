import 'package:expense_tracker_app/widgets/expenses-list/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker_app/model/expense.dart';
import 'package:expense_tracker_app/widgets/expenses-list/expenses_list.dart';
import 'package:expense_tracker_app/widgets/chart/chart.dart';

// main screen of the app
class Expenses extends StatefulWidget {
  const Expenses({super.key});

  // hooks the screen up to its state
  @override
  State<Expenses> createState(){
    return _ExpensesState();
  }
}

// everything that can change on the main screen
class _ExpensesState extends State<Expenses> {
  // our expenses, starts with two example ones
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Flutter Course',
      amount: 19.99,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'Cinema',
      amount: 15.69,
      date: DateTime.now(),
      category: Category.leisure,
    ),
  ];

  // opens the add expense form 
  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      // lets the form take the top of the screen
      isScrollControlled: true,
      context: context,
      // what shows inside the sheet
      builder: (ctx) => NewExpense(onAddExpense: _addExpense,),
    );
  }

  // adds a new expense to our list
  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.add(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          }
        )
      ),
    );
  }

  // what the main screen looks like
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ExpenseTracker'),
        actions: [
          IconButton(
            // opens the form when tapped
            onPressed: _openAddExpenseOverlay,
            icon : const Icon(Icons.add),
          ),
        ],
      ),
      body: width < 600 ? Column(
        children: [
          Chart(expenses: _registeredExpenses,),
          Expanded (
            child: mainContent,
          ),
        ],
      )
      : Row(children: [
        Expanded(
          child: Chart(expenses: _registeredExpenses),
        ),
        Expanded(
          child: mainContent,
          ),
        ],
      ),
    );
  }
}
