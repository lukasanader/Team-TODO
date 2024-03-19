import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../mock_classes.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

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

    firestore.collection('Users').doc('user123').set({
      'name': 'John Doe',
      'email': 'john@example.com',
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

    QuerySnapshot data = await ref.orderBy('title').get();
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );
    localAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    topicWithVideo = MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: localAuth,
          themeManager: themeManager),
    );

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });

  testWidgets('ViewTopicScreen shows correct fields with video',
      (WidgetTester tester) async {
    await tester.pumpWidget(topicWithVideo);
    await tester.pumpAndSettle();

    expect(find.text('video topic'), findsOneWidget);

    expect(find.text('Test Description'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Read Article'), findsOneWidget);

    expect(find.byType(Chewie), findsOneWidget);
  });

  testWidgets('ViewTopicScreen shows image', (WidgetTester tester) async {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [
        {'url': 'http://via.placeholder.com/350x150', 'mediaType': 'image'}
      ],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Pass a valid URL when creating the VideoPlayerController instance
    await mockNetworkImages(() async => await tester.pumpWidget(MaterialApp(
          home: ViewTopicScreen(
            firestore: firestore,
            storage: storage,
            topic: data.docs[0] as QueryDocumentSnapshot<Object>,
            auth: auth,
            themeManager: themeManager,
          ),
        )));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
  });
  testWidgets('next and previous buttons change current media',
      (WidgetTester tester) async {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [
        {'url': 'http://via.placeholder.com/350x150', 'mediaType': 'image'},
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
          'mediaType': 'video'
        },
        {
          'url':
              'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D',
          'mediaType': 'image'
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

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Pass a valid URL when creating the VideoPlayerController instance
    await mockNetworkImages(() async => await tester.pumpWidget(MaterialApp(
          home: ViewTopicScreen(
            firestore: firestore,
            storage: storage,
            topic: data.docs[0] as QueryDocumentSnapshot<Object>,
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
