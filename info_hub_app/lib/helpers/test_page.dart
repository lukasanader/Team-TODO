import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/screens/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await DatabaseService(firestore: widget.firestore, uid: '1')
                    .createNotification('Test Notification',
                        'This is a test notification', DateTime.now());
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )
              ),
              child: const Text('Create Test Notification'),
            ),
          
          ],
        ) 
      
      
      ),
    );

  }
}
