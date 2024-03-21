import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String id;
  final String aid;
  final String type;
  final String uid;
  final Timestamp date;

  Activity(
      {
        required this.id,
        required this.aid,
        required this.type,
        required this.uid,
        required this.date
      });

  factory Activity.fromSnapshot(DocumentSnapshot snapshot) {
    return Activity(
      id: snapshot.id,
      aid: snapshot['aid'],
      type: snapshot['type'],
      uid: snapshot['uid'],
      date: snapshot['date'],
    );
  }
}


class TopicQuestion {
  final String id;
  final String uid;
  final String question;
  final String date;

    TopicQuestion(
      {
        required this.id,
        required this.uid,
        required this.question,
        required this.date,
      });

  factory TopicQuestion.fromSnapshot(DocumentSnapshot snapshot) {
    return TopicQuestion(
      id: snapshot.id,
      uid: snapshot['uid'],
      question: snapshot['question'],
      date: snapshot['date']
    );
  }
}
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
