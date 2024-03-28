import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/view/topic_view/topic_view.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../mock_classes.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:info_hub_app/model/topic_model.dart';

/// This test file is responsible for testing the display of media on the topic view screen
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockFirebaseAuth localAuth;
  late MockFirebaseStorage storage;
  late ThemeManager themeManager = ThemeManager();
  late Widget topicWithVideo;

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
    CollectionReference topicCollectionRef = firestore.collection('topics');

    Topic topic = Topic(
      title: 'video topic',
      description: 'Test Description',
      articleLink: 'https://www.javatpoint.com/heap-sort',
      media: [
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
          'mediaType': 'video',
          'thumbnail':
              'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
        }
      ],
      likes: 0,
      tags: ['Patient'],
      views: 0,
      quizID: "",
      dislikes: 0,
      categories: ['Sports'],
      date: DateTime.now(),
    );
    DocumentReference topicDocRef =
        await topicCollectionRef.add(topic.toJson());
    topic.id = topicDocRef.id;

    localAuth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    topicWithVideo = MaterialApp(
      home: TopicView(
          firestore: firestore,
          storage: storage,
          topic: topic,
          auth: localAuth,
          themeManager: themeManager),
    );

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });

  testWidgets('TopicView shows correct fields with video',
      (WidgetTester tester) async {
    await tester.pumpWidget(topicWithVideo);
    await tester.pumpAndSettle();

    expect(find.text('video topic'), findsOneWidget);

    expect(find.text('Test Description'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Read Article'), findsOneWidget);

    expect(find.byType(Chewie), findsOneWidget);
  });

  testWidgets('TopicView shows image', (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    Topic topic = Topic(
        title: 'video topic',
        description: 'Test Description',
        articleLink: 'https://www.javatpoint.com/heap-sort',
        media: [
          {
            'url': 'http://via.placeholder.com/350x150',
            'mediaType': 'image',
            'thumbnail':
                'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
          }
        ],
        likes: 0,
        tags: ['Patient'],
        views: 0,
        quizID: "",
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());

    DocumentReference topicDocRef =
        await topicCollectionRef.add(topic.toJson());
    topic.id = topicDocRef.id;

    await mockNetworkImages(() async => await tester.pumpWidget(MaterialApp(
          home: TopicView(
            firestore: firestore,
            storage: storage,
            topic: topic,
            auth: MockFirebaseAuth(
                signedIn: true, mockUser: MockUser(uid: 'adminUser')),
            themeManager: themeManager,
          ),
        )));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });
  testWidgets('next and previous buttons change current media',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    CollectionReference topicCollectionRef = firestore.collection('topics');

    Topic topic = Topic(
        title: 'video topic',
        description: 'Test Description',
        articleLink: 'https://www.javatpoint.com/heap-sort',
        media: [
          {
            'url': 'http://via.placeholder.com/350x150',
            'mediaType': 'image',
            'thumbnail':
                'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
          },
          {
            'url':
                'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
            'mediaType': 'video',
            'thumbnail':
                'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
          },
          {
            'url':
                'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D',
            'mediaType': 'image',
            'thumbnail':
                'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
          }
        ],
        likes: 0,
        tags: ['Patient'],
        views: 0,
        quizID: "",
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());

    DocumentReference topicDocRef =
        await topicCollectionRef.add(topic.toJson());
    topic.id = topicDocRef.id;

    await mockNetworkImages(() async => await tester.pumpWidget(MaterialApp(
          home: TopicView(
            firestore: firestore,
            storage: storage,
            topic: topic,
            auth: auth,
            themeManager: themeManager,
          ),
        )));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('nextMediaButton')));
    await tester.tap(find.byKey(const Key('nextMediaButton')));
    await tester.pumpAndSettle();
    expect(find.byType(Chewie), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('previousMediaButton')));
    await tester.tap(find.byKey(const Key('previousMediaButton')));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('nextMediaButton')));
    await tester.tap(find.byKey(const Key('nextMediaButton')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('nextMediaButton')));
    await tester.tap(find.byKey(const Key('nextMediaButton')));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('previousMediaButton')));
    await tester.tap(find.byKey(const Key('previousMediaButton')));
    await tester.pumpAndSettle();
    expect(find.byType(Chewie), findsOneWidget);
  });
}
