// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/screens/base.dart';
import 'package:info_hub_app/screens/home_page_skeleton.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  testWidgets('Test navigation to SearchPage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Base()));

    // Tap on the second item in the BottomNavigationBar.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    // Verify that SearchPage is displayed.
    expect(find.text('Search Page'), findsOneWidget);
  });

  testWidgets('Test navigation to SettingsPage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Base()));

    // Tap on the third item in the BottomNavigationBar.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    // Verify that SettingsPage is displayed.
    expect(find.text('Profile Page'), findsOneWidget);
  });

  testWidgets('HomePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(),
    ));

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.text('User-specific home page content'), findsOneWidget);
  });

  testWidgets('HomePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(),
    ));

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.text('User-specific home page content'), findsOneWidget);
  });

  testWidgets('HomePage to Navigation Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(),
    ));

    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('HomePage to Profile Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(),
    ));

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('NotificationPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NotificationPage(),
    ));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Notification Page'), findsOneWidget);
  });

  testWidgets('ProfilePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfilePage(),
    ));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Profile Page'), findsOneWidget);
  });
}
