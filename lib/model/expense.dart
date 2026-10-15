import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// how our dates look, month/day/year
final formatter = DateFormat.yMd();

// id generator
const uuid = Uuid();

// the categories for what category the expense might fall into 
enum Category {food, travel, leisure, work}

// which icon goes with which category
const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie,
  Category.work: Icons.work
};

// what one expense looks 
class Expense {
  // Everything the expense might include
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = uuid.v4(); // every expense gets its own id

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  // gives the date as readable text
  String get formattedDate {
    return formatter.format(date);
  }
}

class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
    : expenses = allExpenses
      .where((expense) => expense.category == category)
      .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount; //sum = sum + expense.amount
    }

    return sum;
  }
}
