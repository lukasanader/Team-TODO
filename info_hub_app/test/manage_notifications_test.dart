import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/notifications/manage_notifications_model.dart';
import 'package:info_hub_app/notifications/manage_notifications_view.dart';
import 'package:info_hub_app/notifications/preferences_service.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';

import 'mock.dart';

const PreferenceCollection = 'preferences';

Future<void> main() async {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Manage Notifications Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late PreferencesService preferencesService;
    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
      preferencesService = PreferencesService(
          auth: auth, uid: auth.currentUser!.uid, firestore: firestore);
    });

    tearDown(() async {
      firestore.clearPersistence();
    });

    testWidgets('shows preferences', (WidgetTester tester) async {
      await firestore.collection(PreferenceCollection).add({
        'uid': auth.currentUser!.uid,
        'push_notifications': true,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: StreamProvider<List<Preferences>>(
            create: (_) => PreferencesService(
                    firestore: firestore,
                    auth: auth,
                    uid: auth.currentUser!.uid)
                .preferences,
            initialData: [],
            child: Scaffold(
              body: ManageNotifications(firestore: firestore, auth: auth),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, true);
    });

    testWidgets('updates notification preferences',
        (WidgetTester tester) async {
      final preferenceDocRef =
          await firestore.collection(PreferenceCollection).add({
        'uid': auth.currentUser!.uid,
        'push_notifications': true,
      });

      await tester.pumpWidget(
        MaterialApp(
          home: StreamProvider<List<Preferences>>(
            create: (_) => PreferencesService(
                    firestore: firestore,
                    auth: auth,
                    uid: auth.currentUser!.uid)
                .preferences,
            initialData: [],
            child: Scaffold(
              body: ManageNotifications(firestore: firestore, auth: auth),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, false);

      final preferenceDocSnapshot = await preferenceDocRef.get();
      expect(preferenceDocSnapshot.get('push_notifications'), false);
    });

    test('createPreferences adds preferences to Firestore', () async {
      await preferencesService.createPreferences();
      QuerySnapshot querySnapshot =
          await firestore.collection(PreferenceCollection).get();

      expect(querySnapshot.docs.length, 1);
    });

    test('prefListFromSnapshot returns list of preferences from QuerySnapshot',
        () async {
      firestore.collection(PreferenceCollection).add({
        'uid': auth.currentUser!.uid,
        'push_notifications': true,
      });

      QuerySnapshot querySnapshot =
          await firestore.collection(PreferenceCollection).get();

      List<Preferences> preferences =
          preferencesService.prefListFromSnapshot(querySnapshot);

      expect(preferences.length, 1);
    });

    test('getPreferences returns list of preferences from Firestore', () async {
      await preferencesService.createPreferences();
      List<Preferences> preferences = await preferencesService.getPreferences();

      expect(preferences.length, 1);
    });

    test('get preferences stream returns list of preferences', () async {
      await preferencesService.createPreferences();
      Stream<List<Preferences>> preferencesStream =
          preferencesService.preferences;

      expect(preferencesStream, isA<Stream<List<Preferences>>>());
    });
  });
}
