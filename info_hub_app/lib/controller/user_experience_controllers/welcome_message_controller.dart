// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/view/base_view/base.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

class WelcomeMessageController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  final FirebaseMessaging messaging;

  WelcomeMessageController({
    required this.firestore,
    required this.auth,
    required this.storage,
    required this.themeManager,
    required this.messaging,
  });

  Future<void> navigateToBase(BuildContext context) async {
    String uid = auth.currentUser!.uid;
    DocumentSnapshot user = await firestore.collection('Users').doc(uid).get();
    String roleType = user['roleType'];
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Base(
          auth: auth,
          storage: storage,
          firestore: firestore,
          themeManager: themeManager,
          roleType: roleType,
          messaging: messaging,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
