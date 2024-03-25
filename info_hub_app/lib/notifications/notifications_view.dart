import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/notifications/notification_model.dart' as custom;
import 'package:info_hub_app/notifications/notification_card.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Notifications extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  Notifications({super.key, required this.auth, required this.firestore});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late SlidableController slidableController; // Declare SlidableController

  @override
  Widget build(BuildContext context) {
    slidableController = SlidableController();
    final List<custom.Notification> allNotifications =
        Provider.of<List<custom.Notification>>(context);

    final List<custom.Notification> userNotifications = allNotifications
        .where(
            (notification) => notification.uid == widget.auth.currentUser!.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: userNotifications.length,
        itemBuilder: (context, index) {
          final notification = userNotifications[index];
          return Column(
            children: [
              Slidable(
                key: Key(notification.id), // Use a unique key for each Slidable
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                controller: slidableController, // Assign the SlidableController
                secondaryActions: [
                  IconSlideAction(
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      DatabaseService(
                        uid: widget.auth.currentUser!.uid,
                        auth: widget.auth,
                        firestore: widget.firestore,
                      ).deleteNotification(notification.id);
                    },
                  ),
                ],
                child: NotificationCard(notification: notification),
              ),
              if (index != userNotifications.length - 1)
                const Divider(
                  color: Colors.grey,
                  thickness: 3.0,
                  height: 0.0,
                ),
            ],
          );
        },
      ),
    );
  }
}
