import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker_app/expenses.dart';

void main() {
  // L4: checks the 7 day switch hides the older expenses
  testWidgets('7 day toggle filters out older expenses', (WidgetTester tester) async {
    // wider test screen so the long date text on the cards fits
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // loads the main screen with the same card margin our app theme uses
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          cardTheme: const CardThemeData(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        home: const Expenses(),
      ),
    );

    // everything shows before the filter is on
    expect(find.text('Flutter Course'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);

    // flips the switch on
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // older one is gone, today's one is still there
    expect(find.text('Groceries'), findsNothing);
    expect(find.text('Flutter Course'), findsOneWidget);
  });
}
