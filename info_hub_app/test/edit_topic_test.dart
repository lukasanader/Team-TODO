import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/topics/edit_topic.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/helpers/mock_classes.dart';
import 'package:info_hub_app/topics/quiz/create_quiz.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth auth;
  late MockFirebaseStorage mockStorage;
  late FakeFirebaseFirestore firestore;
  late CollectionReference topicCollectionRef;
  late QuerySnapshot data;

  setUp(() async {
    mockFilePicker();

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    firestore = FakeFirebaseFirestore();

    mockStorage = MockFirebaseStorage();

    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    topicCollectionRef = firestore.collection('topics');

    DocumentReference topicDocRef = await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': '',
      'videoUrl': '',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    data = await topicCollectionRef.orderBy('title').get();

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });
  testWidgets('Topic with valid fields updates', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Updated title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Updated description');

    await tester.enterText(find.byKey(const Key('linkField')),
        'https://www.health.org.uk/publications/journal-articles');

    final updateButtonFinder = find.text('UPDATE TOPIC');

    await tester.ensureVisible(updateButtonFinder);

    await tester.tap(updateButtonFinder);

    await tester.pump();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Updated title',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Updated description',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) =>
            doc.data()?['articleLink'] ==
            'https://www.health.org.uk/publications/journal-articles',
      ),
      isTrue,
    );
  });

  testWidgets('Topic with invalid fields does not update',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Updated title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Updated description');

    await tester.enterText(find.byKey(const Key('linkField')), 'https://');

    final updateButtonFinder = find.text('UPDATE TOPIC');

    await tester.ensureVisible(updateButtonFinder);

    await tester.tap(updateButtonFinder);

    await tester.pump();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Updated title',
      ),
      isFalse,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Updated description',
      ),
      isFalse,
    );

    expect(
      documents.any(
        (doc) =>
            doc.data()?['articleLink'] ==
            'https://www.health.org.uk/publications/journal-articles',
      ),
      isFalse,
    );
  });

  testWidgets('Uploaded video is successfuly stored and displays',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Upload a video'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();

    bool videoFound = false;
    final startTime = DateTime.now();
    while (!videoFound) {
      await tester.pump();

      if (find.text('Change video').evaluate().isNotEmpty) {
        videoFound = true;
        break;
      }

      if (DateTime.now().difference(startTime).inSeconds > 1800) {
        fail('Timed out waiting for the "Change video" text to appear');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    expect(find.text('Change video'), findsOneWidget);
    expect(find.byType(Chewie), findsOneWidget);

    expect(find.byKey(const Key('deleteButton')), findsOneWidget);

    final updateButtonFinder = find.text('UPDATE TOPIC');

    await tester.ensureVisible(updateButtonFinder);

    await tester.tap(updateButtonFinder);

    final ListResult result = await mockStorage.ref().child('videos').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('Uploaded video can be cleared', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.text('Upload a video'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();

    bool videoFound = false;
    final startTime = DateTime.now();
    while (!videoFound) {
      await tester.pump();

      if (find.text('Change video').evaluate().isNotEmpty) {
        videoFound = true;
        break;
      }

      if (DateTime.now().difference(startTime).inSeconds > 1800) {
        fail('Timed out waiting for the "Change video" text to appear');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final Finder buttonToTap = find.byKey(const Key('deleteButton'));

    await tester.dragUntilVisible(
      buttonToTap,
      find.byType(SingleChildScrollView),
      const Offset(0, 50),
    );
    await tester.tap(buttonToTap);

    await tester.pump();

    expect(find.byType(Chewie), findsNothing);
    expect(find.text('Change video'), findsNothing);
    expect(find.text('Upload a video'), findsOneWidget);
  });

  testWidgets('Test Create Quiz Screen From Create Topic Screen',
      (WidgetTester tester) async {
    Widget quizWidget = MaterialApp(
      home: EditTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        firestore: firestore,
        storage: mockStorage,
      ),
    );

    await tester.pumpWidget(quizWidget);
    await tester.pumpAndSettle();

    expect(find.text('ADD QUIZ'), findsOneWidget);
    await tester.tap(find.text('ADD QUIZ'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateQuiz), findsOne);

    final addQuestionButton = find.text('Add Question');
    expect(addQuestionButton, findsOneWidget);

    await tester.tap(addQuestionButton); //Add an invalid question
    await tester.pumpAndSettle();
    expect(find.text('Please enter a question'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'What is a liver?');
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle();

    expect(find.text('1. What is a liver?'), findsOneWidget);

    final addAnswerButton = find.byIcon(Icons.add);
    expect(addAnswerButton, findsOne);

    await tester.tap(addAnswerButton); //Enter an invalid answer
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid answer'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('answerField')), 'An organ');
    await tester.ensureVisible(addAnswerButton);
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();
    expect(find.text('1. An organ'), findsOne); //answer card has been added

    final saveQuestionButton = find.text('Save');
    expect(saveQuestionButton, findsOne);
    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton); //Save question without an answer
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid question'), findsOneWidget);
    //prompts user to add valid question
    await tester.enterText(find.byKey(const Key('answerField')), 'A person');
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1. An organ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1. An organ')); //select correct answer
    await tester.pumpAndSettle();
    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton);
    await tester.pumpAndSettle();

    expect(find.text('Question has been saved!'),
        findsOne); //check to see if question has been saved correctly

    final saveQuizButton = find.text('Save Quiz');
    expect(saveQuizButton, findsOne);
    await tester.ensureVisible(saveQuizButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuizButton); //Save question without an answer
    await tester.pumpAndSettle();
  });

  testWidgets('Test uploading new video clears old one',
      (WidgetTester tester) async {
    CollectionReference tempCollectionRef = firestore.collection('topics');

    // Add a topic
    DocumentReference videoTopicRef = await tempCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': 'https://www.example.com',
      'videoUrl':
          'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-28%2000:36:29.473449.mp4?alt=media&token=65864340-7a28-4aec-aac2-ed98d3eb4532',
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'date': DateTime.now()
    });

    QuerySnapshot data = await tempCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: EditTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        topic: data.docs[1] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Change video'), findsOneWidget);

    final Finder buttonToTap = find.byKey(const Key('deleteButton'));

    await tester.dragUntilVisible(
      buttonToTap,
      find.byType(SingleChildScrollView),
      const Offset(0, 50),
    );
    await tester.tap(buttonToTap);

    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();

    bool videoFound = false;
    final startTime = DateTime.now();
    while (!videoFound) {
      await tester.pump();

      if (find.text('Change video').evaluate().isNotEmpty) {
        videoFound = true;
        break;
      }

      if (DateTime.now().difference(startTime).inSeconds > 1800) {
        fail('Timed out waiting for the "Change video" text to appear');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final updateButtonFinder = find.text('UPDATE TOPIC');

    await tester.ensureVisible(updateButtonFinder);

    await tester.tap(updateButtonFinder);

    final ListResult result = await mockStorage.ref().child('videos').listAll();

    expect(result.items.length, equals(0));
  });

  testWidgets('Orientation adjusts correctly', (WidgetTester tester) async {
    final logs = [];

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
      if (methodCall.method == 'SystemChrome.setPreferredOrientations') {
        logs.add((methodCall.arguments as List)[0]);
      }
      return null;
    });
    expect(logs.length, 0);

    await tester.pumpWidget(MaterialApp(
      home: EditTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadVideoButton')));
    await tester.pumpAndSettle();

    bool videoFound = false;
    final startTime = DateTime.now();
    while (!videoFound) {
      await tester.pump();

      if (find.text('Change video').evaluate().isNotEmpty) {
        videoFound = true;
        break;
      }

      if (DateTime.now().difference(startTime).inSeconds > 1800) {
        fail('Timed out waiting for the "Change video" text to appear');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    expect(find.text('Change video'), findsOneWidget);

    expect(find.byType(Chewie), findsOneWidget);

    final Chewie chewieWidget = tester.widget<Chewie>(find.byType(Chewie));

    await tester.pumpAndSettle();

    chewieWidget.controller.enterFullScreen();

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
  });
}
