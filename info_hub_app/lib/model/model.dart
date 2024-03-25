import 'package:cloud_firestore/cloud_firestore.dart';

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
