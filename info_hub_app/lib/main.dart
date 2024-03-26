// coverage:ignore-file

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/helpers/base.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/notifications/notification_service.dart';
import 'package:info_hub_app/push_notifications/push_notifications_controller.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'notifications/notification_model.dart' as custom;
import 'registration/start_page.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/notifications/notification_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart' show rootBundle;

Set<String>? allNouns;
Set<String>? allAdjectives;

Future<Set<String>> loadWordSet(String path) async {
  String data = await rootBundle.loadString(path);
  return Set<String>.from(data.split('\n').where((line) => line.isNotEmpty));
}

final navigatorKey = GlobalKey<NavigatorState>();

ThemeManager themeManager = ThemeManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  allNouns = await loadWordSet('assets/texts/nouns.txt');
  allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
  PushNotifications pushNotifications = PushNotifications(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      messaging: FirebaseMessaging.instance,
      nav: navigatorKey,
      http: http.Client(),
      localnotificationsplugin: FlutterLocalNotificationsPlugin());

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState!
      ..popUntil((route) => false)
      ..pushNamed('/base')
      ..pushNamed('/notifications');
  });

  pushNotifications.init();
  pushNotifications.localNotiInit();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    if (message.notification != null) {
      pushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!
        ..popUntil((route) => false)
        ..pushNamed('/base')
        ..pushNamed('/notifications');
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  initializeDateFormatting('en_GB', null).then((_) {
    runApp(MyApp(
      firestore: firestore,
      auth: auth,
      storage: storage,
    ));
  });
}

class MyApp extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  const MyApp(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.storage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Theme data listener
  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    themeManager.addListener((themeListener));
    super.initState();
  }

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) => NotificationService(
            auth: widget.auth,
            firestore: widget.firestore,
            uid: widget.auth.currentUser!.uid,
          ).notifications,
          initialData: const [],
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: FutureBuilder(
          future: checkUser(),
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              switch (snapshot.data) {
                case 'admin':
                  return Base(
                    auth: widget.auth,
                    firestore: widget.firestore,
                    storage: widget.storage,
                    themeManager: themeManager,
                    roleType: 'admin',
                  );
                case 'user':
                  return Base(
                    auth: widget.auth,
                    firestore: widget.firestore,
                    storage: widget.storage,
                    themeManager: themeManager,
                    roleType: 'user',
                  );
                default:
                  return StartPage(
                    firestore: widget.firestore,
                    storage: widget.storage,
                    auth: widget.auth,
                    messaging: FirebaseMessaging.instance,
                    localnotificationsplugin: FlutterLocalNotificationsPlugin(),
                    themeManager: themeManager,
                  );
              }
            }
          },
        ),
        routes: {
          '/notifications': (context) => Notifications(
                auth: widget.auth,
                firestore: widget.firestore,
              ),
          '/home': (context) => HomePage(
                auth: widget.auth,
                firestore: widget.firestore,
                storage: widget.storage,
              ),
          '/base': (context) => FutureBuilder<Base>(
                future: checkUser().then((roleType) => Base(
                      auth: widget.auth,
                      firestore: widget.firestore,
                      storage: widget.storage,
                      themeManager: themeManager,
                      roleType: roleType,
                    )),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    return snapshot.data!;
                  }
                },
              ),
        },
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeManager.themeMode,
      ),
    );
  }

  // Function to check user's role
  Future<String> checkUser() async {
    if (widget.auth.currentUser != null) {
      DocumentSnapshot snapshot = await widget.firestore
          .collection('Users')
          .doc(widget.auth.currentUser!.uid)
          .get();
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
      if (userData['roleType'] == 'admin') {
        return 'admin';
      } else {
        return 'user';
      }
    } else {
      return 'guest';
    }
  }
}
