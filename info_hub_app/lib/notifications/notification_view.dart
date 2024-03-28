import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/notifications/notification_model.dart' as custom;
import 'package:info_hub_app/notifications/notification_controller.dart';
import 'package:info_hub_app/notifications/notification_card_view.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  const Notifications({super.key, required this.auth, required this.firestore});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late SlidableController slidableController;
  late List<bool> isDeletedList;

  @override
  void initState() {
    super.initState();
    slidableController = SlidableController();
  }

  @override
  Widget build(BuildContext context) {
    slidableController = SlidableController();
    final List<custom.Notification> allNotifications =
        Provider.of<List<custom.Notification>>(context);

    final List<custom.Notification> userNotifications = allNotifications
        .where(
            (notification) => notification.uid == widget.auth.currentUser!.uid)
        .toList();

    isDeletedList = userNotifications.map((e) => e.deleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              setState(() {
                // Mark all notifications as deleted
                for (int i = 0; i < userNotifications.length; i++) {
                  isDeletedList[i] = true;
                  userNotifications[i].deleted = true;
                }
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: userNotifications.length,
        itemBuilder: (context, index) {
          final notification = userNotifications[index];
          // Fade out animation for deleted notifications
          return AnimatedOpacity(
            onEnd: () {
              // Delete notification from database if it is marked as deleted
              if (isDeletedList[index]) {
                NotificationController(
                        uid: widget.auth.currentUser!.uid,
                        auth: widget.auth,
                        firestore: widget.firestore)
                    .deleteNotification(notification.id);
              }
            },
            opacity: isDeletedList[index] ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Column(
              children: [
                Slidable(
                  key: Key(notification.id),
                  actionPane: const SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  controller: slidableController,
                  secondaryActions: [
                    IconSlideAction(
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        setState(() {
                          // Mark notification as deleted
                          isDeletedList[index] = true;
                          userNotifications[index].deleted = true;
                        });
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
            ),
          );
        },
      ),
    );
  }
}
