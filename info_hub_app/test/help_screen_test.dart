import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/help_features/help_view.dart';
import 'package:info_hub_app/screens/settings_view.dart';



void main() {
  late Widget helpViewWidget;


  setUp(() {
    helpViewWidget = const MaterialApp(
      home: HelpView()
    );
  });

  testWidgets('HelpView is actually there', (WidgetTester tester) async {
    await tester.pumpWidget(helpViewWidget);
    expect(find.byType(HelpView), findsOneWidget);
  });

  testWidgets('HelpView has back arrow which leads back to main settings page', (WidgetTester tester) async {
    
    //Entering the help view from the settings page
    late Widget settingsViewWidget = const MaterialApp(
      home: SettingsView(),
    );
    
    await tester.pumpWidget(settingsViewWidget);
    final helpOption = find.byKey(const Key('Help Option'));

    expect(helpOption, findsOneWidget);

    await tester.tap(helpOption);
    await tester.pumpAndSettle();

    expect(find.byType(HelpView), findsOneWidget);


    //Now leaving the help view back into the previous page it was on (the settings page)
    final backArrow = find.byIcon(Icons.arrow_back);

    expect(backArrow, findsOneWidget);

    await tester.tap(backArrow);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsView), findsOneWidget);
  });


}
