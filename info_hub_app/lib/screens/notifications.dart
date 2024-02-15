import 'package:flutter/material.dart';
import 'package:info_hub_app/models/notification.dart' as custom;
import 'package:info_hub_app/helpers/notification_tile.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/services/database.dart';

class Notifications extends StatefulWidget {
  final String currentUser;

  const Notifications(
      {Key? key, required this.currentUser, FirebaseFirestore? firestore})
      : super(key: key);

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
          return NotificationTile(
            notification: userNotifications[index],
            onDelete: (id) {
              DatabaseService(uid: widget.currentUser).deleteNotification(id);
            },
          );
        },
      ),
    );
  }
}
