import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/ask_question/question_card.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/helpers/mock_classes.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  mockFilePicker() {
    const MethodChannel channelFilePicker =
        MethodChannel('miguelruivo.flutter.plugins.filepicker');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelFilePicker,
            (MethodCall methodCall) async {
      final ByteData data = await rootBundle.load('/assets/sample-5s.mp4');
      final Uint8List bytes = data.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/sample-5s.mp4',
      ).writeAsBytes(bytes);
      return [
        {
          'name': "sample-5s.mp4",
          'path': file.path,
          'bytes': bytes,
          'size': bytes.lengthInBytes,
        }
      ];
    });
  }

  setUp(() {
    mockFilePicker();

    final fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();

    VideoPlayerPlatform.instance = fakeVideoPlayerPlatform;
  });
  testWidgets('Topic with title,description and tag save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));    
    
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
        (doc) => (doc.data()?['tags'] as List).contains('Patient') && (doc.data()?['tags'] as List).length==1,
      ),
      isTrue,
    );

    expect(documents.length, 1);
  });

  testWidgets('Topic with title,description and one category save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await firestore
      .collection('categories')
      .add({
        'name' : 'Gym'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.ensureVisible(find.text('Gym'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gym'));    
    
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
        (doc) => (doc.data()?['tags'] as List).contains('Patient') && (doc.data()?['tags'] as List).length==1,
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => (doc.data()?['categories'] as List).contains('Gym') && (doc.data()?['categories'] as List).length==1,
      ),
      isTrue,
    );


    expect(documents.length, 1);
  });

  testWidgets('Topic with title,description and multiple category save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await firestore
      .collection('categories')
      .add({
        'name' : 'Gym'});
    await firestore
      .collection('categories')
      .add({
        'name' : 'Smoking'});
    await firestore
      .collection('categories')
      .add({
        'name' : 'School'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.ensureVisible(find.text('Gym'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gym'));    

    await tester.ensureVisible(find.text('School'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('School'));    

    await tester.ensureVisible(find.text('Smoking'));
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
        (doc) => (doc.data()?['tags'] as List).contains('Patient') && (doc.data()?['tags'] as List).length==1,
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => (doc.data()?['categories'] as List).contains('Gym') 
        && (doc.data()?['categories'] as List).contains('School')
        && (doc.data()?['categories'] as List).contains('Smoking')
        && (doc.data()?['categories'] as List).length==3,
      ),
      isTrue,
    );


    expect(documents.length, 1);
  });

  testWidgets('Can create a new category',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();


    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Gym');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Gym'), findsOne);
  });

  testWidgets('Cannot create a blank category',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();


    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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

  await firestore
    .collection('categories')
    .add({
      'name' : 'Gym'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Gym');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Warning!'), findsOne);
  });

  testWidgets('Can delete a category',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await firestore
      .collection('categories')
      .add({
        'name' : 'Gym'});

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

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

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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
  testWidgets('Topic no tags does not save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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

  testWidgets('Test all form fields are present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    expect(find.text('Title *'), findsOneWidget);

    expect(find.text('Description *'), findsOneWidget);

    expect(find.text('Link article'), findsOneWidget);

    expect(find.text('Upload a video'), findsOneWidget);
    
    expect(find.text('Patient'), findsOneWidget);

    expect(find.text('Parent'), findsOneWidget);

    expect(find.text('Healthcare Professional'), findsOneWidget);
  });

  testWidgets('Navigates back after submitting form',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');
    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));
    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTopicScreen), findsNothing);
  });

  testWidgets('Navigates back after submitting form',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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
    final firestore = FakeFirebaseFirestore();

    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));
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

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    // submit form

    await tester.tap(find.text('PUBLISH TOPIC'));

    final ListResult result = await mockStorage.ref().child('videos').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('Uploaded video can be cleared', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));
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

  testWidgets('Uploaded video is stored in Firebase Storage',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

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

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));    

    // submit form

    await tester.tap(find.text('PUBLISH TOPIC'));

    final ListResult result = await mockStorage.ref().child('videos').listAll();

    expect(result.items.length, greaterThan(0));
  });

  testWidgets('Orientation adjusts correctly', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();
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
        firestore: firestore,
        storage: mockStorage,
      ),
    ));

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

  testWidgets('Relevant topic questions are deleted upon creating a topic', (WidgetTester tester) async{
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
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
    await tester.enterText(find.byKey(const Key('titleField')), 'Tips on going to the gym');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOne);
    expect(find.text('Delete all'), findsOne);
    expect(find.byType(QuestionCard), findsExactly(3)); //finds all gym related questions
    

    await tester.tap(find.byIcon(Icons.check_circle).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.byType(QuestionCard), findsExactly(2)); //verify that card is deleted
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
