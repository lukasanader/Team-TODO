import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/privacy_base.dart';

void main() {
  testWidgets('PrivacyPage UI Test', (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: PrivacyPage(),
    ));

    // Verify that PrivacyPage renders an AppBar with the title "Privacy".
    expect(find.text('Privacy'), findsOneWidget);

    // Verify that PrivacyPage renders a ListTile with the specified title.
    expect(find.text('TeamTODO Terms of Services'), findsOneWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('TeamTODO Terms of Services'));
    await tester.pumpAndSettle();

    // Verify that TermsOfServicesPage renders an AppBar with the title "Terms of Services".
    expect(find.text('Terms of Services'), findsOneWidget);

    // Verify that TermsOfServicesPage renders the specified text.
    expect(find.text('Placeholder for Terms of Services.'), findsOneWidget);
  });
}
