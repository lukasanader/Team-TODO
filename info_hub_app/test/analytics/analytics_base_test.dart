import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/analytics/analytics_base.dart';
import 'package:info_hub_app/analytics/topics/analytics_topic.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseAuth auth;
  late MockFirebaseStorage mockStorage = MockFirebaseStorage();
  late Widget allAnalyticsWidget;

  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();

    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });

    allAnalyticsWidget = MaterialApp(
      home: AnalyticsBase(auth: auth, firestore: firestore, storage: mockStorage),
    );
  });

  testWidgets('Test navigation from All Analytics to Topic Analytics',
      (WidgetTester tester) async {
    await tester.pumpWidget(allAnalyticsWidget);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsTopicView), findsOneWidget);
  });
}
