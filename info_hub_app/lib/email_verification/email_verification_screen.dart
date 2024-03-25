// This file contains the code for the email verification screen

import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/helpers/base.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/services/auth.dart';

class EmailVerificationScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localnotificationsplugin;
  const EmailVerificationScreen(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.storage,
      required this.themeManager,
      required this.messaging,
      required this.localnotificationsplugin});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late AuthService _auth;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _auth = AuthService(
      firestore: widget.firestore,
      auth: widget.auth,
      messaging: widget.messaging,
      localnotificationsplugin: widget.localnotificationsplugin,
    );
  }
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'An email has been sent to your email address. Please verify your email address to continue.',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () async {
                if (user != null) {
                  await user!.sendEmailVerification();
                }
              },
              child: Text('Resend Verification Email'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (user != null){
                  await user!.reload();
                  if (user!.emailVerified){
                    String role = await UserController(widget.auth, widget.firestore).getUserRoleType();
                    Widget nextPage = Base(
                        firestore: widget.firestore,
                        auth: widget.auth,
                        storage: widget.storage,
                        themeManager: widget.themeManager,
                        roleType: role,
                      );
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => nextPage), (Route<dynamic> route) => false);
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email not verified')));
                  }
                }
              },
              child: Text('I have verified my email'),
            ),
            ],
            ),
            ),

    );
    
}
}