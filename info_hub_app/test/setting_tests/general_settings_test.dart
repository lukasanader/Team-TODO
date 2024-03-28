import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/view/settings_view/app_appearance.dart';
import 'package:info_hub_app/view/settings_view/general_settings.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

void main() {
  late Widget generalSettingsViewWidget;
  late ThemeManager themeManager;

  setUp(() {
    themeManager = ThemeManager();
    generalSettingsViewWidget = MaterialApp(
        home: GeneralSettings(
      themeManager: themeManager,
    ));
  });

  testWidgets('SettingsView has appbar with back button and title "General"',
      (WidgetTester tester) async {
    await tester.pumpWidget(generalSettingsViewWidget);

    expect(find.text("General"), findsOneWidget);
  });

  testWidgets('Test entering App Appearance settings works',
      (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(generalSettingsViewWidget);

    // Tap on the ListTile to navigate to AppAppearance Page.
    await tester.tap(find.text('App Appearance'));
    await tester.pumpAndSettle();

    // Verify that App Appearance is rendered after tapping on the ListTile.
    expect(find.byType(AppAppearance), findsOneWidget);

    // Verify that TermsOfServicesPage renders an AppBar with the title "Terms of Services".
    expect(find.text('App Appearance'), findsOneWidget);
  });
}
