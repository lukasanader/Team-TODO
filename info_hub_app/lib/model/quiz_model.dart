

import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String score;
  final String topicID;
  final String uid;
  List<QuizQuestion> ?questions;

    Quiz(
      {
        required this.id,
        required this.score,
        required this.topicID,
        required this.uid,
        this.questions,
      });
}

class QuizQuestion{
  final String id;
  final List<dynamic> correctAnswers;
  final String question;
  final List<dynamic> wrongAnswers;

    QuizQuestion(
      {
        required this.id,
        required this.correctAnswers,
        required this.question,
        required this.wrongAnswers,
      });

  factory QuizQuestion.fromSnapshot(DocumentSnapshot snapshot) {
    return QuizQuestion(
      id: snapshot.id,
      correctAnswers: snapshot['correctAnswers'],
      question: snapshot['question'],
      wrongAnswers: snapshot['wrongAnswers']
    );
  }
}
