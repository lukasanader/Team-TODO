import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/view/topic_view/topic_view.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/model/topic_model.dart';

/// This test file is responsible for testing the use of user feedback tools
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  late DocumentReference topicDocRef;
  late MockFirebaseStorage storage;
  late Topic topic;

  late ThemeManager themeManager = ThemeManager();

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    CollectionReference ref = firestore.collection('topics');

    topic = Topic(
        id: '1',
        title: 'no video topic',
        description: 'Test Description',
        articleLink: 'https://www.javatpoint.com/heap-sort',
        media: [],
        likes: 0,
        views: 0,
        quizID: "",
        tags: ['Patient'],
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());

    topicDocRef = await ref.add(topic.toJson());

    String topicId = topicDocRef.id;
    topic.id = topicId;

    await ref.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
          'mediaType': 'video',
          'thumbnail':
              'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
        }
      ],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now()
    });
  });

  testWidgets('Test tapping thumb up icon increments likes by one',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: auth,
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_up));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(topicSnapshot['likes'], 1);
  });

  testWidgets('Test tapping thumb down icon increments dislikes by one',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: auth,
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'disikes' field has been incremented by one
    expect(topicSnapshot['dislikes'], 1);
  });

  testWidgets('Test tapping dislike button removes past like',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    // Create the TopicView widget with the test topic
    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: auth,
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_up));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    // Retrieve the updated topic document from Firestore
    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(topicSnapshot['likes'], 1);

    // Tap the thumb up icon
    await tester.tap(find.byIcon(Icons.thumb_down));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    // Retrieve the updated topic document from Firestore
    DocumentSnapshot dislikeSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(dislikeSnapshot['dislikes'], 1);

    // check that likes field is back to 0
    expect(dislikeSnapshot['likes'], 0);
  });

  testWidgets('Test tapping like button removes past dislike',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: auth,
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();

    // dislike topic
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been incremented by one
    expect(topicSnapshot['dislikes'], 1);

    // like topic
    await tester.tap(find.byIcon(Icons.thumb_up));

    await tester.pumpAndSettle();

    DocumentSnapshot likeSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(likeSnapshot['likes'], 1);

    // check that dislikes field is back to 0
    expect(likeSnapshot['dislikes'], 0);
  });

  testWidgets('Test tapping like button twice removes like',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: auth,
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();

    // Like topic
    await tester.tap(find.byIcon(Icons.thumb_up));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'likes' field has been incremented by one
    expect(topicSnapshot['likes'], 1);

    // like topic again
    await tester.tap(find.byIcon(Icons.thumb_up));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    DocumentSnapshot likeSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been reset
    expect(likeSnapshot['likes'], 0);
  });

  testWidgets('Test tapping dislike button twice removes dislike',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: auth,
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();

    // dislike topic
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been incremented by one
    expect(topicSnapshot['dislikes'], 1);

    // dislike topic again
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot dislikeSnapshot = await topicDocRef.get();

    // Verify that the 'dislikes' field has been reset

    expect(dislikeSnapshot['dislikes'], 0);
  });
}
