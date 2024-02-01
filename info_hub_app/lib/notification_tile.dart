import 'package:flutter/material.dart';
import 'package:info_hub_app/models/notification.dart' as custom;

class NotificationTile extends StatelessWidget {
  final custom.Notification notification;

  NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.message),
            trailing: Text(
              '${notification.timestamp.hour}:${notification.timestamp.minute}',
            ),
          ),
        ));
  }
}
