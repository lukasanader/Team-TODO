import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/view/settings_view/app_appearance.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

void main() {
  late ThemeManager themeManager;

  setUp(() {
    themeManager = ThemeManager();
  });

  testWidgets("App Appearance has three list tiles", (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AppAppearance(themeManager: themeManager),
      ),
    );

    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets("App Appearance has Match System enabled by defaults",
      (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AppAppearance(themeManager: themeManager),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);

    // Verify if the theme manager has been updated correctly
    expect(themeManager.themeMode, equals(ThemeMode.system));
  });

  testWidgets("App Appearance has Light mode enabled by tapping on it",
      (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AppAppearance(themeManager: themeManager),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);

    await widgetTester.tap(find.text('Always Light'));
    await widgetTester.pumpAndSettle();

    // Verify if the theme manager has been updated correctly
    expect(themeManager.themeMode, equals(ThemeMode.light));
  });

  testWidgets("App Appearance has Dark mode enabled by tapping on it",
      (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AppAppearance(themeManager: themeManager),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);

    await widgetTester.tap(find.text('Always Dark'));
    await widgetTester.pumpAndSettle();

    // Verify if the theme manager has been updated correctly
    expect(themeManager.themeMode, equals(ThemeMode.dark));
  });

  testWidgets("App Appearance has System mode enabled by tapping on it",
      (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AppAppearance(themeManager: themeManager),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);

    await widgetTester.tap(find.text('Match System'));
    await widgetTester.pumpAndSettle();

    expect(themeManager.themeMode, equals(ThemeMode.system));
  });

  testWidgets("App Appearance has light mode enabled by defaults",
      (widgetTester) async {
    themeManager.changeTheme('light');
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AppAppearance(themeManager: themeManager),
      ),
    );

    expect(themeManager.themeMode, equals(ThemeMode.light));
  });

  testWidgets("App Appearance has dark mode enabled by defaults",
      (widgetTester) async {
    themeManager.changeTheme('dark');
    await widgetTester.pumpWidget(
      MaterialApp(
        home: AppAppearance(themeManager: themeManager),
      ),
    );

    expect(themeManager.themeMode, equals(ThemeMode.dark));
  });
}
