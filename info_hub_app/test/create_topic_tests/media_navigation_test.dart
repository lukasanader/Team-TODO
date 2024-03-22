import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/topics/create_topic/create_topic.dart';
import 'package:http/http.dart' as http;
import 'package:chewie/chewie.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../mock_classes.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  late PlatformFile imageFile;
  late PlatformFile videoFile;
  late List<PlatformFile> mediaFileList;
  setUp(() {
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
  }

  testWidgets('next and previous buttons change current media',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    await defineUserAndStorage(tester);
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'multimedia topic',
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
          home: CreateTopicScreen(
            auth: auth,
            firestore: firestore,
            storage: mockStorage,
            topic: data.docs[0],
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

  testWidgets('Selected media can be replaced', (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
        selectedFiles: mediaFileList,
      ),
    ));

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    // video replaces the image
    expect(find.byType(Chewie), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets(
      'when video is changed or deselected, old video gets deleted from storage',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef;
    QuerySnapshot data;

    topicCollectionRef = firestore.collection('topics');
    await defineUserAndStorage(tester);

    await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': '',
      'media': [
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-27%2022%3A09%3A02.035911.mp4?alt=media&token=ea6b51e9-9e9f-4d2e-a014-64fc3631e321',
          'mediaType': 'video'
        },
      ],
      'likes': 0,
      'tags': ['Patient'],
      'views': 0,
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now(),
      'quizID': ''
    });

    const url =
        'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-27%2022%3A09%3A02.035911.mp4?alt=media&token=ea6b51e9-9e9f-4d2e-a014-64fc3631e321';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Extract the content from the response
      final String content = response.body;

      // Upload the content to Firebase Storage as a string
      final ref = mockStorage.ref().child('media');
      await ref.putString(content, format: PutStringFormat.raw);
    }

    data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
        selectedFiles: mediaFileList,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('UPDATE TOPIC'));

    await tester.tap(find.text('UPDATE TOPIC'));

    await tester.pumpAndSettle();
    final ListResult result = await mockStorage.ref().child('media').listAll();
    expect(result.items.length, 1);
  });

  testWidgets('media can be cleared and navigates to media in front correctly',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    List<PlatformFile> media = [videoFile, imageFile];

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        selectedFiles: media,
        themeManager: themeManager,
      ),
    ));

    // upload a video
    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();
    // add an image
    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();
    // go back to the video
    await tester.ensureVisible(find.byKey(const Key('previousMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('previousMediaButton')));
    await tester.pumpAndSettle();
    // clear the video selection
    await tester.ensureVisible(find.byKey(const Key('deleteVideoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteVideoButton')));
    await tester.pumpAndSettle();
    // check that image in front has been navigated to
    expect(find.byType(Image), findsOneWidget);
    // add a video
    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();
    // go back to the image
    await tester.ensureVisible(find.byKey(const Key('previousMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('previousMediaButton')));
    await tester.pumpAndSettle();
    // clear the image selection
    await tester.ensureVisible(find.byKey(const Key('deleteImageButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteImageButton')));
    await tester.pumpAndSettle();
    //check that the video in front has been navigated to
    expect(find.byType(Chewie), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('deleteVideoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteVideoButton')));
    await tester.pumpAndSettle();
    //check that no video appears
    expect(find.byType(Chewie), findsNothing);
  });

  testWidgets('cleared media navigates to media behind correctly',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    List<PlatformFile> media = [videoFile, imageFile];

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        selectedFiles: media,
        themeManager: themeManager,
      ),
    ));

    //upload an image
    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    // upload a video
    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    // add another image
    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();
    // clear the image selection
    await tester.ensureVisible(find.byKey(const Key('deleteImageButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteImageButton')));
    await tester.pumpAndSettle();
    // check that video behind has been navigated to
    expect(find.byType(Chewie), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('deleteVideoButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteVideoButton')));
    await tester.pumpAndSettle();
    // check that Image behind has been navigated to
    expect(find.byType(Image), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('deleteImageButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteImageButton')));
    await tester.pumpAndSettle();
    // check that no image is found
    expect(find.byType(Image), findsNothing);
  });
}
