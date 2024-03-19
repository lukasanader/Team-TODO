import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/discovery_view/discovery_view.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/push_notifications/push_notifications.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'notifications/notification.dart' as custom;
import 'registration/start_page.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/notifications/notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:info_hub_app/topics/view_topic.dart';

final navigatorKey = GlobalKey<NavigatorState>();

ThemeManager themeManager = ThemeManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotifications pushNotifications = PushNotifications(
      uid: FirebaseAuth.instance.currentUser!.uid,
      firestore: FirebaseFirestore.instance,
      messaging: FirebaseMessaging.instance,
      navigatorKey: navigatorKey,
      http: http.Client(),
      localnotificationsplugin: FlutterLocalNotificationsPlugin());

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState!.pushNamed('/notifications');
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
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/notifications");
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  runApp(MyApp(
    firestore: firestore,
    auth: auth,
    storage: storage,
  ));
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
          create: (_) => DatabaseService(
                  auth: widget.auth,
                  firestore: widget.firestore,
                  uid: widget.auth.currentUser!.uid)
              .notifications,
          initialData: const [],
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: StartPage(
          firestore: widget.firestore,
          storage: widget.storage,
          auth: widget.auth,
          themeManager: themeManager,
        ),
        routes: {
          '/notifications': (context) => Notifications(
                auth: widget.auth,
                firestore: widget.firestore,
              ),
        },
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeManager.themeMode,

        // home: HomePage(auth: auth, firestore: firestore, storage: storage)
        // home: AdminHomepage(firestore: firestore, storage: storage),
      ),
    );
  }
}
