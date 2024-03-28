import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/view/topic_view/topic_view.dart';
import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../test_helpers/mock_classes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_hub_app/model/topic_models/topic_model.dart';
import 'package:info_hub_app/view/thread_view/threads.dart';

/// This test file is responsible for testing that elements of the topic view screen can be utilised
void main() {
  late MockUrlLauncher mockLauncher;
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

    CollectionReference ref = firestore.collection('topics');

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

    DocumentReference topicRef = await ref.add(topic.toJson());

    topic.id = topicRef.id;

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

    mockLauncher = MockUrlLauncher();
    UrlLauncherPlatform.instance = mockLauncher;
  });

  testWidgets('Test article link opens', (WidgetTester tester) async {
    await tester.pumpWidget(topicWithVideo);

    mockLauncher
      ..setLaunchExpectations(
        url: 'https://www.javatpoint.com/heap-sort',
        useSafariVC: false,
        useWebView: false,
        universalLinksOnly: false,
        enableJavaScript: true,
        enableDomStorage: true,
        headers: <String, String>{},
      )
      ..setResponse(true);

    final elevatedButton = find.widgetWithText(ElevatedButton, 'Read Article');
    expect(elevatedButton, findsOneWidget);

    await tester.tap(elevatedButton);

    await tester.pumpAndSettle();
  });

  testWidgets('Admin user can use edit topic button',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;

    Topic topic = Topic(
        title: 'no video topic',
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
        views: 0,
        quizID: "",
        tags: ['Patient'],
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());
    DocumentReference topicRef = await topicCollectionRef.add(topic.toJson());
    topic.id = topicRef.id;

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

    await tester.ensureVisible(find.byKey(const Key('edit_btn')));

    await tester.pumpAndSettle();
    // check that admin user sees edit topic button

    expect(find.byKey(const Key('edit_btn')), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit_btn')));

    await tester.pumpAndSettle();

    expect(fakeVideoPlayerPlatform.calls.contains('pause'), true);

    expect(find.byType(TopicCreationView), findsOneWidget);
    await tester.ensureVisible(find.text("UPDATE TOPIC"));
    await tester.tap(find.text("UPDATE TOPIC"));
    await tester.pumpAndSettle();
    expect(find.byType(TopicView), findsOneWidget);
  });
  testWidgets('Test navigation to ThreadApp screen',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));
    CollectionReference topicCollectionRef = firestore.collection('topics');

    Topic topic = Topic(
        title: 'no video topic',
        description: 'Test Description',
        articleLink: 'https://www.javatpoint.com/heap-sort',
        media: [],
        likes: 0,
        tags: ['Patient'],
        views: 0,
        quizID: "",
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());

    DocumentReference topicRef = await topicCollectionRef.add(topic.toJson());
    topic.id = topicRef.id;
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

    // Find the comment icon button and tap it
    await tester.tap(find.byIcon(FontAwesomeIcons.comments));

    // Wait for the navigation to complete
    await tester.pumpAndSettle();

    // Check if the ThreadApp screen is pushed to the navigator stack
    expect(find.byType(ThreadApp), findsOneWidget);
  });
  testWidgets('User can save a topic', (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    Topic topic = Topic(
        title: 'no video topic',
        description: 'Test Description',
        articleLink: 'https://www.javatpoint.com/heap-sort',
        media: [],
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

    DocumentReference mockUserDocRef =
        firestore.collection('Users').doc('adminUser');

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
    await tester.ensureVisible(find.byIcon(Icons.bookmark_border));
    // Find the save icon button and tap it
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();
    DocumentSnapshot saveUserSnapshot = await mockUserDocRef.get();
    List<dynamic> listAfterSave = [];
    if (saveUserSnapshot.exists && saveUserSnapshot.data() != null) {
      listAfterSave = List<dynamic>.from(saveUserSnapshot['savedTopics']);
    } else {
      fail("'savedTopics' field not found in user's document");
    }
    expect(listAfterSave.contains(topicDocRef.id), true);
    await tester.ensureVisible(find.byIcon(Icons.bookmark));
    // tap save icon again to unsave
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pumpAndSettle();
    DocumentReference unsaveUserDocRef =
        firestore.collection('Users').doc('adminUser');
    DocumentSnapshot unsaveUserSnapshot = await unsaveUserDocRef.get();

    List<dynamic> listAfterUnsave =
        List<dynamic>.from(unsaveUserSnapshot['savedTopics']);
    expect(listAfterUnsave.contains(topicDocRef.id), false);
  });
}
