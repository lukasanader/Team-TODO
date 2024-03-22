import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import '../mock_classes.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  late PlatformFile imageFile;
  late PlatformFile videoFile;
  late List<PlatformFile> mediaFileList;
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
  }

  testWidgets('drafted topic with valid fields is published',
      (WidgetTester tester) async {
    CollectionReference draftCollectionRef;

    QuerySnapshot data;

    draftCollectionRef = firestore.collection('topicDrafts');

    await defineUserAndStorage(tester);
    DocumentSnapshot adminUserDoc =
        await firestore.collection('Users').doc('adminUser').get();

    DocumentReference draftDocRef = await draftCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': '',
      'media': [
        {
          'url':
              'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-27%2022%3A09%3A02.035911.mp4?alt=media&token=ea6b51e9-9e9f-4d2e-a014-64fc3631e321',
          'mediaType': 'video'
        }
      ],
      'tags': ['Patient'],
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now(),
      'userID': adminUserDoc.id,
      'quizID': ''
    });
    await firestore.collection('Users').doc('adminUser').update({
      'draftedTopics': FieldValue.arrayUnion([draftDocRef.id])
    });

    data = await draftCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        draft: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Submitted draft');

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
  });

  testWidgets('Can save as draft', (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
        selectedFiles: mediaFileList,
      ),
    ));

    await fillRequiredFields(tester);

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('draft_btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('draft_btn')));

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topicDrafts").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

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

    final ListResult result = await mockStorage.ref().child('media').listAll();
    final DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
        await firestore.collection('Users').doc('adminUser').get();
    final userData = userDocSnapshot.data();
    expect(userData, isNotNull);
    expect(userData?['draftedTopics'], hasLength(1));
    final List<String> draftedTopics =
        List<String>.from(userData?['draftedTopics']);
    expect(draftedTopics[0], equals(documents[0].id));
    expect(result.items.length, greaterThan(0));
  });
}
