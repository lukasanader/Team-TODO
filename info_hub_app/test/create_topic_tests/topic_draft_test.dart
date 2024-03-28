import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../mock_classes.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:info_hub_app/model/topic_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// This test file is responsible for testing topic drafts

void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  late PlatformFile imageFile;
  late PlatformFile videoFile;
  late List<PlatformFile> mediaFileList;
  List<String> urls1 = [];
  setUp(() {
    String videoPath = 'assets/sample-5s.mp4';
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
  }

  testWidgets('drafted topic with valid fields is published',
      (WidgetTester tester) async {
    CollectionReference draftCollectionRef;

    draftCollectionRef = firestore.collection('topicDrafts');

    await defineUserAndStorage(tester);
    DocumentSnapshot adminUserDoc =
        await firestore.collection('Users').doc('adminUser').get();

    Topic draftTopic = Topic(
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
      userID: adminUserDoc.id,
      quizID: '',
    );

    // Add the draft topic to Firestore
    DocumentReference draftDocRef =
        await draftCollectionRef.add(draftTopic.toJson());
    draftTopic.id = draftDocRef.id;

    // Update user document to include the draft topic
    await firestore.collection('Users').doc('adminUser').update({
      'draftedTopics': FieldValue.arrayUnion([draftDocRef.id])
    });

    await tester.pumpWidget(MaterialApp(
      home: TopicCreationView(
        draft: draftTopic,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
        selectedFiles: mediaFileList,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Submitted draft');

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    final publishButtonFinder = find.text('PUBLISH TOPIC');

    await tester.ensureVisible(publishButtonFinder);

    await tester.tap(publishButtonFinder);

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Submitted draft',
      ),
      isTrue,
    );

    ListResult listResult = await mockStorage.ref().child('media').listAll();

    // Get the first item in the list
    Reference? firstItem;
    if (listResult.items.isNotEmpty) {
      firstItem = listResult.items.first;
    }
    urls1.add(await firstItem!.getDownloadURL());
  });

  testWidgets('drafted topic replaces unused media in storage',
      (WidgetTester tester) async {
    CollectionReference draftCollectionRef;

    draftCollectionRef = firestore.collection('topicDrafts');

    await defineUserAndStorage(tester);
    DocumentSnapshot adminUserDoc =
        await firestore.collection('Users').doc('adminUser').get();

    Topic draftTopic2 = Topic(
      title: 'Submitted draft',
      description: 'Test Description',
      articleLink: '',
      media: [
        {'url': urls1[0], 'mediaType': 'video', 'thumbnail': urls1[0]},
      ],
      tags: ['Patient'],
      likes: 0,
      views: 0,
      dislikes: 0,
      categories: ['Sports'],
      date: DateTime.now(),
      userID: adminUserDoc.id,
      quizID: '',
    );

    // Add the draft topic to Firestore
    DocumentReference draftDocRef =
        await draftCollectionRef.add(draftTopic2.toJson());
    draftTopic2.id = draftDocRef.id;
    // Update user document to include the draft topic
    await firestore.collection('Users').doc('adminUser').update({
      'draftedTopics': FieldValue.arrayUnion([draftDocRef.id])
    });
    await tester.pumpWidget(MaterialApp(
      home: TopicCreationView(
        draft: draftTopic2,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
        selectedFiles: [
          PlatformFile(
            name: 'base_image.png',
            path: 'assets/base_image.png',
            size: 0,
          )
        ],
      ),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('PUBLISH TOPIC'));

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();
    ListResult listResult = await mockStorage.ref().child('media').listAll();
    expect(listResult.items.length, 1);
  });

  testWidgets('drafted topic can be deleted', (WidgetTester tester) async {
    CollectionReference draftCollectionRef;

    draftCollectionRef = firestore.collection('topicDrafts');

    await defineUserAndStorage(tester);
    DocumentSnapshot adminUserDoc =
        await firestore.collection('Users').doc('adminUser').get();

    Topic draftTopic = Topic(
      title: 'Test Topic',
      description: 'Test Description',
      articleLink: '',
      media: [
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-01%2018:28:20.745204.mp4?alt=media&token=6d6e3aee-240d-470f-ab22-58e274a04010',
          'mediaType': 'video',
          'thumbnail':
              'https://firebasestorage.googleapis.com/v0/b/some-bucket/o/thumbnails/blank_pfp.png'
        }
      ],
      tags: ['Patient'],
      likes: 0,
      views: 0,
      dislikes: 0,
      categories: ['Sports'],
      date: DateTime.now(),
      userID: adminUserDoc.id, // Replace with the actual user ID
      quizID: '',
    );
    final storageRef = mockStorage.ref().child('thumbnails');
    await storageRef.putString(
        'https://firebasestorage.googleapis.com/v0/b/some-bucket/o/thumbnails/blank_pfp.png');

    // Add the draft topic to Firestore
    DocumentReference draftDocRef =
        await draftCollectionRef.add(draftTopic.toJson());
    draftTopic.id = draftDocRef.id;

    // Update user document to include the draft topic
    await firestore.collection('Users').doc('adminUser').update({
      'draftedTopics': FieldValue.arrayUnion([draftDocRef.id])
    });

    await tester.pumpWidget(MaterialApp(
      home: TopicCreationView(
        draft: draftTopic,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete_draft_btn')));
    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topicDrafts").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Test Topic',
      ),
      isFalse,
    );
  });

  testWidgets('Can save as draft', (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await tester.runAsync(() async {
      tester.pumpWidget(MaterialApp(
        home: TopicCreationView(
          firestore: firestore,
          storage: mockStorage,
          auth: auth,
          themeManager: themeManager,
          selectedFiles: mediaFileList,
        ),
      ));
    });

    await fillRequiredFields(tester);

    await tester.ensureVisible(find.byKey(const Key('draft_btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('draft_btn')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topicDrafts").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(find.byType(TopicCreationView), findsNothing);

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Test title',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Test description',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['userID'] == auth.currentUser?.uid,
      ),
      isTrue,
    );

    final DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
        await firestore.collection('Users').doc('adminUser').get();
    final userData = userDocSnapshot.data();
    expect(userData, isNotNull);
    expect(userData?['draftedTopics'], hasLength(1));
    final List<String> draftedTopics =
        List<String>.from(userData?['draftedTopics']);
    expect(draftedTopics[0], equals(documents[0].id));
  });
}
