/*
 * Bottom navigation bar tests (Also contains )
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:info_hub_app/helpers/base.dart';
import 'package:info_hub_app/discovery_view/discovery_view.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/notifications/notifications.dart';
import 'package:info_hub_app/settings/settings_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';
import 'mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';

void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseAuth auth = MockFirebaseAuth();
  late MockFirebaseStorage storage = MockFirebaseStorage();

  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Bottom Nav Bar to Home Page', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(email: 'test@tested.org', password: 'Password123!');
  String uid = auth.currentUser!.uid;
  await firestore.collection('Users').doc(uid).set({
        'email': 'test@tested.org',
        'firstName' : 'James',
        'lastName' : 'Doe',
        'roleType' : 'Patient'
        });
    await tester.pumpWidget(MaterialApp(
        home: Base(
      storage: storage,
      auth: auth,
      firestore: firestore,
    )));

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
    await auth.createUserWithEmailAndPassword(email: 'test@tested.org', password: 'Password123!');
  String uid = auth.currentUser!.uid;
  await firestore.collection('Users').doc(uid).set({
        'email': 'test@tested.org',
        'firstName' : 'James',
        'lastName' : 'Doe',
        'roleType' : 'Patient'
        });
    await tester.pumpWidget(MaterialApp(
        home: Base(
      storage: storage,
      auth: auth,
      firestore: firestore,
    )));

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.byType(DiscoveryView), findsOneWidget);
  });

  testWidgets('Bottom Nav Bar to Setting Page', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(email: 'test@tested.org', password: 'Password123!');
  String uid = auth.currentUser!.uid;
  await firestore.collection('Users').doc(uid).set({
        'email': 'test@tested.org',
        'firstName' : 'James',
        'lastName' : 'Doe',
        'roleType' : 'Patient'
        });
    await tester.pumpWidget(MaterialApp(
        home: Base(
      storage: storage,
      auth: auth,
      firestore: firestore,
    )));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    expect(find.byType(SettingsView), findsOneWidget);
  });

  testWidgets('HomePage UI Test', (WidgetTester tester) async {
      await auth.createUserWithEmailAndPassword(email: 'test@tested.org', password: 'Password123!');
  String uid = auth.currentUser!.uid;
  await firestore.collection('Users').doc(uid).set({
        'email': 'test@tested.org',
        'firstName' : 'James',
        'lastName' : 'Doe',
        'roleType' : 'Patient'
        });
    await tester.pumpWidget(MaterialApp(
      home: HomePage(
        storage: storage,
        auth: auth,
        firestore: firestore,
      ),
    ));

    expect(find.text('Team TODO'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('HomePage to Notification Page', (WidgetTester tester) async {
      await auth.createUserWithEmailAndPassword(email: 'test@tested.org', password: 'Password123!');
  String uid = auth.currentUser!.uid;
  await firestore.collection('Users').doc(uid).set({
        'email': 'test@tested.org',
        'firstName' : 'James',
        'lastName' : 'Doe',
        'roleType' : 'Patient'
        });
    await tester.pumpWidget(MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) =>
              DatabaseService(uid: '', firestore: firestore).notifications,
          initialData: const [], // Initial data while waiting for Firebase data
        ),
      ],
      child: MaterialApp(
        home: HomePage(
          storage: storage,
          auth: auth,
          firestore: firestore,
        ),
      ),
    ));
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    expect(find.byType(Notifications), findsOneWidget);
  });

  testWidgets('HomePage to Profile Page', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
    final fakeUserId = auth.currentUser!.uid;
    final fakeUser = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'profileview@example.org',
      'roleType' : 'Patient',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);
    await tester.pumpWidget(MaterialApp(
      home: HomePage(
        storage: storage,
        auth: auth,
        firestore: firestore,
      ),
    ));

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle(); 

    expect(find.byType(ProfileView), findsOneWidget);
  });

  testWidgets('NotificationPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) =>
              DatabaseService(uid: '', firestore: firestore).notifications,
          initialData: const [], // Initial data while waiting for Firebase data
        ),
      ],
      child: MaterialApp(
        home: Notifications(
          auth: auth,
          firestore: firestore,
        ),
      ),
    ));
    expect(find.byType(Notifications), findsOneWidget);
  });
}
