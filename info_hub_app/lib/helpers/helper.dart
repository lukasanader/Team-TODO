/*
 * This file contains all helper function.
 */

import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

// This function calculates the trending score of a topic.
double getTrending(Topic topic) {
  DateTime date = topic.date!;
  int difference = DateTime.now().difference(date).inDays;
  if (difference == 0) {
    difference = 1;
  }
  return topic.views! / difference;
}
