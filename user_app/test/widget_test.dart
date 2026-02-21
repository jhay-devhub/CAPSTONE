// Basic smoke test for ResQLink user app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ResQLinkApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
