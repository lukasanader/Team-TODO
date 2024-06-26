import 'package:flutter/material.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/model/notification_models/notification_model.dart' as custom;
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final custom.Notification notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(notification.timestamp);
    return GestureDetector(
      onTap: () {
        showNotificationDetails(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Card(
          margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            title: Text(notification.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeAgo,
                  style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Handles the display of notification details when a notification is clicked
  void showNotificationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(notification.body),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the content the notification is referring to
                    navigatorKey.currentState!
                      ..popUntil((route) => false)
                      ..pushNamed('/base')
                      ..pushNamed(notification.route,
                          arguments: notification.payload);
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
