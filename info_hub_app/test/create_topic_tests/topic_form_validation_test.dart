import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:file_picker/file_picker.dart';

/// This test file is responsible for testing the create topic form validation
void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  late PlatformFile imageFile;
  late PlatformFile videoFile;
  late List<PlatformFile> mediaFileList;
  Widget? basicWidget;
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
      home: TopicCreationView(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    );
  }

  testWidgets('Topic with no title does not save', (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('PUBLISH TOPIC'));

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic with no description does not save',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await tester.pumpWidget(basicWidget!);

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });
  testWidgets('Topic with no tags does not save', (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await tester.pumpWidget(basicWidget!);

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });
  testWidgets('Topic with invalid article link does not save',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);

    await fillRequiredFields(tester);

    await tester.enterText(find.byKey(const Key('linkField')), 'invalidLink');
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;
    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Cannot save topic draft with no title',
      (WidgetTester tester) async {
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
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test invalid draft');

    await tester.ensureVisible(find.byKey(const Key('draft_btn')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('draft_btn')));
    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topicDrafts").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(find.byType(SnackBar), findsOneWidget);

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Test invalid draft',
      ),
      isFalse,
    );
  });
}
