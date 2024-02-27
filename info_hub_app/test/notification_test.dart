import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/models/notification.dart' as custom;
import 'package:info_hub_app/screens/notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';

import 'mock.dart';

const NotificationCollection = 'notifications';

Future<void> main() async {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Notifications tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
    });

    tearDown(() async {
      await firestore.collection(NotificationCollection).get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    });

    testWidgets('shows notifications', (WidgetTester tester) async {
      await firestore.collection(NotificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title1',
        'body': 'body1',
        'timestamp': DateTime.now(),
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => DatabaseService(
                uid: auth.currentUser!.uid,
                firestore: firestore,
              ).notifications,
              initialData: [],
            ),
          ],
          child: MaterialApp(
            home: Notifications(
              currentUser: auth.currentUser!.uid,
              firestore: firestore,
            ),
          ),
        ),
      );

      await tester.idle();

      await tester.pump();

      expect(find.text('title1'), findsOneWidget);
      expect(find.text('body1'), findsOneWidget);
      expect(find.text('title2'), findsNothing);
      expect(find.text('body2'), findsNothing);
    });

    testWidgets('create and delete notification', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String notificationId = await DatabaseService(
                      uid: 'user',
                      firestore: firestore,
                    ).createNotification(
                      'Test Title',
                      'Test Body',
                      DateTime.now(),
                    );

                    expect(notificationId, isNotEmpty);

                    await DatabaseService(
                      uid: 'user',
                      firestore: firestore,
                    ).deleteNotification(notificationId);

                    final notificationAfterDelete = firestore
                        .collection(NotificationCollection)
                        .doc(notificationId);
                    final snapshot = await notificationAfterDelete.get();

                    expect(snapshot.exists, isFalse);
                  },
                  child: Text('Create and Delete Notification'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create and Delete Notification'));
      await tester.pumpAndSettle();
    });

    testWidgets('delete notification on dismiss', (WidgetTester tester) async {
      await firestore.collection(NotificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'Test Title',
        'body': 'Test Body',
        'timestamp': Timestamp.now(),
      }).then((doc) => doc.id);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => DatabaseService(
                uid: auth.currentUser!.uid,
                firestore: firestore,
              ).notifications,
              initialData: [],
            ),
          ],
          child: MaterialApp(
            home: Notifications(
              currentUser: auth.currentUser!.uid,
              firestore: firestore,
            ),
          ),
        ),
      );

      await tester.idle();
      await tester.pump();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);

      await tester.drag(find.text('Test Title'), Offset(500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsNothing);
      expect(find.text('Test Body'), findsNothing);
    });
  });
}
