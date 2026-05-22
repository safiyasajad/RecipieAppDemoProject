import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:newproject/login.dart';

void main() {
  testWidgets('Login page shows auth controls', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Login()));

    expect(find.text('Login Page'), findsOneWidget);
    expect(find.text('Email'), findsWidgets);
    expect(find.text('Password'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('Login page validates empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Login()));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter both email and password'), findsOneWidget);
  });
}
