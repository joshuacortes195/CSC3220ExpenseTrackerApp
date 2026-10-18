import 'package:flutter/material.dart';
import 'package:expense_tracker_app/model/expense.dart';

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
  // new form wrapper
  final _formKey = GlobalKey<FormState>();
  // date is trickier since its not a textfield
  final _dateFieldKey = GlobalKey<FormFieldState<DateTime>>();

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
    _dateFieldKey.currentState?.didChange(pickedDate);
  }

  // runs when we hit save
  void _submitExpenseData() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onAddExpense(Expense(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
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
  // changed to text form field so we can use validators
  // these are ultimately precautionary things so no one can enter nothing in the title field or 2 letters that dont even make a legit title
  // had to add autovalidate to each field seperately or it would trigger all fields without typing in a specific field
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(label: Text('Title')),
      // field checks itself only after user types in it
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        // does not allow a title to be blank or just spaces
        if (value == null || value.trim().length < 2) {
          return 'Title needs to be at least 2 characters.';
        }
        return null;
      },
    );
  }

  // new widget turns amount field into a method for reusability
  // changed keyboard type so decimals can be entered
  // changed to text form field so we can use validators
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      // allowing for decimal points in amount field
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        prefixText: '\$ ',
        label: Text('Amount'),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        // if text isnt a number we get null
        final amount = double.tryParse(value ?? '');
        // simple statements for cases where amount isnt correctly entered
        if (amount == null) {
          return 'Enter a valid number.';
        }
        if (amount <= 0) {
          return 'Amount must be greater than 0.';
        }
        return null;
      },
    );
  }

  // new widget turns category dropdown into a method for reusability
  // leisure is default so that saved needing a validator
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
  // had to wrap row in FormField<DateTime>
  // this was the hardest part since flutter has not date form field we made our own
  // it simply holds a date and time runs the validator and if its empty shows an error
  Widget _buildDateRow() {
    return FormField<DateTime>(
      initialValue: _selectedDate,
      key: _dateFieldKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => value == null ? 'Please pick a date.' : null,
      // simply if field has a current it will display what it says
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
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
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        );
      },
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
            child: Form(
              key: _formKey,
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
        ),
      );
    });
  }
}