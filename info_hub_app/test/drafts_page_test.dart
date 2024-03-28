import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/settings/drafts/view/drafts_view.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late Widget draftedTopicsWidget;
  late CollectionReference draftCollectionRef;

  setUp(() {
    HttpOverrides.global = null;
    auth = MockFirebaseAuth();

    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    draftedTopicsWidget = MaterialApp(
        home: DraftsPage(auth: auth, firestore: firestore, storage: storage));
  });

  testWidgets('App bar title should be "Your Drafts" ',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: DraftsPage(auth: auth, firestore: firestore, storage: storage),
    ));

    // Verify if the app bar title is 'Your Drafts'
    expect(find.text('Your Drafts'), findsOneWidget);
  });

  testWidgets('test user with no drafted topics shows no drafts on screen',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'admin',
      'draftedTopics': []
    });

    await tester.pumpWidget(draftedTopicsWidget);
    await tester.pumpAndSettle();
    expect(find.text("No drafts"), findsOne);
  });

  testWidgets('test click into drafted topic takes to create topic screen',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;

    draftCollectionRef = firestore.collection('topicDrafts');
    DocumentReference draftDocRef = await draftCollectionRef.add({
      'title': 'test ',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 10,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym'],
      'userID': uid
    });

    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'admin',
      'draftedTopics': [draftDocRef.id],
    });

    await tester.pumpWidget(draftedTopicsWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();
    expect(find.byType(TopicCreationView), findsOne);
  });
}
