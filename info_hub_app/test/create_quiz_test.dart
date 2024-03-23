import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/topics/create_topic/create_topic.dart';
import 'package:info_hub_app/topics/quiz/create_quiz.dart';
import 'package:info_hub_app/topics/quiz/quiz_question_card.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

Future<void> main() async {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseStorage mockStorage = MockFirebaseStorage();
  late MockFirebaseAuth auth = MockFirebaseAuth();
  late Widget quizWidget;
  late ThemeManager themeManager = ThemeManager();

  setUp(() {
    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    auth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    quizWidget = MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
        storage: mockStorage,
        auth: auth,
        themeManager: themeManager,
      ),
    );
  });

  testWidgets('Test Create Quiz Screen', (WidgetTester tester) async {
    await tester.pumpWidget(quizWidget);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ADD QUIZ'));
    expect(find.text('ADD QUIZ'), findsOneWidget);
    await tester.tap(find.text('ADD QUIZ'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateQuiz), findsOne);

    final saveQuizButton = find.text('Save Quiz');
    expect(saveQuizButton, findsOne);
    await tester.ensureVisible(saveQuizButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuizButton);
    await tester.pumpAndSettle();
    expect(find.text('Please add at least one question to save the quiz'),
        findsOne);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final addQuestionButton = find.text('Add Question');

    expect(addQuestionButton, findsOneWidget);
    await tester.ensureVisible(addQuestionButton);
    await tester.pumpAndSettle();

    await tester.tap(addQuestionButton); //Add an invalid question
    await tester.pumpAndSettle();
    expect(find.text('Please enter a question'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'What is a liver?');
    await tester.pumpAndSettle(const Duration(seconds: 4));
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('1. What is a liver?'), findsOneWidget);
    //Test delete question buttton
    final deleteQuestionButton = find.text('Delete');

    expect(deleteQuestionButton, findsOneWidget);
    await tester.ensureVisible(deleteQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(deleteQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.byType(QuizQuestionCard), findsNothing);

    await tester.enterText(find.byType(TextField), 'What is a liver?');
    await tester.pumpAndSettle(const Duration(seconds: 4));
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final addAnswerButton = find.byIcon(Icons.add);
    expect(addAnswerButton, findsOne);
    await tester.ensureVisible(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.tap(addAnswerButton); //Enter an invalid answer
    await tester.pumpAndSettle();
    
    expect(find.text('Enter a valid answer'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('answerField')), 'An organ');
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();
    expect(find.text('1. An organ'), findsOne); //answer card has been added

    final saveQuestionButton = find.text('Save');
    expect(saveQuestionButton, findsOne);
    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton); //Save question without an answer
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Select at least one correct answer'), findsOneWidget);
    //prompts user to add valid question
    await tester.enterText(find.byKey(const Key('answerField')), 'A person');
    await tester.ensureVisible(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1. An organ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1. An organ')); //select correct answer
    await tester.pumpAndSettle();
    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Question has been saved!'),
        findsOne); //check to see if question has been saved correctly

    await tester.ensureVisible(saveQuizButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOne);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateQuiz), findsOne);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOne);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateTopicScreen), findsOne);
  });

  testWidgets('Test quiz questions saved correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(quizWidget);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ADD QUIZ'));
    await tester.tap(find.text('ADD QUIZ'));
    await tester.pumpAndSettle();

    final addQuestionButton = find.text('Add Question');
    await tester.ensureVisible(addQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.enterText(find.byType(TextField), 'What is a liver?');
    await tester.ensureVisible(addQuestionButton);
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle();

    final addAnswerButton = find.byIcon(Icons.add);
    await tester.enterText(find.byKey(const Key('answerField')), 'An organ');
    await tester.ensureVisible(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('answerField')), 'A person');
    await tester.ensureVisible(addQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();

    final saveQuestionButton = find.text('Save');
    await tester.ensureVisible(find.text('1. An organ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1. An organ')); //select correct answer
    await tester.pumpAndSettle();
    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final saveQuizButton = find.text('Save Quiz');
    await tester.ensureVisible(saveQuizButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuizButton);
    await tester.pumpAndSettle();
    expect(find.byType(CreateTopicScreen), findsOne);
    bool correctAnswers = false;
    bool wrongAnswers = false;
    final querySnapshot = await firestore.collection('quizQuestions').get();
    querySnapshot.docs.forEach((doc) {
      // Check if the correctAnswers field exists and contains "organ"
      if (doc.data().containsKey('correctAnswers') &&
          (doc.data()['correctAnswers'] as List).contains('An organ') &&
          (doc.data()['correctAnswers'] as List).length == 1) {
        correctAnswers = true;
      }
      if (doc.data().containsKey('wrongAnswers') &&
          (doc.data()['wrongAnswers'] as List).contains('A person') &&
          (doc.data()['wrongAnswers'] as List).length == 1) {
        wrongAnswers = true;
      }
    });
    expect(correctAnswers, true); //contains the right correct answers
    expect(wrongAnswers, true); //contains the right wrong answers
  });

  testWidgets('Test edit quiz questions', (WidgetTester tester) async {
    CollectionReference topicCollectionRef;
    QuerySnapshot data;

    topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 1',
      'description': 'Test Description',
      'articleLink': '',
      'media': [],
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'date': DateTime.now(),
      'categories': [],
      'quizID': '1'
    });
    CollectionReference quizQuestionRef = firestore.collection('quizQuestions');
    quizQuestionRef.add({
      'question': 'What is a liver?',
      'correctAnswers': ['An organ'],
      'wrongAnswers': ['A person', 'A cat'],
      'quizID': '1'
    });
    data = await topicCollectionRef.get();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
        auth: auth,
        firestore: firestore,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('ADD QUIZ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD QUIZ'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    //print(find.byType(Text));
    expect(find.byType(QuizQuestionCard), findsOne);

    await tester.tap(find.textContaining('An organ'));
    await tester.pumpAndSettle();

    final saveQuestionButton = find.text('Save');
    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final addQuestionButton = find.text('Add Question');
    await tester.ensureVisible(addQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.enterText(find.byType(TextField), 'What is a doctor?');
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle();

    final deleteQuestionButton = find.text('Delete');

    await tester.ensureVisible(deleteQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(deleteQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.byType(QuizQuestionCard), findsOne);

    await tester.ensureVisible(addQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.enterText(find.byType(TextField), 'What is a doctor?');
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle();

    final addAnswerButton = find.byIcon(Icons.add);
    await tester.enterText(find.byKey(const Key('answerField')), 'A Person');
    await tester.ensureVisible(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('answerField')), 'A dog');
    await tester.ensureVisible(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('1. A Person'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1. A Person'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final saveQuizButton = find.text('Save Quiz');
    await tester.ensureVisible(saveQuizButton);
    await tester.pumpAndSettle(const Duration(seconds: 4));
    await tester.tap(saveQuizButton);
    await tester.pumpAndSettle();

    final querySnapshot = await firestore.collection('quizQuestions').get();
    querySnapshot.docs.forEach((doc) {
      // Check if the correctAnswers field exists and contains "organ"
      if (doc.data().containsKey('question') &&
          doc.data()['question'] == 'What is a doctor?') {
        expect(doc['correctAnswers'] as List,
            ['A Person']); //contains the right correct answers
        expect(doc['wrongAnswers'] as List, ['A dog']);
        expect(doc['quizID'], '1');
      }
    });
  });
}
