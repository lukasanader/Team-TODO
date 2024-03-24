import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  Widget? basicWidget;
  setUp(() {
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
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    );
  }

  testWidgets('Topic with title,description, category and tag save',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await firestore.collection('categories').add({'name': 'Gym'});

    await tester.pumpWidget(basicWidget!);

    await fillRequiredFields(tester);
    expect(tester.testTextInput.isVisible, true);
    final outsideGestureDetectorFinder = find.descendant(
      of: find.byType(
          CreateTopicScreen), // Change this to the appropriate type of your widget
      matching: find.byType(GestureDetector),
    );
    await tester.tap(outsideGestureDetectorFinder.first);
    await tester.pump();
    expect(tester.testTextInput.isVisible, false);
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
    await defineUserAndStorage(tester);

    await firestore.collection('categories').add({'name': 'Gym'});
    await firestore.collection('categories').add({'name': 'Smoking'});
    await firestore.collection('categories').add({'name': 'School'});

    await tester.pumpWidget(basicWidget!);

    await fillRequiredFields(tester);
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
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
    await tester.tap(find.text('PUBLISH TOPIC'));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;
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
    await defineUserAndStorage(tester);

    await tester.pumpWidget(basicWidget!);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Gym');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Gym'), findsOne);
  });

  testWidgets('Cannot create a blank category', (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await tester.pumpWidget(basicWidget!);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Warning!'), findsOne);
  });

  testWidgets('Cannot create a category that already exists',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await firestore.collection('categories').add({'name': 'Gym'});

    await tester.pumpWidget(basicWidget!);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Gym');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Warning!'), findsOne);
  });

  testWidgets('Can delete a category', (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await firestore.collection('categories').add({'name': 'Gym'});

    await tester.pumpWidget(basicWidget!);
    await fillRequiredFields(tester);

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

  testWidgets('Deleting category removes category from existing topics', (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await firestore.collection('categories').add({'name': 'Testing category'});

    Topic topic = Topic(
        title: 'Test Topic',
        description: 'Test Description',
        articleLink: '',
        media: [
          {
            'url':
                'https://firebasestorage.googleapis.com/v0/b/team-todo-38f76.appspot.com/o/videos%2F2024-02-27%2022%3A09%3A02.035911.mp4?alt=media&token=ea6b51e9-9e9f-4d2e-a014-64fc3631e321',
            'mediaType': 'video'
          },
        ],
        likes: 0,
        tags: ['Patient'],
        views: 0,
        dislikes: 0,
        categories: ['Testing category'],
        date: DateTime.now(),
        quizID: '');

    DocumentReference topicRef = await firestore
      .collection('topics')
      .add(topic.toJson());

    topic.id = topicRef.id;



    await tester.pumpWidget(basicWidget!);
    await fillRequiredFields(tester);

    await tester.ensureVisible(find.text('Testing category'));
    expect(find.text('Testing category'), findsOne);

    //steps to remove Testing category
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Testing category').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Testing category'), findsNothing);

    //verifies that the topic no longer contains the category Testing category
    DocumentSnapshot topicSnapshot = await firestore.collection('topics').doc(topic.id).get();
    expect(topicSnapshot['categories'], isEmpty);



  });


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

  testWidgets('Topic with valid article link saves',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);
    await fillRequiredFields(tester);
    await tester.enterText(find.byKey(const Key('linkField')),
        'https://pub.dev/packages?q=cloud_firestore_mocks');
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
    await tester.tap(find.text('PUBLISH TOPIC'));
    await tester.pumpAndSettle();
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;
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
    await defineUserAndStorage(tester);
    await tester.pumpWidget(basicWidget!);
    expect(find.text('Title *'), findsOneWidget);
    expect(find.text('Description *'), findsOneWidget);
    expect(find.text('Link article'), findsOneWidget);
    expect(find.text('Upload Media'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Parent'), findsOneWidget);
    expect(find.text('Healthcare Professional'), findsOneWidget);
    expect(find.byKey(const Key('draft_btn')), findsOneWidget);
  });
}
