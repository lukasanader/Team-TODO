import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsTopic extends StatefulWidget {
  final QueryDocumentSnapshot topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AdminAnalyticsTopic({
    Key? key,
    required this.firestore,
    required this.storage,
    required this.topic,
  }) : super(key: key);

  @override
  State<AdminAnalyticsTopic> createState() => AdminAnalyticsTopicState();
}

class AdminAnalyticsTopicState extends State<AdminAnalyticsTopic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic['title']),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Likes", "${widget.topic['likes']}"),
          _buildInfoRow("Dislikes", "${widget.topic['dislikes']}"),
          _buildInfoRow("Views", "${widget.topic['views']}"),
          _buildInfoRow("Date", "${formatDate(widget.topic['date'])}"),
          _buildInfoRow("Time", "${formatTime(widget.topic['date'])}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(Timestamp timestamp) {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String formatTime(Timestamp timestamp) {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('HH:mm:ss').format(dateTime);
  }
}
