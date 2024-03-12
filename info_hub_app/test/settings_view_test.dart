import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/registration/start_page.dart';
import 'package:info_hub_app/settings/settings_view.dart';
import 'package:info_hub_app/registration/registration_screen.dart';

import 'manage_notifications_test.dart';

void main() {
  late Widget settingsViewWidget;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseStorage firebaseStorage;
  late FakeFirebaseFirestore firestore;

  setUp(() { 
    firebaseAuth = MockFirebaseAuth(signedIn: true);
    firebaseStorage = MockFirebaseStorage();
    firestore = FakeFirebaseFirestore();
    settingsViewWidget =  MaterialApp(home: SettingsView(auth: firebaseAuth, firestore: firestore, storage: firebaseStorage,));
  });

  testWidgets('SettingsView has appbar with back button and title "Settings"',
      (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    expect(find.text("Settings"), findsOneWidget);
  });

  testWidgets(
      'SettingsView has account profile pic with title (username) and role (patient, parent, or medical professional)',
      (WidgetTester tester) async {
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

  testWidgets('Test entering privacy settings works', (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(settingsViewWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('Manage Privacy Settings'));
    await tester.pumpAndSettle();

    // Verify that TermsOfServicesPage renders an AppBar with the title "Terms of Services".
    expect(find.text('Privacy'), findsOneWidget);

    // Verify that TermsOfServicesPage renders the specified text.
    expect(find.text('TeamTODO Terms of Services'), findsOneWidget);
  });

    
    testWidgets('Test entering manage notification works', (WidgetTester tester) async {
      await firestore.collection(PreferenceCollection).add({
        'uid': firebaseAuth.currentUser!.uid,
        'push_notifications': true,
      });
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(settingsViewWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('Manage Notifications'));
    await tester.pumpAndSettle();
    
    // Verify that TermsOfServicesPage renders the specified text.
    expect(find.byType(ManageNotifications), findsOneWidget);
  });
  


  testWidgets('test if logout works', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    expect(firebaseAuth.currentUser,null);
});
}
