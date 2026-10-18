import 'dart:io';

import 'package:flutter/material.dart';
import 'package:expense_tracker_app/model/expense.dart';
import 'package:flutter/cupertino.dart';

// the add expense form
class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  // sends the new expense back to the main screen
  final void Function(Expense expense) onAddExpense;

  // hooks the form up to its state
  @override
  State<StatefulWidget> createState() {
    return _NewExpensesState();
  }
}

// everything that can change on the form
class _NewExpensesState extends State<NewExpense> {
  // holds what the user types for the title
  final _titleController = TextEditingController();
  // holds the amount
  final _amountController = TextEditingController();
  // the date user picked
  DateTime? _selectedDate;
  // the category the user picked, it it leisure by default
  Category _selectedCategory = Category.leisure;

  // opens the calendar
  void _presentDatePicker() async {
    final now = DateTime.now();
    // can only go back one year
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    // waits for us to pick a date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      // earliest date we can pick
      firstDate: firstDate,
      // can't pick a future date
      lastDate: now,
    );
    // saves the date and updates the screen
    if (pickedDate == null) return;
    setState(() {
      _selectedDate = pickedDate;
    },);
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context, 
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
            'Please make sure a valid title, amount, date and category was entered'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
              )
            ],
          ));
    }else {
      // shows the error popup
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
            'Please make sure a valid title, amount, date and category was entered'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
              )
            ],
          )
        );
    }
  }

  // runs when we hit save
  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text); // turns the amount text into a number
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;  // checks for an empty title, bad amount or no date
    if (_titleController.text.trim().isEmpty || amountIsInvalid || _selectedDate == null) { // amount will cause an error if it's not a number or it's 0 or less
      _showDialog();
        // returns here so nothing bad gets saved
      return;
    }
      // builds the expense and sends it to the main screen if it passes the if checkpoint
      widget.onAddExpense(Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
        )
      );
      Navigator.pop(context);
    }

  // cleans up the controllers when the form closes
  @override
  void dispose () {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // new widget turns title field into method for reusability
  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(label: Text('Title')),
    );
  }

  // new widget turns amount field into a method for reusability
  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        prefixText: '\$ ',
        label: Text('Amount')
      ),
    );
  }

  // new widget turns category dropdown into a method for reusability
  Widget _buildCategoryDropdown() {
    return DropdownButton(
      value: _selectedCategory, 
      items: Category.values.
        map(
          (category) => DropdownMenuItem(
            value: category,
            child: Text(
              category.name.toUpperCase(),
            ),
          ),
        ).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedCategory = value;
        },
      );
    },
  );
  }
 
  // new widget turns date text and calendar button into method for reusability
  Widget _buildDateRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(_selectedDate == null? 'No Date Selected' : formatter.format(_selectedDate!)),
        IconButton(
          onPressed: _presentDatePicker,
          icon: const Icon(
            Icons.calendar_month,
          )
        ),
      ],
    );
  }

  // what the form looks like
  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;

      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            // stacks everything top to bottom
            child: Column(
              children: [
                if (width >= 600 )
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTitleField(),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildAmountField(),
                      ),
                    ],
                  )
                else  
                _buildTitleField(),
                if (width >= 600)
                  Row(children: [
                    _buildCategoryDropdown(),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildDateRow(),
                    )
                  ],
                )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _buildAmountField(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateRow(),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  if(width >= 600)
                    Row(children: [
                      const Spacer(),
                      // cancel button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),),
                      // save button
                      ElevatedButton(
                        // checks and saves the expense
                        onPressed: _submitExpenseData,
                        child: const Text('Save Expense'),
                      ),
                    ])
                  else
                    // category dropdown and the buttons
                    Row(children: [  
                      _buildCategoryDropdown(),
                      const Spacer(),
                      // cancel button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),),
                      // save button
                      ElevatedButton(
                        // checks and saves the expense
                        onPressed: _submitExpenseData,
                        child: const Text('Save Expense'),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      );
    });
  }
}
