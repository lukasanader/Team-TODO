/*
 * Bottom navigation bar tests (Also contains )
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/base.dart';
import 'package:info_hub_app/screens/discovery_view.dart';
import 'package:info_hub_app/screens/home_page_skeleton.dart';
import 'package:info_hub_app/screens/settings_view.dart';


void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  setUp((){
    CollectionReference topicCollectionRef =
        firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 4',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 5,
      'date': DateTime.now(),
    });
  });
  testWidgets('Bottom Nav Bar to Home Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Base(firestore: firestore,)));

    await tester.tap(find.byIcon(Icons.home));
    await tester.pump();

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Bottom Nav Bar to Search Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Base(firestore: firestore,)));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.byType(DiscoveryView), findsOneWidget);
  });

  testWidgets('Bottom Nav Bar to Setting Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Base(firestore: firestore,)));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(find.byType(SettingsView), findsOneWidget);
  });

  testWidgets('HomePage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(firestore: firestore,),
    ));

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('HomePage to Navigation Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(firestore: firestore,),
    ));

    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('HomePage to Profile Page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HomePage(firestore: firestore,),
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
