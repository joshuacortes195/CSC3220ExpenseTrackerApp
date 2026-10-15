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
    setState(() {
      _selectedDate = pickedDate;
    },
    );
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
                        child: TextField(
                          controller: _titleController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            label: Text('Title')
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          // number keyboard
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            // dollar sign in front
                            prefixText: '\$ ',
                            label: Text('Amount')
                          ),
                        ),
                      ),
                    ],
                  )
                else  
                TextField(
                  controller: _titleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    label: Text('Title')
                  ),
                ),
                if (width >= 600)
                  Row(children: [
                    DropdownButton(
                      value: _selectedCategory, // default category which is set to lesiure
                      // makes a dropdown option for every category
                      items: Category.values.
                        map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              category.name.toUpperCase(),
                                ),
                              ),
                            ).toList(),
                        // runs when we pick a category
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          // saves the category and updates the screen
                          setState(() {
                            _selectedCategory = value;
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // shows the date, or a message if user hasnt picked one
                            Text(_selectedDate == null? 'No Date Selected' : formatter.format(_selectedDate!)),
                            IconButton(
                              // opens the calendar
                              onPressed: _presentDatePicker,
                              icon: const Icon(
                                Icons.calendar_month,
                            )
                          ),
                        ],
                      ),
                    )
                  ],
                )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          // number keyboard
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            // dollar sign in front
                            prefixText: '\$ ',
                            label: Text('Amount')
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // shows the date, or a message if user hasnt picked one
                            Text(_selectedDate == null? 'No Date Selected' : formatter.format(_selectedDate!)),
                            IconButton(
                              // opens the calendar
                              onPressed: _presentDatePicker,
                              icon: const Icon(
                                Icons.calendar_month,
                              )
                            ),
                          ],
                        ),
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
                        child: const Text('Save Express'),
                      ),
                    ])
                  else
                    // category dropdown and the buttons
                    Row(children: [  
                      DropdownButton(
                        value: _selectedCategory, // default category which is set to lesiure
                        // makes a dropdown option for every category
                        items: Category.values.
                          map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category.name.toUpperCase(),
                                  ),
                                ),
                              ).toList(),
                          // runs when we pick a category
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            // saves the category and updates the screen
                            setState(() {
                              _selectedCategory = value;
                            },
                          );
                        },
                      ),
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
                        child: const Text('Save Express'),
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
