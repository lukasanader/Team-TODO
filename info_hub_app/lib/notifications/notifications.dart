import 'package:flutter/material.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:info_hub_app/notifications/notification_tile.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/services/database.dart';

class Notifications extends StatefulWidget {
  final String currentUser;
  FirebaseFirestore firestore;
  Notifications(
      {super.key, required this.currentUser,required this.firestore});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    final List<custom.Notification> allNotifications =
        Provider.of<List<custom.Notification>>(context);

    final List<custom.Notification> userNotifications = allNotifications
        .where((notification) => notification.user == widget.currentUser)
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
            child: NotificationTile(notification: notification),
            onDismissed: (direction) {
              DatabaseService(uid: widget.currentUser, firestore: widget.firestore)
                  .deleteNotification(notification.id);
            },
          );
        },
      ),
    );
  }
}