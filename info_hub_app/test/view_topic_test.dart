import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:info_hub_app/topics/edit_topic.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/helpers/mock_classes.dart';

void main() {
  late MockUrlLauncher mock;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockFirebaseStorage storage;
  setUp(() {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();

    firestore.collection('Users').doc('user123').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    firestore.collection('Users').doc('nonAdminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'Patient',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;

    mock = MockUrlLauncher();
    UrlLauncherPlatform.instance = mock;
  });

  testWidgets('ViewTopicScreen shows title', (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    expect(find.text('no video topic'), findsOneWidget);

    expect(find.text('Test Description'), findsOneWidget);
  });

  testWidgets('ViewTopicScreen shows correct fields with video',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Pass a valid URL when creating the VideoPlayerController instance
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    expect(find.text('video topic'), findsOneWidget);

    expect(find.text('Test Description'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Read Article'), findsOneWidget);

    expect(find.byType(Chewie), findsOneWidget);
  });

  testWidgets('Test article link opens', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'http://www.javatpoint.com/heap-sort',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));

    mock
      ..setLaunchExpectations(
        url: 'http://www.javatpoint.com/heap-sort',
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

  testWidgets('Test orientation changes correctly with video fullscreen',
      (tester) async {
    final logs = [];
    final firestore = FakeFirebaseFirestore();

    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'video topic',
      'description': 'Test Description',
      'articleLink': 'http://www.javatpoint.com/heap-sort',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
      if (methodCall.method == 'SystemChrome.setPreferredOrientations') {
        logs.add((methodCall.arguments as List)[0]);
      }
      return null;
    });

    expect(logs.length, 0);

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));

    await tester.pumpAndSettle();

    expect(find.byType(Chewie), findsOneWidget);

    final Chewie chewieWidget = tester.widget<Chewie>(find.byType(Chewie));

    chewieWidget.controller.enterFullScreen();
    await tester.pumpAndSettle();

    expect(logs.length, 1,
        reason:
            'It should have added an orientation log after the fullscreen entry');

    chewieWidget.controller.exitFullScreen();

    expect(logs.length, 2,
        reason:
            'It should have added an orientation log after the fullscreen exit');

    expect(logs.last, 'DeviceOrientation.portraitUp',
        reason:
            'It should be in the portrait view after the fullscreen actions done');

    await tester.pumpAndSettle();
  });

  testWidgets('ViewTopicScreen shows like and dislike buttons',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down), findsOneWidget);
  });

  testWidgets('Test tapping thumb up icon increments likes by one',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic with initial likes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0, // Initial likes count
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Create the ViewTopicScreen widget with the test topic
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
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
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0, // Initial likes count
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
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
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic with initial likes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0, // Initial likes count
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    // Create the ViewTopicScreen widget with the test topic
    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
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
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0, // Initial likes count
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
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
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0, // Initial likes count
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
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
    CollectionReference topicCollectionRef = firestore.collection('topics');

    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: auth),
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

  testWidgets('Admin user sees delete topic button',
      (WidgetTester tester) async {
    // Mock user data
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));

    await tester.pumpAndSettle();

    final deleteButtonFinder = find.byKey(const Key('delete_topic_button'));

    await tester.ensureVisible(deleteButtonFinder);

    await tester.pumpAndSettle();
    // check that admin user sees delete topic button

    expect(deleteButtonFinder, findsOneWidget);
  });

  testWidgets('Admin user sees edit topic button', (WidgetTester tester) async {
    // Mock user data
    CollectionReference topicCollectionRef = firestore.collection('topics');

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));

    await tester.pumpAndSettle();

    final editButtonFinder = find.byKey(const Key('edit_btn'));

    await tester.ensureVisible(editButtonFinder);

    await tester.pumpAndSettle();
    // check that admin user sees edit topic button

    expect(editButtonFinder, findsOneWidget);

    await tester.tap(editButtonFinder);

    await tester.pumpAndSettle();

    expect(fakeVideoPlayerPlatform.calls.contains('pause'), true);

    expect(find.byType(EditTopicScreen), findsOneWidget);
  });

  testWidgets('Non-Admin user cannot see delete topic button',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'nonAdminUser')),
      ),
    ));

    await tester.pumpAndSettle();
    // check that non-admin user cannot see the delete topic button
    expect(find.byKey(const Key('delete_topic_button')), findsNothing);
  });

  testWidgets('Test tapping delete topic button deletes the topic',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));

    await tester.pumpAndSettle();

    // Find the delete topic button and tap it
    await tester.tap(find.byKey(const Key('delete_topic_button')));

    // Wait for the asynchronous operations to complete
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Delete'));

    await tester.pumpAndSettle();

    // topic is deleted from firebase

    DocumentSnapshot topicSnapshot = await topicDocRef.get();

    expect(topicSnapshot.exists, false);

    final ListResult result = await storage.ref().child('videos').listAll();

    expect(result.items.length, equals(0));
  });

  testWidgets(
      'Test tapping delete topic button then cancel does not delete topic',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));

    await tester.pumpAndSettle();

    // Find the delete topic button and tap it
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

  testWidgets('Test delete topic button removes topic from user liked topics',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));

    await tester.pumpAndSettle();

    DocumentReference adminUserDocRef =
        firestore.collection('Users').doc('adminUser');

    // like topic
    await tester.tap(find.byIcon(Icons.thumb_up));

    await tester.pumpAndSettle();

    DocumentSnapshot adminUserSnapshot = await adminUserDocRef.get();

    List<dynamic> listAfterLike =
        List<dynamic>.from(adminUserSnapshot['likedTopics']);

    expect(listAfterLike.contains(topicDocRef.id), true);

    await tester.tap(find.byKey(const Key('delete_topic_button')));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));

    await tester.pumpAndSettle();

    DocumentSnapshot secondSnapshot = await adminUserDocRef.get();

    List<dynamic> listAfterDelete =
        List<dynamic>.from(secondSnapshot['likedTopics']);

    expect(listAfterDelete.contains(topicDocRef.id), false);
  });

  testWidgets(
      'Test delete topic button removes topic from user disliked topics',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));

    await tester.pumpAndSettle();

    DocumentReference adminUserDocRef =
        firestore.collection('Users').doc('adminUser');

    // like topic
    await tester.tap(find.byIcon(Icons.thumb_down));

    await tester.pumpAndSettle();

    DocumentSnapshot adminUserSnapshot = await adminUserDocRef.get();

    List<dynamic> listAfterDislike =
        List<dynamic>.from(adminUserSnapshot['dislikedTopics']);

    expect(listAfterDislike.contains(topicDocRef.id), true);

    await tester.tap(find.byKey(const Key('delete_topic_button')));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));

    await tester.pumpAndSettle();

    DocumentSnapshot secondSnapshot = await adminUserDocRef.get();

    List<dynamic> listAfterDelete =
        List<dynamic>.from(secondSnapshot['dislikedTopics']);

    expect(listAfterDelete.contains(topicDocRef.id), false);
  });
}
