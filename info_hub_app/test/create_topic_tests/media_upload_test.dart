import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../mock_classes.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  late PlatformFile imageFile;
  late PlatformFile videoFile;
  Widget? basicWidget;

  late List<PlatformFile> mediaFileList;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockFilePicker();

    String videoPath = 'info_hub_app/assets/sample-5s.mp4';
    String imagePath = 'assets/blank_pfp.png';

    videoFile = PlatformFile(
      name: 'sample-5s.mp4',
      path: videoPath,
      size: 0,
    );
    imageFile = PlatformFile(
      name: 'blank_pfp.png',
      path: imagePath,
      size: 0,
    );

    mediaFileList = [videoFile, imageFile];

    firestore = FakeFirebaseFirestore();

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });
  Future<void> fillRequiredFields(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');
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
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    );
  }

  testWidgets('Uploaded video is successfully stored and displays',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);

    await fillRequiredFields(tester);

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    final startTime = DateTime.now();
    while (true) {
      await tester.pump();

      if (find.text('Change Media').evaluate().isNotEmpty) {
        break;
      }

      if (DateTime.now().difference(startTime).inSeconds > 1800) {
        fail('Timed out waiting for the "Change Media" text to appear');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    expect(find.byType(Chewie), findsOneWidget);
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();

    final ListResult result = await mockStorage.ref().child('media').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('Uploaded image is successfully stored and displays',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);

    await fillRequiredFields(tester);

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    bool videoFound = false;
    final startTime = DateTime.now();
    while (!videoFound) {
      await tester.pump();

      if (find.text('Change Media').evaluate().isNotEmpty) {
        videoFound = true;
        break;
      }

      if (DateTime.now().difference(startTime).inSeconds > 1800) {
        fail('Timed out waiting for the "Change Media" text to appear');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

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

    Topic topic = Topic(
      title: 'Test Topic',
      description: 'Test Description',
      articleLink: '',
      media: [
        {
          'url':
              'https://fastly.picsum.photos/id/629/200/300.jpg?hmac=YTSnJIQbXgJTOWUeXAqVeQYHZDodXXFFJxd5RTKs7yU',
          'mediaType': 'image'
        }
      ],
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
      home: CreateTopicScreen(
        topic: topic,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
        selectedFiles: mediaFileList,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Updated title');

    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    final updateButtonFinder = find.text('UPDATE TOPIC');

    await tester.ensureVisible(updateButtonFinder);

    await tester.tap(updateButtonFinder);

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
