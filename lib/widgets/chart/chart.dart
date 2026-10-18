// L5: this whole file is new, it swaps the old hand built bars for an fl_chart donut
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:expense_tracker_app/model/expense.dart';

// L5: which color each category gets in the donut and legend
final categoryColors = {
  Category.food: Colors.orange.shade400,
  Category.travel: Colors.blue.shade400,
  Category.leisure: Colors.purple.shade300,
  Category.work: Colors.teal.shade400,
};

// L5: donut chart showing how much we spent in each category
class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  // kept from the old chart: groups the expenses into one bucket per category
  List<ExpenseBucket> get buckets {
    return [
      ExpenseBucket.forCategory(expenses, Category.food),
      ExpenseBucket.forCategory(expenses, Category.leisure),
      ExpenseBucket.forCategory(expenses, Category.travel),
      ExpenseBucket.forCategory(expenses, Category.work),
    ];
  }

  // L5: adds up every bucket so we can work out percentages
  double get totalSpent {
    double sum = 0;

    for (final bucket in buckets) {
      sum += bucket.totalExpenses;
    }

    return sum;
  }

  // L5: makes one donut slice for each category that has money in it
  List<PieChartSectionData> get sections {
    final total = totalSpent;

    return [
      for (final bucket in buckets)
        if (bucket.totalExpenses > 0)
          PieChartSectionData(
            value: bucket.totalExpenses,
            color: categoryColors[bucket.category],
            radius: 36,
            // the percent written on the slice
            title: '${(bucket.totalExpenses / total * 100).round()}%',
            // hides the label on tiny slices so it doesn't overlap
            showTitle: bucket.totalExpenses / total >= 0.08,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
    ];
  }

  // what the chart box looks like
  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      width: double.infinity,
      height: 180,
      // kept from the old chart: same faded background
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.primary.withOpacity(0.0)
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      // L5: donut on the left, legend on the right
      child: Row(
        children: [
          SizedBox(
            width: 140,
            // L5: shows a message instead of an empty donut
            child: totalSpent == 0
                ? const Center(child: Text('No data'))
                : PieChart(
                    PieChartData(
                      sections: sections,
                      // the hole in the middle that makes it a donut
                      centerSpaceRadius: 28,
                      // little gap between slices
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // L5: the legend, one row per category
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final bucket in buckets)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        // color dot that matches the slice
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: categoryColors[bucket.category],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // category icon, same coloring as the old chart
                        Icon(
                          categoryIcons[bucket.category],
                          size: 18,
                          color: isDarkMode
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        // category name
                        Expanded(
                          child: Text(
                            bucket.category.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        // how much we spent in this category
                        Text(
                          '\$${bucket.totalExpenses.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
