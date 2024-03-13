/*
 * This file contains all helper function.
 */

import 'package:cloud_firestore/cloud_firestore.dart';

// This function calculates the trending score of a topic.
double getTrending(QueryDocumentSnapshot topic) {
  Timestamp timestamp = topic['date'];
  DateTime date = timestamp.toDate();
  int difference = DateTime.now().difference(date).inDays;
  if (difference == 0) {
    difference = 1;
  }
  return topic['views'] / difference;
}
