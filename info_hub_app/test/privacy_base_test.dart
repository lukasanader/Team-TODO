import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/legal_agreements/privacy_policy.dart';
import 'package:info_hub_app/legal_agreements/terms_of_services.dart';
import 'package:info_hub_app/settings/privacy_base.dart';

void main() {
  testWidgets('Privacy base to Terms of Services Page navigation test.',
      (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: PrivacyPage(),
    ));

    // Verify that PrivacyPage renders an AppBar with the title "Privacy".
    expect(find.text('Privacy'), findsOneWidget);

    // Verify that PrivacyPage renders a ListTile with the specified title.
    expect(find.text('Terms of Services'), findsOneWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('Terms of Services'));
    await tester.pumpAndSettle();

    // Verify that TermsOfServicesPage is rendered after tapping on the ListTile.
    expect(find.byType(TermsOfServicesPage), findsOneWidget);

    // Verify that TermsOfServicesPage renders an AppBar with the title "Terms of Services".
    expect(find.text('Terms of Services'), findsOneWidget);
  });
  testWidgets('Privacy base to Privacy Policy Page navigation test.',
      (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: PrivacyPage(),
    ));

    // Verify that PrivacyPage renders an AppBar with the title "Privacy".
    expect(find.text('Privacy'), findsOneWidget);

    // Verify that PrivacyPage renders a ListTile with the specified title.
    expect(find.text('Privacy Policy'), findsOneWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    // Verify that PrivacyPolicyPage is rendered after tapping on the ListTile.
    expect(find.byType(PrivacyPolicyPage), findsOneWidget);

    // Verify that Privacy Page renders an AppBar with the title "Privacy Policy".
    expect(find.text('Privacy Policy'), findsOneWidget);
  });
}
