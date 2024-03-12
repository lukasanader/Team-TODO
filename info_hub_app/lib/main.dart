import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/discovery_view/discovery_view.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'notifications/notification.dart' as custom;
import 'registration/start_page.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/topics/view_topic.dart';

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

class MyApp extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  const MyApp(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.storage});

  @override
  Widget build(BuildContext context) {
 
      return MaterialApp(
        home: StartPage(
          firestore: firestore,
          storage: storage,
          auth: auth,
        ),

        // home: HomePage(auth: auth, firestore: firestore, storage: storage)
        // home: AdminHomepage(firestore: firestore, storage: storage),
      );
    
  }
}
