//coverage:ignore-file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/notifications/notification_service.dart';

class TestView extends StatefulWidget {
  TestView(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});

  FirebaseFirestore firestore;
  FirebaseAuth auth;
  FirebaseStorage storage;

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (BuildContext context) =>
                  ThreadApp(firestore: widget.firestore, auth: widget.auth)));
        },
        child: const Icon(FontAwesomeIcons.comment),
      ), */ //commented out test code
      body: SafeArea(
          child: Center(
              child: Column(children: [
        ElevatedButton(
          onPressed: () async {
            await NotificationService(
                    firestore: widget.firestore,
                    auth: widget.auth,
                    uid: widget.auth.currentUser!.uid)
                .createNotification(
                    'Test Notification',
                    'This is a test notification',
                    DateTime.now(),
                    '/notifications');
          },
          child: const Text('Create Test Notification'),
        ),
      ]))),
    );
  }
}
