import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../test/mock_classes.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:info_hub_app/model/topic_model.dart';

/// This test file is responsible for testing the media upload using file picker when creating topics.
void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  Widget? basicWidget;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    firestore = FakeFirebaseFirestore();

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });
  // Fills the required fields in the widget
  Future<void> fillRequiredFields(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');
    await tester.ensureVisible(find.byType(AppBar));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppBar), warnIfMissed: false);
  }

  Future<void> defineUserAndStorage(WidgetTester tester) async {
    mockStorage = MockFirebaseStorage();
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    basicWidget = MaterialApp(
      home: TopicCreationView(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    );
  }

  testWidgets('video can be uploaded and is successfully stored and displayed',
      (WidgetTester tester) async {
    mockFilePicker('sample-5s.mp4');
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);

    await fillRequiredFields(tester);

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();
    expect(find.text('Change Media'), findsOneWidget);
    expect(find.byType(Chewie), findsOneWidget);
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();

    final ListResult result = await mockStorage.ref().child('media').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('image can be uploaded and is successfully stored and displayed',
      (WidgetTester tester) async {
    mockFilePicker('blank_pfp.png');
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);

    await fillRequiredFields(tester);

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();
    expect(find.text('Change Media'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();

    final ListResult result = await mockStorage.ref().child('media').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('edited topic with valid fields updates',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    mockFilePicker('sample-5s.mp4');

    Topic topic = Topic(
      title: 'Test Topic',
      description: 'Test Description',
      articleLink: '',
      media: [],
      tags: ['Patient'],
      likes: 0,
      views: 0,
      dislikes: 0,
      categories: ['Sports'],
      date: DateTime.now(),
      quizID: '1',
    );
    CollectionReference topicCollectionRef = firestore.collection('topics');

    DocumentReference topicRef = await topicCollectionRef.add(topic.toJson());
    topic.id = topicRef.id;

    await tester.pumpWidget(MaterialApp(
      home: TopicCreationView(
        topic: topic,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Updated title');

    await tester.ensureVisible(find.byType(AppBar));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppBar), warnIfMissed: false);
    
    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')),
        warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.ensureVisible(find.text('UPDATE TOPIC'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('UPDATE TOPIC'));

    await tester.pumpAndSettle();

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
  });
}
