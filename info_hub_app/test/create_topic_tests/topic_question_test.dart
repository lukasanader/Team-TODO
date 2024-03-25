import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/ask_question/question_card.dart';

void main() async {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage mockStorage;
  Widget? basicWidget;

  setUp(() {
    firestore = FakeFirebaseFirestore();
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

    basicWidget = MaterialApp(
      home: TopicCreationView(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    );
  }

  testWidgets('Relevant topic questions are deleted upon creating a topic',
      (WidgetTester tester) async {
    await defineUserAndStorage(tester);

    await tester.pumpWidget(basicWidget!);
    await firestore.collection('questions').add({
      'question': 'Can i go to the gym with liver failure?',
      'date': DateTime.now().toString(),
      'uid': '1',
    });
    await firestore.collection('questions').add({
      'question': 'Advice on going university',
      'date': DateTime.now().toString(),
      'uid': '1',
    });
    await firestore.collection('questions').add({
      'question': 'Advice on going gym',
      'date': DateTime.now().toString(),
      'uid': '1',
    });
    await firestore.collection('questions').add({
      'question': 'Tips on going gym',
      'date': DateTime.now().toString(),
      'uid': '1',
    });
    await tester.enterText(
        find.byKey(const Key('titleField')), 'Tips on going to the gym');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.ensureVisible(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));
    await tester.ensureVisible(find.text('PUBLISH TOPIC'));
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
