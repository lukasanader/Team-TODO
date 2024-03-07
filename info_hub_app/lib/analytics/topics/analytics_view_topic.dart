/*
 * This file contains the code for the admin analytics view topic page.
 * This page displays the analytics of a topic, such as likes, dislikes, views, and upload date.
 */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class AdminTopicAnalytics extends StatefulWidget {
  final QueryDocumentSnapshot topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AdminTopicAnalytics({
    super.key,
    required this.firestore,
    required this.storage,
    required this.topic,
  });

  @override
  State<AdminTopicAnalytics> createState() => AdminAnalyticsTopicState();
}

class AdminAnalyticsTopicState extends State<AdminTopicAnalytics> {
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
          _buildInfoRow("Uploaded Date", _formatDate(widget.topic['date'])),
          _buildInfoRow("Uploaded Time", _formatTime(widget.topic['date'])),
        ],
      ),
    );
  }

  // Builds a row with key/title and value
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  String _formatTime(Timestamp timestamp) {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('HH:mm').format(dateTime);
  }
}
