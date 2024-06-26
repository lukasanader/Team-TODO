import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/view/notifications_view/notification_card_view.dart';
import 'package:info_hub_app/model/notification_models/notification_model.dart' as custom;
import 'package:info_hub_app/controller/notification_controllers/notification_controller.dart';
import 'package:info_hub_app/view/notifications_view/notification_view.dart';
import 'package:provider/provider.dart';

import '../test_helpers/mock.dart';

const notificationCollection = 'notifications';

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
      await firestore.collection(notificationCollection).get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    });

    testWidgets('shows notifications', (WidgetTester tester) async {
      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title1',
        'body': 'body1',
        'timestamp': DateTime.now(),
        'route': 'route1',
        'payload': 'payload1',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => NotificationController(
                auth: auth,
                firestore: firestore,
                uid: auth.currentUser!.uid,
              ).notifications,
              initialData: const [],
            ),
          ],
          child: MaterialApp(
            home: Notifications(
              auth: auth,
              firestore: firestore,
            ),
          ),
        ),
      );

      await tester.idle();

      await tester.pump();

      expect(find.text('title1'), findsOneWidget);
      expect(find.text('title2'), findsNothing);
    });

    testWidgets(
        'ensure padding is visible if more than 2 notifications are present',
        (WidgetTester tester) async {
      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title1',
        'body': 'body1',
        'timestamp': DateTime.now(),
        'route': 'route1',
        'payload': 'payload1',
      });
      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title2',
        'body': 'body2',
        'timestamp': DateTime.now(),
        'route': 'route2',
        'payload': 'payload2',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => NotificationController(
                uid: auth.currentUser!.uid,
                auth: auth,
                firestore: firestore,
              ).notifications,
              initialData: const [],
            ),
          ],
          child: MaterialApp(
            home: Notifications(
              auth: auth,
              firestore: firestore,
            ),
          ),
        ),
      );

      await tester.idle();

      await tester.pump();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('create and delete notification', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String notificationId = await NotificationController(
                      auth: auth,
                      firestore: firestore,
                      uid: auth.currentUser!.uid,
                    ).createNotification('Test Title', 'Test Body',
                        DateTime.now(), 'Test Route', null);

                    expect(notificationId, isNotEmpty);

                    await NotificationController(
                            auth: auth,
                            firestore: firestore,
                            uid: auth.currentUser!.uid)
                        .deleteNotification(notificationId);

                    final notificationAfterDelete = firestore
                        .collection(notificationCollection)
                        .doc(notificationId);
                    final snapshot = await notificationAfterDelete.get();

                    expect(snapshot.exists, isFalse);
                  },
                  child: const Text('Create and Delete Notification'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create and Delete Notification'));
      await tester.pumpAndSettle();
    });

    testWidgets('delete notification on delete button',
        (WidgetTester tester) async {
      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'Test Title',
        'body': 'Test Body',
        'timestamp': Timestamp.now(),
        'route': 'Test Route',
        'payload': 'Test Payload',
      }).then((doc) => doc.id);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => NotificationController(
                      auth: auth,
                      firestore: firestore,
                      uid: auth.currentUser!.uid)
                  .notifications,
              initialData: const [],
            ),
          ],
          child: MaterialApp(
            home: Notifications(
              auth: auth,
              firestore: firestore,
            ),
          ),
        ),
      );

      await tester.idle();
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);

      await tester.drag(find.text('Test Title'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsNothing);
    });

    testWidgets('delete all notifications on delete all button',
        (WidgetTester tester) async {
      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'Test Title1',
        'body': 'Test Body1',
        'timestamp': Timestamp.now(),
        'route': 'Test Route1',
        'payload': 'Test Payload1',
      }).then((doc) => doc.id);

      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'Test Title2',
        'body': 'Test Body2',
        'timestamp': Timestamp.now(),
        'route': 'Test Route2',
        'payload': 'Test Payload2',
      }).then((doc) => doc.id);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => NotificationController(
                      auth: auth,
                      firestore: firestore,
                      uid: auth.currentUser!.uid)
                  .notifications,
              initialData: const [],
            ),
          ],
          child: MaterialApp(
            home: Notifications(
              auth: auth,
              firestore: firestore,
            ),
          ),
        ),
      );

      await tester.idle();
      await tester.pumpAndSettle();

      expect(find.text('Test Title1'), findsOneWidget);
      expect(find.text('Test Title2'), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      expect(find.text('Test Title1'), findsNothing);
      expect(find.text('Test Title2'), findsNothing);
    });

    testWidgets('show notification details button routes correctly',
        (WidgetTester tester) async {
      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title1',
        'body': 'body1',
        'timestamp': DateTime.now(),
        'route': 'route1',
        'payload': 'payload1',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => NotificationController(
                      auth: auth,
                      firestore: firestore,
                      uid: auth.currentUser!.uid)
                  .notifications,
              initialData: const [],
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: Notifications(
              auth: auth,
              firestore: firestore,
            ),
            routes: {
              'route1': (_) => Notifications(
                    auth: auth,
                    firestore: firestore,
                  ),
              '/home': (_) => const Scaffold(),
              '/base': (_) => const Scaffold(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('title1'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('View Details'));
      expect(find.byType(Notifications), findsOneWidget);
    });

    testWidgets('show notification details dialog',
        (WidgetTester tester) async {
      final notification = custom.Notification(
        id: 'notificationId',
        uid: auth.currentUser!.uid,
        title: 'Test Title',
        body: 'Test Body',
        timestamp: DateTime.now(),
        route: 'Test Route',
        deleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          routes: {
            'Test Route': (_) => const Scaffold(),
          },
          home: NotificationCard(notification: notification),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Title'), findsOneWidget);

      await tester.tap(find.byType(NotificationCard));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('show notification close buttons routes correctly',
        (WidgetTester tester) async {
      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title1',
        'body': 'body1',
        'timestamp': DateTime.now(),
        'route': 'route1',
        'payload': 'payload1',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            StreamProvider<List<custom.Notification>>(
              create: (_) => NotificationController(
                      auth: auth,
                      firestore: firestore,
                      uid: auth.currentUser!.uid)
                  .notifications,
              initialData: const [],
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: Notifications(
              auth: auth,
              firestore: firestore,
            ),
            routes: {
              'route1': (_) => Notifications(
                    auth: auth,
                    firestore: firestore,
                  ),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('title1'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Close'));
      expect(find.byType(Notifications), findsOneWidget);
    });

    test(
        'getNotificationIdFromPayload returns a list of notification ids to be deleted',
        () async {
      const payload = 'payload1';

      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title1',
        'body': 'body1',
        'timestamp': DateTime.now(),
        'route': 'route1',
        'payload': 'payload1',
      });

      await firestore.collection(notificationCollection).add({
        'uid': auth.currentUser!.uid,
        'title': 'title2',
        'body': 'body2',
        'timestamp': DateTime.now(),
        'route': 'route2',
        'payload': 'payload1',
      });

      NotificationController notificationController = NotificationController(
          auth: auth, firestore: firestore, uid: auth.currentUser!.uid);
      List<String> notificationId =
          await notificationController.getNotificationIdFromPayload(payload);

      expect(notificationId.length, 2);

      if (notificationId.isNotEmpty) {
        for (String id in notificationId) {
          notificationController.deleteNotification(id);
        }
      }

      final snapshot = await firestore.collection(notificationCollection).get();
      expect(snapshot.docs.length, 0);
    });

    test(
        'getNotificationIdFromPayload returns an empty list of notification ids',
        () async {
      const payload = 'payload1';

      NotificationController notificationController = NotificationController(
          auth: auth, firestore: firestore, uid: auth.currentUser!.uid);
      List<String> notificationId =
          await notificationController.getNotificationIdFromPayload(payload);

      expect(notificationId.length, 0);

      final snapshot = await firestore.collection(notificationCollection).get();

      expect(snapshot.docs.length, 0);
    });
  });
}
