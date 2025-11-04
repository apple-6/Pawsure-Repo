// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pawsure_app/main.dart';

void main() {
  testWidgets('Pawsure app navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PawsureApp());

    // Verify that our app shows the home screen
    expect(find.text('Home Dashboard'), findsOneWidget);
    expect(find.text('Welcome to Pawsure!'), findsOneWidget);

    // Test navigation to health screen
    await tester.tap(find.text('Health'));
    await tester.pump();

    // Verify that we're on the health screen
    expect(find.text('Pet Health'), findsOneWidget);
    expect(find.text('Track your pet\'s health records'), findsOneWidget);
  });
}
