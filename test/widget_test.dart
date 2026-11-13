import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mealmap/main.dart';

void main() {
  testWidgets('MealMap App validation and auth test', (WidgetTester tester) async {
    await tester.pumpWidget(const MealMapApp());

    expect(find.text('MealMap'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Student Login'), findsOneWidget);

    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email address'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'student@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.pump();

    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();
  });
}
