import 'package:flutter/material.dart';
import 'package:info_hub_app/models/notification.dart' as custom;
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends StatelessWidget {
  final custom.Notification notification;

  NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(notification.timestamp);

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(notification.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
