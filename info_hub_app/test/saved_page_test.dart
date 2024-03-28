import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/settings/saved/view/saved_view.dart';
import 'package:info_hub_app/view/topic_view/topic_view.dart';
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
  late Widget savedTopicsWidget;
  late CollectionReference topicCollectionRef;

  setUp(() {
    HttpOverrides.global = null;
    auth = MockFirebaseAuth();

    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    savedTopicsWidget = MaterialApp(
        home: SavedPage(auth: auth, firestore: firestore, storage: storage));
  });

  testWidgets('App bar title should be "Saved Topics" ',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');

    // Build the widget
    await tester.pumpWidget(MaterialApp(
      home: SavedPage(auth: auth, firestore: firestore, storage: storage),
    ));

    // Verify if the app bar title is 'Your Saved Topics'
    expect(find.text('Saved Topics'), findsOneWidget);
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
      'media': [
        {
          'url':
              'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D',
          'mediaType': 'image',
          'thumbnail':
              'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
        },
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
          'mediaType': 'video'
        }
      ],
      'views': 10,
      'date': DateTime.now().subtract(const Duration(minutes: 5)),
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
    expect(find.byType(TopicView), findsOne);
  });

  testWidgets(
      'ensure padding is visible if there are at least two saved topics',
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
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });

    DocumentReference topicDocRef2 = await topicCollectionRef.add({
      'title': 'test 2',
      'description': 'this is a test 2',
      'articleLink': '',
      'media': [],
      'views': 10,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
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
      'savedTopics': [
        topicDocRef.id,
        topicDocRef2.id,
      ],
    });

    await tester.pumpWidget(savedTopicsWidget);
    await tester.pumpAndSettle();

    expect(find.byType(Padding), findsWidgets);
  });
}
