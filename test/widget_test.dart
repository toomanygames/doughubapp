import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doughubapp/main.dart';

void main() {
  testWidgets('DougHubApp sign-in screen renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignInPage(),
      ),
    );

    expect(find.text('Welcome to DougHubApp'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
