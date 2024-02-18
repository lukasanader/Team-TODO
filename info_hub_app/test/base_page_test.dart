/*
 * Bottom navigation bar tests (Also contains )
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/models/notification.dart' as custom;
import 'package:info_hub_app/screens/base.dart';
import 'package:info_hub_app/screens/discovery_view.dart';
import 'package:info_hub_app/screens/home_page.dart';
import 'package:info_hub_app/screens/notifications.dart';
import 'package:info_hub_app/screens/settings_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'mock.dart';


void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseAuth auth = MockFirebaseAuth();
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });


  testWidgets('Bottom Nav Bar to Home Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Base(firestore: firestore,auth:auth)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Bottom Nav Bar to Search Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Base(firestore: firestore,auth: auth)));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.byType(DiscoveryView), findsOneWidget);
  });

  testWidgets('Bottom Nav Bar to Setting Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Base(firestore: firestore,auth: auth,)));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(find.byType(SettingsView), findsOneWidget);
  });

  testWidgets('HomePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(firestore: firestore,auth: auth,),
    ));

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('HomePage to Notification Page', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) => DatabaseService(uid: '', firestore: firestore).notifications,
          initialData: [], // Initial data while waiting for Firebase data
        ),
  
      ],
      child: MaterialApp(
        home: HomePage(firestore: firestore,auth: auth,),
      ),
    ));
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    expect(find.byType(Notifications), findsOneWidget);
  });

  testWidgets('HomePage to Profile Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(firestore: firestore,auth: auth,),
    ));

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('NotificationPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) => DatabaseService(uid: '', firestore: firestore).notifications,
          initialData: [], // Initial data while waiting for Firebase data
        ),
  
      ],
      child: MaterialApp(
        home: Notifications(currentUser: '1',firestore: firestore,),
      ),
    ));
    expect(find.byType(Notifications), findsOneWidget);
  });

  testWidgets('ProfilePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ProfilePage(),
    ));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Profile Page'), findsOneWidget);
  });
}
