import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String aid;
  final String type;
  final String uid;

  Activity(
      {
        required this.id,
        required this.aid,
        required this.type,
        required this.uid,
      });

  factory Activity.fromSnapshot(DocumentSnapshot snapshot) {
    return Activity(
      id: snapshot.id,
      aid: snapshot['aid'],
      type: snapshot['type'],
      uid: snapshot['uid']
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
