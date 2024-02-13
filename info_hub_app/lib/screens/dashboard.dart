import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/screens/notifications.dart';
import 'package:info_hub_app/services/database.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await DatabaseService(uid: user!.uid).createNotification(
                    'Test Notification',
                    'This is a test notification',
                    DateTime.now());
              },
              child: const Text('Create Test Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Notifications(
                      currentUser: user!.uid,
                    ),
                  ),
                );
              },
              child: const Text('Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
