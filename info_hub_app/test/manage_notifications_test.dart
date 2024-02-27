import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/notifications/preferences.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
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
    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
    });

    tearDown(() async {
      firestore.clearPersistence();
    });

    testWidgets('shows preferences', (WidgetTester tester) async {
      // Add a document to Firestore with the user's preferences
      await firestore.collection(PreferenceCollection).add({
        'uid': auth.currentUser!.uid,
        'push_notifications': true,
      });

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: StreamProvider<List<Preferences>>(
            create: (_) => DatabaseService(
                    firestore: firestore, uid: auth.currentUser!.uid)
                .preferences,
            initialData: [],
            child: Scaffold(
              body: ManageNotifications(firestore: firestore, auth: auth),
            ),
          ),
        ),
      );

      // Wait for the widget to render
      await tester.pumpAndSettle();

      // Verify that the switch is toggled on
      expect(find.byType(Switch), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, true);
    });

    testWidgets('updates notification preferences',
        (WidgetTester tester) async {
      // Add a document to Firestore with the user's preferences
      final preferenceDocRef =
          await firestore.collection(PreferenceCollection).add({
        'uid': auth.currentUser!.uid,
        'push_notifications': true,
      });

      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: StreamProvider<List<Preferences>>(
            create: (_) => DatabaseService(
                    firestore: firestore, uid: auth.currentUser!.uid)
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
  });
}
