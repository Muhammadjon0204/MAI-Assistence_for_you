import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mai_app/main.dart';

void main() {
  testWidgets('MAI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MAIApp());

    // Verify that MAI title is present
    expect(find.text('MAI'), findsOneWidget);
    expect(find.text('Math AI Assistant'), findsOneWidget);
  });
}
