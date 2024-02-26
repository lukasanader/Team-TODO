import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:info_hub_app/notifications/notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';

import 'mock.dart';

const notificationCollection = 'notifications';

Future<void> main() async {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('shows notifications', (WidgetTester tester) async {
    // Populate the fake database.
    final firestore = FakeFirebaseFirestore();

    await firestore.collection(notificationCollection).add({
      'user': 'user1',
      'title': 'title1',
      'body': 'body1',
      'timestamp': Timestamp.now(),
    });

    // Render the widget.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          StreamProvider<List<custom.Notification>>(
            create: (_) => DatabaseService(
              uid: 'user1',
              firestore: firestore, // Use the fake Firestore instance
            ).notifications,
            initialData: const [], // Initial data while waiting for Firebase data
          ),
        ],
        child: MaterialApp(
          home: Notifications(
            currentUser: 'user1',
            firestore: firestore,
          ),
        ),
      ),
    );

    // Let the snapshots stream fire a snapshot.
    await tester.idle();
    // Re-render.
    await tester.pump();
    // // Verify the output.
    expect(find.text('title1'), findsOneWidget);
    expect(find.text('body1'), findsOneWidget);
    expect(find.text('title2'), findsNothing);
    expect(find.text('body2'), findsNothing);
  });
}
