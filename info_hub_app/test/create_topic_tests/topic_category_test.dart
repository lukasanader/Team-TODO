import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/model/topic_models/topic_model.dart';
import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

/// This test file is responsible for testing the create topic form submission
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
      home: TopicCreationView(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    );
  }

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

  testWidgets('Deleting category removes category from existing topics',
      (WidgetTester tester) async {
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
            'mediaType': 'video',
            'thumbnail':
                'https://images.unsplash.com/photo-1606921231106-f1083329a65c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZXhhbXBsZXxlbnwwfHwwfHx8MA%3D%3D'
          },
        ],
        likes: 0,
        tags: ['Patient'],
        views: 0,
        dislikes: 0,
        categories: ['Testing category'],
        date: DateTime.now(),
        quizID: '');

    DocumentReference topicRef =
        await firestore.collection('topics').add(topic.toJson());

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
    DocumentSnapshot topicSnapshot =
        await firestore.collection('topics').doc(topic.id).get();
    expect(topicSnapshot['categories'], isEmpty);
  });
}
