import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/services/database_service.dart';
import 'package:info_hub_app/screens/webinar-screens/chat.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });
  testWidgets('Chat Widget Test', (WidgetTester tester) async {
    // Mock data
    final String channelId = 'mockChannelId';
    final UserModel user = UserModel(uid: 'mockUid', firstName: 'John',lastName: 'Doe', roleType: 'Patient',email: 'testemail@email.com');
    final firestore = FakeFirebaseFirestore();

  
    // Build our widget and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: Chat(channelId: channelId, user: user, firestore: firestore),
    ));

    // Verify that the Chat widget initializes correctly
    // expect(find.byType(Chat), findsOneWidget);
    // expect(find.byType(StreamBuilder), findsOneWidget);

    // // Simulate loading state
    // expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // // Simulate loaded state
    // await tester.pump();

    // // Verify that the chat messages are displayed
    // expect(find.text('Anonymous Beaver'), findsOneWidget);

    // // Simulate sending a message with profanity
    // await tester.enterText(find.byType(TextField), 'Profanity message');
    // await tester.tap(find.byType(IconButton));
    // await tester.pump();

    // // Verify that the warning dialog is shown
    // expect(find.text('Warning'), findsOneWidget);

    // // Simulate sending a message with the user's name
    // await tester.enterText(find.byType(TextField), 'John, check this out!');
    // await tester.tap(find.byType(IconButton));
    // await tester.pump();

    // // Verify that the warning dialog is shown
    // expect(find.text('Warning'), findsOneWidget);
  }
  );
}

