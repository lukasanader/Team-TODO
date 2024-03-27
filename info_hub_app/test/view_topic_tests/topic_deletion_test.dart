import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/topics/view_topic/view/topic_view.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../mock_classes.dart';
import 'package:info_hub_app/model/topic_model.dart';

/// This test file is responsible for testing the deletion of topics by admins
void main() {
  late FakeFirebaseFirestore firestore;

  late MockFirebaseStorage storage;
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

    await ref.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
          'mediaType': 'video'
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

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });

  testWidgets('Test tapping delete topic button deletes the topic',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    Topic topic = Topic(
        title: 'Test Topic',
        description: 'Test Description',
        articleLink: 'https://www.example.com',
        media: [
          {
            'url':
                'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
            'mediaType': 'video'
          }
        ],
        likes: 0,
        views: 0,
        quizID: "",
        tags: ['Patient'],
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());

    // Add a topic
    DocumentReference ref = await topicCollectionRef.add(topic.toJson());
    topic.id = ref.id;

    Widget deleteView = MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        themeManager: themeManager,
      ),
    );

    await tester.pumpWidget(deleteView);

    await tester.pumpAndSettle();
    // save the topic
    await tester.ensureVisible(find.byKey(const Key('save_btn')));
    await tester.tap(find.byKey(const Key('save_btn')));
    //like the topic
    await tester.ensureVisible(find.byIcon(Icons.thumb_up));
    await tester.tap(find.byIcon(Icons.thumb_up));
    await tester.ensureVisible(find.byKey(const Key('delete_topic_button')));
    await tester.tap(find.byKey(const Key('delete_topic_button')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    // topic is deleted from firebase
    DocumentSnapshot topicSnapshot = await ref.get();
    expect(topicSnapshot.exists, false);
    DocumentSnapshot userSnapshot =
        await firestore.collection('Users').doc('adminUser').get();
    expect(List<dynamic>.from(userSnapshot['savedTopics']).contains(ref.id),
        false);
    expect(List<dynamic>.from(userSnapshot['likedTopics']).contains(ref.id),
        false);
    final ListResult result = await storage.ref().child('media').listAll();
    expect(result.items.length, equals(0));
  });

  testWidgets(
      'Test delete topic button removes topic from user disliked topics',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    Topic topic = Topic(
        title: 'Test Topic',
        description: 'Test Description',
        articleLink: 'https://www.example.com',
        media: [
          {
            'url':
                'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
            'mediaType': 'video'
          }
        ],
        likes: 0,
        views: 0,
        quizID: "",
        tags: ['Patient'],
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());

    DocumentReference topicDocRef =
        await topicCollectionRef.add(topic.toJson());
    topic.id = topicDocRef.id;

    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();
    DocumentReference adminUserDocRef =
        firestore.collection('Users').doc('adminUser');
    // dislike topic
    await tester.ensureVisible(find.byIcon(Icons.thumb_down));
    await tester.tap(find.byIcon(Icons.thumb_down));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('delete_topic_button')));
    await tester.tap(find.byKey(const Key('delete_topic_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    DocumentSnapshot deleteSnapshot = await adminUserDocRef.get();
    List<dynamic> listAfterDelete =
        List<dynamic>.from(deleteSnapshot['dislikedTopics']);
    expect(listAfterDelete.contains(topicDocRef.id), false);
  });

  testWidgets(
      'Test tapping delete topic button then cancel does not delete topic',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic
    Topic topic = Topic(
        title: 'Test Topic',
        description: 'Test Description',
        articleLink: 'https://www.example.com',
        media: [
          {
            'url':
                'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
            'mediaType': 'video'
          }
        ],
        likes: 0,
        views: 0,
        quizID: "",
        tags: ['Patient'],
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());
    DocumentReference topicDocRef =
        await topicCollectionRef.add(topic.toJson());
    topic.id = topicDocRef.id;

    await tester.pumpWidget(MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        themeManager: themeManager,
      ),
    ));

    await tester.pumpAndSettle();

    // Find the delete topic button and tap it
    await tester.ensureVisible(find.byKey(const Key('delete_topic_button')));
    await tester.tap(find.byKey(const Key('delete_topic_button')));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));

    await tester.pumpAndSettle();

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    expect(topicSnapshot.exists, true);

    expect(find.byKey(const Key('delete_topic_button')), findsOneWidget);
  });
}
