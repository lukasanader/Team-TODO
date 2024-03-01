import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/webinar/webinar_view.dart';



void main() {
  late Widget webinarViewWidget;


  setUp(() {
    webinarViewWidget = const MaterialApp(
      home: WebinarView()
    );
  });

  testWidgets('WebinarView exists', (WidgetTester tester) async {
    await tester.pumpWidget(webinarViewWidget);
    expect(find.byType(WebinarView), findsOneWidget);
  });



}
