import 'package:flutter_test/flutter_test.dart';
import 'package:farmer/main.dart';

void main() {
  testWidgets('App smoke test and navigation verification', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnvayaFarmerApp());

    // 1. Verify Splash Screen
    expect(find.text('Get Started'), findsOneWidget);

    // 2. Tap "Get Started" and navigate to Login Screen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Email/ID'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Metamask'), findsOneWidget);

    // 3. Test empty validation on Login
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Please enter your Email or ID'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // 4. Navigate from Login to Sign Up Screen
    await tester.tap(find.text('Sing up'));
    await tester.pumpAndSettle();

    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);

    // 5. Fill registration fields and submit to go to Home Dashboard
    await tester.enterText(find.widgetWithText(dynamic, 'First Name').last, 'Jane');
    await tester.enterText(find.widgetWithText(dynamic, 'Last Name').last, 'Doe');
    await tester.enterText(find.widgetWithText(dynamic, 'Email').last, 'jane@anvaya.farm');
    await tester.enterText(find.widgetWithText(dynamic, 'Password').last, 'password123');
    await tester.pump();

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // 6. Verify History Screen is default active tab
    expect(find.text('Produce History'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Organic Arabica Coffee'), findsOneWidget);
  });
}
