import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/settings/saved/saved_page.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late Widget savedTopicsWidget;
  late CollectionReference topicCollectionRef;

  setUp(() {
    auth = MockFirebaseAuth();

    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    savedTopicsWidget = MaterialApp(
        home: SavedPage(auth: auth, firestore: firestore, storage: storage));
  });

  testWidgets('App bar title should be "Your Saved Topics" ',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: SavedPage(auth: auth, firestore: firestore, storage: storage),
    ));

    // Verify if the app bar title is 'Your Saved Topics'
    expect(find.text('Your Saved Topics'), findsOneWidget);
  });

  testWidgets('test user with no saved topics shows no saved topics on screen',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient',
      'savedTopics': []
    });

    await tester.pumpWidget(savedTopicsWidget);
    await tester.pumpAndSettle();
    expect(find.text("No saved topics"), findsOne);
  });

  testWidgets('test click into saved topic takes to view topic screen',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;

    topicCollectionRef = firestore.collection('topics');
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'test 1',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 10,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });

    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient',
      'savedTopics': [topicDocRef.id],
    });

    await tester.pumpWidget(savedTopicsWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();
    expect(find.byType(ViewTopicScreen), findsOne);
  });
}
