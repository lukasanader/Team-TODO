import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/message_feature/message_rooms_card.dart';
import 'package:info_hub_app/message_feature/patient_message_view.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:info_hub_app/threads/controllers/name_generator_controller.dart';

void main() {
  late MockFirebaseAuth auth;
  late FirebaseFirestore firestore;
  late Widget patientMessageViewWidget;

  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();

    // Initialize allNouns and allAdjectives before each test
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');

    await auth.createUserWithEmailAndPassword(
        email: 'patient@gmail.com', password: 'Patient123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'patient@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });

    CollectionReference userCollectionRef = firestore.collection('Users');
    userCollectionRef.doc('1').set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });
    userCollectionRef.doc('2').set({
      'email': 'admin2@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });
    userCollectionRef.doc('3').set({
      'email': 'admin3@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });

    CollectionReference chatRoomMembersCollectionReference =
        firestore.collection('message_rooms');

    chatRoomMembersCollectionReference.add({
      'adminId': '1',
      'patientId': uid,
      'patientDisplayName': generateUniqueName('1'),
      'adminDisplayName': 'admin@gmail.com'
    });

    patientMessageViewWidget = MaterialApp(
      home: PatientMessageView(firestore: firestore, auth: auth),
    );
  });

  testWidgets('Will display 3 existing chats', (WidgetTester tester) async {
    CollectionReference chatRoomMembersCollectionReference =
        firestore.collection('message_rooms');

    chatRoomMembersCollectionReference.add({
      'adminId': '2',
      'patientId': auth.currentUser!.uid,
      'patientDisplayName': generateUniqueName('2'),
      'adminDisplayName': 'admin2@gmail.com'
    });
    chatRoomMembersCollectionReference.add({
      'adminId': '3',
      'patientId': auth.currentUser!.uid,
      'patientDisplayName': generateUniqueName('3'),
      'adminDisplayName': 'admin3@gmail.com'
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(patientMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));
  });

  testWidgets('Pressing onto existing chat leads to correct message room view',
      (WidgetTester tester) async {
    firestore.collection('message_rooms').doc('1').collection('messages').add({
      'senderId': '1',
      'receiverId': auth.currentUser!.uid,
      'message': 'Hello world',
      'timestamp': DateTime.now(),
    });

    await tester.pumpWidget(patientMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(MessageRoomCard);
    expect(cardFinder, findsNWidgets(1));

    await tester.tap(find.byType(MessageRoomCard));
    await tester.pumpAndSettle();

    //username for admin
    String userName = generateUniqueName('1');

    expect(find.text(userName), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);
  });
}
