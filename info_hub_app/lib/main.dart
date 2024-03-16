import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/discovery_view/discovery_view.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'notifications/notification.dart' as custom;
import 'registration/start_page.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  runApp(MyApp(
    firestore: firestore,
    auth: auth,
    storage: storage,
  ));
}

ThemeManager _themeManager = ThemeManager();

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
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener((themeListener));
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) => DatabaseService(
                  uid: widget.auth.currentUser!.uid,
                  firestore: widget.firestore)
              .notifications,
          initialData: const [], // Initial data while waiting for Firebase data
        ),
      ],
      child: MaterialApp(
        home: StartPage(
          firestore: widget.firestore,
          storage: widget.storage,
          auth: widget.auth,
          themeManager: _themeManager,
        ),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeManager.themeMode,

        routes: {
          '/disc': (context) => StartPage(
                auth: widget.auth,
                storage: widget.storage,
                firestore: widget.firestore,
                themeManager: _themeManager,
              ), // Screen A route
          // Screen C route
        },

        // home: HomePage(auth: auth, firestore: firestore, storage: storage)
        // home: AdminHomepage(firestore: firestore, storage: storage),
      ),
    );
  }
}
