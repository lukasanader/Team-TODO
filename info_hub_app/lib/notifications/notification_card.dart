import 'package:flutter/material.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final custom.Notification notification;

  NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(notification.timestamp);

    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 5.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(notification.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body),
              Text(
                timeAgo,
                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
