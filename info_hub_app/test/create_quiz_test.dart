import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:info_hub_app/topics/quiz/create_quiz.dart';

void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseStorage mockStorage = MockFirebaseStorage();
  late Widget quizWidget;

  setUp(() {
    quizWidget = MaterialApp(
      home: CreateTopicScreen(firestore: firestore, storage: mockStorage),
    );
  });

  testWidgets('Test Create Quiz Screen', (WidgetTester tester) async {
    await tester.pumpWidget(quizWidget);
    await tester.pumpAndSettle();

    expect(find.text('ADD QUIZ'), findsOneWidget);
    await tester.tap(find.text('ADD QUIZ'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateQuiz), findsOne);

    final addQuestionButton = find.text('Add Question');
    expect(addQuestionButton, findsOneWidget);

    await tester.tap(addQuestionButton); //Add an invalid question
    await tester.pumpAndSettle();
    expect(find.text('Please enter a question'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'What is a liver?');
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle();

    expect(find.text('1. What is a liver?'), findsOneWidget);

    final addAnswerButton = find.byIcon(Icons.add);
    expect(addAnswerButton, findsOne);

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
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid question'), findsOneWidget);
    //prompts user to add valid question
    await tester.enterText(find.byKey(const Key('answerField')), 'A person');
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('1. An organ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1. An organ')); //select correct answer
    await tester.pumpAndSettle();
    await tester.ensureVisible(saveQuestionButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuestionButton);
    await tester.pumpAndSettle();

    expect(find.text('Question has been saved!'),
        findsOne); //check to see if question has been saved correctly

    final saveQuizButton = find.text('Save Quiz');
    expect(saveQuizButton, findsOne);
    await tester.ensureVisible(saveQuizButton);
    await tester.pumpAndSettle();
    await tester.tap(saveQuizButton); //Save question without an answer
    await tester.pumpAndSettle();
    expect(find.byType(CreateTopicScreen), findsOne);
  });

  testWidgets('Test quiz questions saved correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(quizWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('ADD QUIZ'));
    await tester.pumpAndSettle();
    final addQuestionButton = find.text('Add Question');
    await tester.tap(addQuestionButton); //Add an invalid question
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'What is a liver?');
    await tester.tap(addQuestionButton);
    await tester.pumpAndSettle();

    final addAnswerButton = find.byIcon(Icons.add);
    await tester.enterText(find.byKey(const Key('answerField')), 'An organ');
    await tester.tap(addAnswerButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('answerField')), 'A person');
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
    await tester.pumpAndSettle();

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
}
