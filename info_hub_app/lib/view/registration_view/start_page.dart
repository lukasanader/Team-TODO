import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'registration_screen.dart';
import 'package:info_hub_app/view/login_view/login_screen.dart';

class StartPage extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localnotificationsplugin;
  const StartPage(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.storage,
      required this.themeManager,
      required this.messaging,
      required this.localnotificationsplugin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100.0), // Add padding here
                child: Image.asset(
                  'assets/base_image.png',
                  width: 180.0,
                  height: 180.0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Team TODO',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 250.0),
              SizedBox(
                width: 250.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(
                          storage: storage,
                          firestore: firestore,
                          auth: auth,
                          messaging: FirebaseMessaging.instance,
                          themeManager: themeManager,
                          localnotificationsplugin:
                              FlutterLocalNotificationsPlugin(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 250.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginScreen(
                                firestore: firestore,
                                auth: auth,
                                storage: storage,
                                themeManager: themeManager,
                                messaging: FirebaseMessaging.instance,
                                localnotificationsplugin:
                                    FlutterLocalNotificationsPlugin(),
                              )),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
