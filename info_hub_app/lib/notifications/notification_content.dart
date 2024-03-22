import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/notifications/notification_model.dart' as custom;
import 'package:info_hub_app/notifications/notification_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/services/database.dart';

class NotificationContent extends StatefulWidget {
  FirebaseAuth auth;
  FirebaseFirestore firestore;
  NotificationContent({super.key, required this.auth, required this.firestore});

  @override
  State<NotificationContent> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationContent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
