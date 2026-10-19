import 'package:flutter_test/flutter_test.dart';

import 'package:mealmap/main.dart';

void main() {
  testWidgets('MealMap App Firebase auth flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MealMapApp());

    // Verify Welcome Screen is present.
    expect(find.text('MealMap'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap Get Started to navigate to Auth Screen.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Auth Screen is present.
    expect(find.text('Welcome Back!'), findsOneWidget);

    // Tap Log In button to proceed to Home.
    await tester.tap(find.text('Log In with Firebase'));
    await tester.pumpAndSettle();

    // Verify Home Screen elements are present.
    expect(find.text('Eateries Near ACES Tagum College'), findsOneWidget);
  });
}
