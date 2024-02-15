
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/help_view.dart';
import 'package:info_hub_app/screens/settings_view.dart';



void main() {
  late Widget settingsViewWidget;


  setUp(() {
    settingsViewWidget = const MaterialApp(
      home: SettingsView()
    );
  });

  testWidgets('SettingsView has appbar with back button and title "Settings"', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    
    expect(find.text("Settings"), findsOneWidget);
  });

  testWidgets('SettingsView has account profile pic with title (username) and role (patient, parent, or medical professional)', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
  });

  testWidgets('SettingsView has all options', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.privacy_tip), findsOneWidget);
    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    expect(find.byIcon(Icons.help), findsOneWidget);

    expect(find.text("Manage Notifications"), findsOneWidget);
    expect(find.text("Manage Privacy Settings"), findsOneWidget);
    expect(find.text("History"), findsOneWidget);
    expect(find.text("Help"), findsOneWidget);

  });

  testWidgets('SettingsView help option goes to help view', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    final helpOption = find.byKey(const Key('Help Option'));

    expect(helpOption, findsOneWidget);

    await tester.tap(helpOption);
    await tester.pumpAndSettle();

    expect(find.byType(HelpView), findsOneWidget);
  });

}
