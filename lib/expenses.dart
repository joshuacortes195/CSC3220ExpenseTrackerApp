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
  // our expenses, starts with four example ones
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
    // L4: older examples so the 7 day filter has something to hide
    Expense(
      title: 'Groceries',
      amount: 42.30,
      date: DateTime.now().subtract(const Duration(days: 10)),
      category: Category.food,
    ),
    Expense(
      title: 'Train Ticket',
      amount: 27.50,
      date: DateTime.now().subtract(const Duration(days: 12)),
      category: Category.travel,
    ),
  ];

  // L4: whether we only show the last 7 days, off by default
  bool _showLast7DaysOnly = false;

  // L4: the expenses that pass the filter, this is what the chart and list show
  List<Expense> get _visibleExpenses {
    if (!_showLast7DaysOnly) {
      return _registeredExpenses;
    }
    final now = DateTime.now();
    // start of the day 6 days ago, so today plus the 6 days before it
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return _registeredExpenses
        .where((expense) => !expense.date.isBefore(cutoff))
        .toList();
  }

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

  // deletes an expense and gives the option to undo
  void _removeExpense(Expense expense) {
    // remembers where it was so undo can put it back
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      // fix: this used to say add, so swiping never actually deleted anything
      _registeredExpenses.remove(expense);
    });
    // clears any old popup and shows the deleted message with an undo button
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          // puts the expense back where it was
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
    // L4 + L5: grabs the filtered list once so the chart and list match
    final visibleExpenses = _visibleExpenses;

    // L4: empty message changes if the filter is what's hiding everything
    Widget mainContent = Center(
      child: Text(
        _showLast7DaysOnly && _registeredExpenses.isNotEmpty
            ? 'No expenses in the last 7 days.'
            : 'No expenses found. Start adding some!',
      ),
    );

    if (visibleExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: visibleExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    // L4: the switch that turns the 7 day filter on and off
    final filterToggle = SwitchListTile(
      title: const Text('Show last 7 days only'),
      value: _showLast7DaysOnly,
      onChanged: (isOn) {
        // saves the choice and redraws the chart and list
        setState(() {
          _showLast7DaysOnly = isOn;
        });
      },
    );

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
      // L4: portrait stacks chart, toggle and list
      body: width < 600 ? Column(
        children: [
          Chart(expenses: visibleExpenses,),
          filterToggle,
          Expanded (
            child: mainContent,
          ),
        ],
      )
      // L4: landscape puts the chart on the left and toggle plus list on the right
      : Row(children: [
        Expanded(
          child: Chart(expenses: visibleExpenses),
        ),
        Expanded(
          child: Column(
            children: [
              filterToggle,
              Expanded(
                child: mainContent,
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}
