import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fancy_page_indicator/fancy_page_indicator.dart';

void main() {
  testWidgets('FancyPageIndicator renders with PageController and count',
      (WidgetTester tester) async {
    final controller = PageController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FancyPageIndicator(
            controller: controller,
            count: 5,
          ),
        ),
      ),
    );

    expect(find.byType(FancyPageIndicator), findsOneWidget);
  });

  testWidgets('FancyPageIndicator respects enableLoupe', (WidgetTester tester) async {
    final controller = PageController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FancyPageIndicator(
            controller: controller,
            count: 3,
            enableLoupe: true,
          ),
        ),
      ),
    );

    expect(find.byType(FancyPageIndicator), findsOneWidget);
  });
}
