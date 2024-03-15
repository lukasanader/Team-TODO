import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:info_hub_app/topics/quiz/complete_quiz.dart';
import 'package:info_hub_app/topics/quiz/create_quiz.dart';
import 'package:info_hub_app/topics/quiz/quiz_answer_card.dart';
import 'package:info_hub_app/topics/view_topic.dart';

void main() {
  late FirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockFirebaseStorage mockStorage = MockFirebaseStorage();
  late Widget quizWidget;

  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    auth.createUserWithEmailAndPassword(
        email: 'test@email.com', password: 'Password123!');
    await firestore.collection('topics').add({
      'title': 'Test Topic',
      'description': 'This is a test',
      'articleLink': '',
      'media': [],
      'views': 0,
      'likes': 0,
      'dislikes': 0,
      'date': DateTime.now(),
      'quizID': '1'
    });
    final topicsSnapshot = await firestore.collection('topics').get();
    final topic = topicsSnapshot.docs.first;
    //Add the questions
    await firestore.collection('quizQuestions').add({
      'question': 'What is a liver?',
      'correctAnswers': ['An organ'],
      'wrongAnswers': ['A dog', 'A cat', 'A person'],
      'quizID': '1',
    });
    await firestore.collection('quizQuestions').add({
      'question': 'What is a hospital?',
      'correctAnswers': ['A building'],
      'wrongAnswers': ['A car', 'A taxi', 'A bus'],
      'quizID': '1',
    });
    quizWidget = MaterialApp(
      home: ViewTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        topic: topic,
        auth: auth,
      ),
    );
  });

  testWidgets('Test Complete Quiz Screen', (WidgetTester tester) async {
    await tester.pumpWidget(quizWidget);
    await tester.pumpAndSettle();

    expect(find.text('QUIZ!!'), findsOneWidget);
    await tester.tap(find.text('QUIZ!!'));
    await tester.pumpAndSettle();

    expect(find.byType(CompleteQuiz), findsOne);

    //Ensure all questions and answers are there

    expect(find.text('1. What is a liver?'), findsOne);
    expect(find.text('2. What is a hospital?'), findsOne);

    //Finds 8 possible answers 4 for each question
    expect(find.byType(AnswerCard), findsExactly(8));

    //answer correctly
    await tester.tap(find.textContaining('An organ'));
    //answer incorrectly
    await tester.ensureVisible(find.textContaining('A car'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('A car'));

    expect(find.text('Done'), findsOne);
    await tester.ensureVisible(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    //finds a tick for the correct question
    expect(find.byIcon(Icons.check_circle), findsOne);
    //A cross for the wrong question
    expect(find.byIcon(Icons.cancel), findsOne);
    //Tells the correct answer
    expect(find.text('Correct answer(s) was: A building'), findsOne);
    //check if correct score is outputted
    expect(find.text("Your score is 1 out of 2"), findsOne);

    final querySnapshot = await firestore.collection('Quiz').get();

    // Check if the retrieved document has the expected values
    expect(querySnapshot.docs.length, 1); // Expecting one document
    final quizDoc = querySnapshot.docs.first.data(); // Check topicID
    expect(quizDoc['uid'], auth.currentUser?.uid); // Check uID
    expect(quizDoc['score'], "1/2");
  });
}
