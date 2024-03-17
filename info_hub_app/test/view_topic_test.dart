import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'mock_classes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_hub_app/threads/threads.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  late MockUrlLauncher mock;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockFirebaseAuth localAuth;
  late MockFirebaseStorage storage;
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
    // Pass a valid URL when creating the VideoPlayerController instance
    topicWithVideo = MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: localAuth),
    );

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;

    mock = MockUrlLauncher();
    UrlLauncherPlatform.instance = mock;
  });

  testWidgets('ViewTopicScreen shows correct fields with video',
      (WidgetTester tester) async {
    // Pass a valid URL when creating the VideoPlayerController instance
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
              auth: auth),
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
              auth: auth),
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

  testWidgets('Test article link opens', (WidgetTester tester) async {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    await tester.pumpWidget(topicWithVideo);

    mock
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

  testWidgets('ViewTopicScreen shows like and dislike buttons',
      (WidgetTester tester) async {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    await tester.pumpWidget(topicWithVideo);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down), findsOneWidget);
  });

  testWidgets('Test tapping thumb up icon increments likes by one',
      (WidgetTester tester) async {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
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
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'views': 0,
      'quizId': "",
      'tags': ['Patient'],
      'dislikes': 0,
      'categories': ['Sports'],
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
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // Add a topic with initial likes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'views': 0,
      'quizId': "",
      'tags': ['Patient'],
      'dislikes': 0,
      'categories': ['Sports'],
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
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'views': 0,
      'quizId': "",
      'tags': ['Patient'],
      'dislikes': 0,
      'categories': ['Sports'],
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
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    // topic with initial likes and dislikes count of 0
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'views': 0,
      'quizId': "",
      'tags': ['Patient'],
      'dislikes': 0,
      'categories': ['Sports'],
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
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
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

  testWidgets('Admin user sees edit topic button', (WidgetTester tester) async {
    // Mock user data
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    CollectionReference topicCollectionRef = firestore.collection('topics');

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;

    await topicCollectionRef.add({
      'title': 'no video topic',
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
      'views': 0,
      'quizId': "",
      'tags': ['Patient'],
      'dislikes': 0,
      'categories': ['Sports'],
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

    await tester.ensureVisible(find.byKey(const Key('edit_btn')));

    await tester.pumpAndSettle();
    // check that admin user sees edit topic button

    expect(find.byKey(const Key('edit_btn')), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit_btn')));

    await tester.pumpAndSettle();

    expect(fakeVideoPlayerPlatform.calls.contains('pause'), true);

    expect(find.byType(CreateTopicScreen), findsOneWidget);
  });

  testWidgets('Test tapping delete topic button deletes the topic',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    Map<String, dynamic> details = {
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'media': [
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
          'mediaType': 'video'
        }
      ],
      'likes': 0,
      'views': 0,
      'quizId': "",
      'tags': ['Patient'],
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now()
    };

    // Add a topic
    DocumentReference ref = await topicCollectionRef.add(details);

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();
    Widget deleteView = MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: storage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
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

    // Add a topic
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'media': [],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
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
    // dislike topic
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
    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'media': [],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
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
  testWidgets('Test navigation to ThreadApp screen',
      (WidgetTester tester) async {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
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

    // Find the comment icon button and tap it
    await tester.tap(find.byIcon(FontAwesomeIcons.comments));

    // Wait for the navigation to complete
    await tester.pumpAndSettle();

    // Check if the ThreadApp screen is pushed to the navigator stack
    expect(find.byType(ThreadApp), findsOneWidget);
  });
  testWidgets('User can save a topic', (WidgetTester tester) async {
    CollectionReference topicCollectionRef = firestore.collection('topics');

    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'media': [],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'quizId': "",
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now()
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    DocumentReference mockUserDocRef =
        firestore.collection('Users').doc('adminUser');

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
          firestore: firestore,
          storage: storage,
          topic: data.docs[0] as QueryDocumentSnapshot<Object>,
          auth: MockFirebaseAuth(
              signedIn: true, mockUser: MockUser(uid: 'adminUser'))),
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
