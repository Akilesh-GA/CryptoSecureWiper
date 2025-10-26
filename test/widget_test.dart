import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:securewipe/main.dart';

void main() {
  testWidgets('App launches and navigates correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const SecureWipeApp());

    // Verify WelcomePage is displayed
    expect(find.text('Secure Wipe'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap "Get Started" → should navigate to LoginScreen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    // Enter username and password
    await tester.enterText(find.byType(TextField).at(0), 'user');
    await tester.enterText(find.byType(TextField).at(1), 'password');

    // Tap Login → should navigate to DashboardScreen
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify DashboardScreen is displayed
    expect(find.textContaining('Used:'), findsOneWidget);
    expect(find.textContaining('Free:'), findsOneWidget);
    expect(find.text('Start Crypto Erase'), findsOneWidget);
  });
}
