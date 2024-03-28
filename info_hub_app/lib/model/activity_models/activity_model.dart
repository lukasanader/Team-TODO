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
