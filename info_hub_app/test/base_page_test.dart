/*
 * Bottom navigation bar tests (Also contains )
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/base.dart';
import 'package:info_hub_app/screens/home_page_skeleton.dart';

void main() {
  testWidgets('Bottom Nav Bar to Home Page', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Base()));

    await tester.tap(find.byIcon(Icons.home));
    await tester.pump();

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.text('User-specific home page content'), findsOneWidget);
  });
  testWidgets('Bottom Nav Bar to Search Page', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Base()));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.text('Search Page'), findsOneWidget);
  });

  testWidgets('Bottom Nav Bar to Profile Page', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Base()));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(find.text('Profile Page'), findsOneWidget);
  });

  testWidgets('HomePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.text('User-specific home page content'), findsOneWidget);
  });

  testWidgets('HomePage to Navigation Page', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));

    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('HomePage to Profile Page', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('NotificationPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: NotificationPage(),
    ));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Notification Page'), findsOneWidget);
  });

  testWidgets('ProfilePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ProfilePage(),
    ));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Profile Page'), findsOneWidget);
  });
}
