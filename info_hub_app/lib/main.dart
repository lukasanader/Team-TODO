import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/models/notification.dart' as custom;
import 'package:info_hub_app/screens/dashboard.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/services/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) => DatabaseService(uid: '').notifications,
          initialData: [], // Initial data while waiting for Firebase data
        ),
      ],
      child: MaterialApp(
        home: MainPage(),
      ),
    );
  }
}
