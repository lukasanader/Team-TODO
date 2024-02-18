
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/settings_view.dart';



void main() {
  late Widget settingsViewWidget;
  late MockFirebaseAuth auth = MockFirebaseAuth();
  late FakeFirebaseFirestore firestore = FakeFirebaseFirestore();


  setUp(() {
    settingsViewWidget =  MaterialApp(
      home: SettingsView(firestore:firestore, auth: auth)
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
    expect(find.text("About TEAM TODO"), findsOneWidget);

  });


}
