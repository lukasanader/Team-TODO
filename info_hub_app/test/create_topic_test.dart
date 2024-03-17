import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'mock_classes.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:file_picker/file_picker.dart';
import 'package:info_hub_app/ask_question/question_card.dart';

void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late PlatformFile imageFile;
  late PlatformFile videoFile;
  late List<PlatformFile> fileListOneVideo;
  late List<PlatformFile> fileListOneImage;
  late List<PlatformFile> fileListImageAndVideo;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockFilePicker();

    String videoPath = 'info_hub_app/assets/sample-5s.mp4';
    String imagePath = 'assets/blank_pfp.png';

    videoFile = PlatformFile(
      name: 'sample-5s.mp4', // Replace with the actual file name
      path: videoPath,
      size: 0, // If the size is unknown or not needed, you can set it to 0
    );
    imageFile = PlatformFile(
      name: 'blank_pfp.png', // Replace with the actual file name
      path: imagePath,
      size: 0, // If the size is unknown or not needed, you can set it to 0
    );
    fileListOneVideo = [videoFile];
    fileListOneImage = [imageFile];
    fileListImageAndVideo = [videoFile, imageFile];

    firestore = FakeFirebaseFirestore();

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });
  testWidgets('Topic with title,description, category and tag save',
      (WidgetTester tester) async {
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    await firestore.collection('categories').add({'name': 'Gym'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));
    int maxScrollAttempts = 5;

    for (int i = 0; i < maxScrollAttempts; i++) {
      if (tester.any(find.text('Gym'))) {
        break;
      }
      await tester.scrollUntilVisible(find.text('Gym'), 100);
    }

    await tester.pumpAndSettle();
    await tester.tap(find.text('Gym'));

    await tester.ensureVisible(find.text('PUBLISH TOPIC'));

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

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
        (doc) =>
            (doc.data()?['tags'] as List).contains('Patient') &&
            (doc.data()?['tags'] as List).length == 1,
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) =>
            (doc.data()?['categories'] as List).contains('Gym') &&
            (doc.data()?['categories'] as List).length == 1,
      ),
      isTrue,
    );

    expect(documents.length, 1);
  });

  testWidgets('Topic with title,description and multiple category save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await firestore.collection('categories').add({'name': 'Gym'});
    await firestore.collection('categories').add({'name': 'Smoking'});
    await firestore.collection('categories').add({'name': 'School'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));
    int maxScrollAttempts = 5;

    for (int i = 0; i < maxScrollAttempts; i++) {
      if (tester.any(find.text('Gym'))) {
        break;
      }
      await tester.scrollUntilVisible(
          find.text('Gym'), 100); // Scroll down by 100 pixels
    }
    await tester.tap(find.text('Gym'));

    for (int i = 0; i < maxScrollAttempts; i++) {
      if (tester.any(find.text('School'))) {
        break;
      }
      await tester.scrollUntilVisible(
          find.text('School'), 100); // Scroll down by 100 pixels
    }
    await tester.pumpAndSettle();
    await tester.tap(find.text('School'));

    for (int i = 0; i < maxScrollAttempts; i++) {
      if (tester.any(find.text('Smoking'))) {
        break;
      }
      await tester.scrollUntilVisible(
          find.text('Smoking'), 100); // Scroll down by 100 pixels
    }
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smoking'));

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

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
        (doc) =>
            (doc.data()?['tags'] as List).contains('Patient') &&
            (doc.data()?['tags'] as List).length == 1,
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) =>
            (doc.data()?['categories'] as List).contains('Gym') &&
            (doc.data()?['categories'] as List).contains('School') &&
            (doc.data()?['categories'] as List).contains('Smoking') &&
            (doc.data()?['categories'] as List).length == 3,
      ),
      isTrue,
    );

    expect(documents.length, 1);
  });

  testWidgets('Can create a new category', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    ));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Gym');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Gym'), findsOne);
  });

  testWidgets('Can create a draft', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        selectedFiles: fileListOneVideo,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

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

  testWidgets('Cannot create a blank category', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    ));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Warning!'), findsOne);
  });

  testWidgets('Cannot create a category that already exists',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await firestore.collection('categories').add({'name': 'Gym'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    ));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Gym');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Warning!'), findsOne);
  });

  testWidgets('Can delete a category', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await firestore.collection('categories').add({'name': 'Gym'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.ensureVisible(find.text('Gym'));
    expect(find.text('Gym'), findsOne);

    //steps to remove Gym
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gym').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Gym'), findsNothing);
  });

  testWidgets('Topic with no title does not save', (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

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
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });
  testWidgets('Topic no tags does not save', (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

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
  testWidgets('Topic invalid article link does not save',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.enterText(find.byKey(const Key('linkField')), 'invalidLink');

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic with valid article link saves',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.enterText(find.byKey(const Key('linkField')),
        'https://pub.dev/packages?q=cloud_firestore_mocks');

    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

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
        (doc) =>
            doc.data()?['articleLink'] ==
            'https://pub.dev/packages?q=cloud_firestore_mocks',
      ),
      isTrue,
    );
  });

  testWidgets('Test all form parts are present', (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    expect(find.text('Title *'), findsOneWidget);

    expect(find.text('Description *'), findsOneWidget);

    expect(find.text('Link article'), findsOneWidget);

    expect(find.text('Upload Media'), findsOneWidget);

    expect(find.text('Patient'), findsOneWidget);

    expect(find.text('Parent'), findsOneWidget);

    expect(find.text('Healthcare Professional'), findsOneWidget);

    expect(find.byKey(const Key('draft_btn')), findsOneWidget);
  });

  testWidgets('Navigates back after submitting form',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();
    await firestore.collection('categories').add({'name': 'Gym'});

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');
    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    int maxScrollAttempts = 5;

    for (int i = 0; i < maxScrollAttempts; i++) {
      if (tester.any(find.text('Gym'))) {
        break;
      }
      await tester.scrollUntilVisible(find.text('Gym'), 100);
    }

    await tester.pumpAndSettle();
    await tester.tap(find.text('Gym'));
    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTopicScreen), findsNothing);
  });

  testWidgets('Navigates back after submitting form',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTopicScreen), findsNothing);
  });

  testWidgets('Uploaded video is successfully stored and displays',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

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

    await tester.tap(find.text('PUBLISH TOPIC'));

    final ListResult result = await mockStorage.ref().child('media').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('Uploaded image is successfully stored and displays',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

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

    await tester.tap(find.text('PUBLISH TOPIC'));

    final ListResult result = await mockStorage.ref().child('media').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('media can be cleared and navigates to media in front correctly',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();
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
    MockFirebaseStorage mockStorage = MockFirebaseStorage();
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

  testWidgets('Uploaded video is stored in Firebase Storage',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        selectedFiles: fileListOneVideo,
        themeManager: themeManager,
      ),
    ));

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    expect(find.text('Change Media'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    // submit form

    await tester.tap(find.text('PUBLISH TOPIC'));

    final ListResult result = await mockStorage.ref().child('media').listAll();

    expect(result.items.length, greaterThan(0));
  });
  testWidgets('Test back button pops', (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.pumpAndSettle();

    // tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));

    await tester.pumpAndSettle();

    // check if the Base screen is navigated to
    expect(find.byType(CreateTopicScreen), findsNothing);
  });

  testWidgets('Orientation adjusts correctly', (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
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
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        selectedFiles: fileListOneVideo,
        themeManager: themeManager,
      ),
    ));

    await tester.ensureVisible(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uploadMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

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

  testWidgets('edited topic with valid fields updates',
      (WidgetTester tester) async {
    CollectionReference topicCollectionRef;
    QuerySnapshot data;

    topicCollectionRef = firestore.collection('topics');
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': '',
      'media': [
        {'url': 'http://via.placeholder.com/350x150', 'mediaType': 'image'}
      ],
      'tags': ['Patient'],
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now()
    });

    data = await topicCollectionRef.orderBy('title').get();
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        selectedFiles: fileListImageAndVideo,
        themeManager: themeManager,
      ),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('titleField')), 'Updated title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Updated description');

    await tester.enterText(find.byKey(const Key('linkField')),
        'https://www.health.org.uk/publications/journal-articles');

    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moreMediaButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();

    final updateButtonFinder = find.text('UPDATE TOPIC');

    await tester.ensureVisible(updateButtonFinder);

    await tester.tap(updateButtonFinder);

    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

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

  testWidgets('Test back button on edit topic navigates to View Topic screen',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();
    CollectionReference topicCollectionRef;

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    QuerySnapshot data;

    topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': '',
      'media': [],
      'tags': ['Patient'],
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now()
    });

    data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));

    await tester.pumpAndSettle();

    // tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));

    await tester.pumpAndSettle();

    // check if the Base screen is navigated to
    expect(find.byType(ViewTopicScreen), findsOneWidget);
  });

  testWidgets('next and previous buttons change current media',
      (WidgetTester tester) async {
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'user123',
      email: 'test@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final firestore = FakeFirebaseFirestore();

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

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
    MockFirebaseStorage mockStorage = MockFirebaseStorage();
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        selectedFiles: fileListImageAndVideo,
        themeManager: themeManager,
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
    MockFirebaseStorage mockStorage = MockFirebaseStorage();
    topicCollectionRef = firestore.collection('topics');
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

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
      'date': DateTime.now()
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
        selectedFiles: fileListOneVideo,
        themeManager: themeManager,
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

  testWidgets('drafted topic with valid fields and image is created',
      (WidgetTester tester) async {
    CollectionReference draftCollectionRef;
    QuerySnapshot data;

    draftCollectionRef = firestore.collection('topicDrafts');
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await draftCollectionRef.add({
      'title': 'Test Topic',
      'description': 'Test Description',
      'articleLink': '',
      'media': [
        {'url': 'http://via.placeholder.com/350x150', 'mediaType': 'image'}
      ],
      'tags': ['Patient'],
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'categories': ['Sports'],
      'date': DateTime.now()
    });

    data = await draftCollectionRef.orderBy('title').get();
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

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
        find.byKey(const Key('titleField')), 'Updated title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Updated description');

    await tester.enterText(find.byKey(const Key('linkField')),
        'https://www.health.org.uk/publications/journal-articles');

    final publishButtonFinder = find.text('PUBLISH TOPIC');

    await tester.ensureVisible(publishButtonFinder);

    await tester.tap(publishButtonFinder);

    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

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

  testWidgets('drafted topic with valid fields and video is created',
      (WidgetTester tester) async {
    CollectionReference draftCollectionRef;

    QuerySnapshot data;

    draftCollectionRef = firestore.collection('topicDrafts');

    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    await draftCollectionRef.add({
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
      'date': DateTime.now()
    });

    data = await draftCollectionRef.orderBy('title').get();
    MockFirebaseStorage mockStorage = MockFirebaseStorage();

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
        find.byKey(const Key('titleField')), 'Updated title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Updated description');

    await tester.enterText(find.byKey(const Key('linkField')),
        'https://www.health.org.uk/publications/journal-articles');

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

  testWidgets('Relevant topic questions are deleted upon creating a topic',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    ));
    await firestore.collection('questions').add({
      'question': 'Can i go to the gym with liver failure?',
      'date': DateTime.now().toString(),
      'uid': 1,
    });
    await firestore.collection('questions').add({
      'question': 'Advice on going university',
      'date': DateTime.now().toString(),
      'uid': 1,
    });
    await firestore.collection('questions').add({
      'question': 'Advice on going gym',
      'date': DateTime.now().toString(),
      'uid': 1,
    });
    await firestore.collection('questions').add({
      'question': 'Tips on going gym',
      'date': DateTime.now().toString(),
      'uid': 1,
    });
    await tester.enterText(
        find.byKey(const Key('titleField')), 'Tips on going to the gym');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOne);
    expect(find.text('Delete all'), findsOne);
    expect(find.byType(QuestionCard),
        findsExactly(3)); //finds all gym related questions

    await tester.tap(find.byIcon(Icons.check_circle).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.byType(QuestionCard),
        findsExactly(2)); //verify that card is deleted
    final snapshot = await firestore.collection('questions').get();
    expect(snapshot.docs.length, 3);

    await tester.tap(find.text('Delete all'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOne);

    await tester.tap(find.text('Delete all'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('There are currently no more questions!'), findsOne);
    await tester.tap(find.text('Done'));
    final newSnapshot = await firestore.collection('questions').get();
    expect(newSnapshot.docs.length, 1);
    final questionDoc = newSnapshot.docs.first.data();
    expect(questionDoc['question'], 'Advice on going university');
  });
}
