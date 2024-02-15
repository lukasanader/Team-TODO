import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/screens/admin_dash.dart';
import 'package:info_hub_app/screens/base.dart';
import 'screens/start_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  runApp(MyApp(firestore: firestore,auth: auth));
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const MyApp({Key? key, required this.firestore,required this.auth}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Base(firestore: firestore)
      //StartPage(
        //firestore: firestore,auth: auth,),
    );
    
  }
}

