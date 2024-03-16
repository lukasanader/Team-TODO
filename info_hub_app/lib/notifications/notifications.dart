import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:info_hub_app/notifications/notification_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/services/database.dart';

class Notifications extends StatefulWidget {
  FirebaseAuth auth;
  FirebaseFirestore firestore;
  Notifications({super.key, required this.auth, required this.firestore});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    final List<custom.Notification> allNotifications =
        Provider.of<List<custom.Notification>>(context);

    final List<custom.Notification> userNotifications = allNotifications
        .where(
            (notification) => notification.uid == widget.auth.currentUser!.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[400],
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: userNotifications.length,
        itemBuilder: (context, index) {
          final notification = userNotifications[index];
          return Dismissible(
            key: Key(notification.id),
            child: NotificationCard(notification: notification),
            onDismissed: (direction) {
              DatabaseService(
                      uid: widget.auth.currentUser!.uid,
                      firestore: widget.firestore)
                  .deleteNotification(notification.id);
            },
          );
        },
      ),
    );
  }
}
