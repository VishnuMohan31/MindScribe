// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindscribe/main.dart';

void main() {
  testWidgets('MindScribe app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MindScribeApp());

    // Verify that our app loads with the splash screen
    expect(find.text('MindScribe'), findsOneWidget);
    expect(find.text('Your Personal Digital Diary'), findsOneWidget);
  });
}
