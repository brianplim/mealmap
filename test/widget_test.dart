import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mealmap/main.dart';

void main() {
  testWidgets('MealMap App validation and auth test', (WidgetTester tester) async {
    await tester.pumpWidget(const MealMapApp());

    expect(find.text('MealMap'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);

    await tester.tap(find.text('Log In with Firebase'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your student email or ID'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'student@aces.edu.ph');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pump();

    await tester.tap(find.text('Log In with Firebase'));
    await tester.pumpAndSettle();
  });
}
