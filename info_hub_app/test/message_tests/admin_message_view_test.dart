import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/message_feature/admin_message_view.dart';
import 'package:info_hub_app/message_feature/message_bubble.dart';
import 'package:info_hub_app/message_feature/message_rooms_card.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:info_hub_app/threads/name_generator.dart';

void main() {
  late MockFirebaseAuth auth;
  late FirebaseFirestore firestore;
  late Widget adminMessageViewWidget;

  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();

    // Initialize allNouns and allAdjectives before each test
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');

    await auth.createUserWithEmailAndPassword(
        email: 'admin@gmail.com', password: 'Admin123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });

    CollectionReference userCollectionRef = firestore.collection('Users');
    userCollectionRef.doc('1').set({
      'email': 'user@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    userCollectionRef.doc('2').set({
      'email': 'user2@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    userCollectionRef.doc('3').set({
      'email': 'user3@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });

    CollectionReference chatRoomMembersCollectionReference =
        firestore.collection('message_rooms');

    chatRoomMembersCollectionReference.doc('1').set({
      'adminId': uid,
      'patientId': '1',
      'patientDisplayName': generateUniqueName(uid),
      'adminDisplayName': 'user@gmail.com'
    });

    adminMessageViewWidget = MaterialApp(
      home: MessageView(firestore: firestore, auth: auth),
    );
  });

  testWidgets('Will display 3 existing chats', (WidgetTester tester) async {
    CollectionReference chatRoomMembersCollectionReference =
        firestore.collection('message_rooms');

    chatRoomMembersCollectionReference.doc('2').set({
      'adminId': auth.currentUser!.uid,
      'patientId': '2',
      'patientDisplayName': generateUniqueName(auth.currentUser!.uid),
      'adminDisplayName': 'user2@gmail.com'
    });
    chatRoomMembersCollectionReference.doc('3').set({
      'adminId': auth.currentUser!.uid,
      'patientId': '3',
      'patientDisplayName': generateUniqueName(auth.currentUser!.uid),
      'adminDisplayName': 'user3@gmail.com'
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));
  });

  testWidgets('Show dialogue to message patient test',
      (WidgetTester tester) async {
    CollectionReference userCollectionRef = firestore.collection('Users');
    userCollectionRef.add({
      'email': 'john@nhs.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    userCollectionRef.add({
      'email': 'jane@nhs.com',
      'firstName': 'Jane',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showUser method
    await tester.tap(find.text('Message new patient'));
    await tester.pump();

    final searchTextField = find.byType(TextField);
    await tester.enterText(searchTextField, 'jo');
    await tester.pump();

    Finder textFinder = find.text('john@nhs.com');
    expect(tester.widget<Text>(textFinder).data, 'john@nhs.com');

    await tester.enterText(searchTextField, 'There is no user with this email');
    await tester.pump();
    textFinder = find.text('Sorry there are no patients matching this email.');
    expect(tester.widget<Text>(textFinder).data,
        'Sorry there are no patients matching this email.');
  });

  testWidgets('Can message correct patient through dialogue',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showUser method
    await tester.tap(find.text('Message new patient'));
    await tester.pump();

    expect(find.text('user2@gmail.com'), findsOneWidget);

    String userName = generateUniqueName('2');

    await tester.tap(find.text('user2@gmail.com'));
    await tester.pumpAndSettle();
    expect(find.text(userName), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);
  });

  testWidgets('Pressing onto existing chat leads to correct message room view',
      (WidgetTester tester) async {
    firestore.collection('message_rooms').doc('1').collection('messages').add({
      'senderId': auth.currentUser!.uid,
      'receiverId': '1',
      'message': 'Hello world',
      'timestamp': DateTime.now(),
    });

    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(MessageRoomCard);
    expect(cardFinder, findsNWidgets(1));

    String userName = generateUniqueName('1');

    await tester.tap(find.byType(MessageRoomCard));
    await tester.pumpAndSettle();

    expect(find.text(userName), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);
  });



  testWidgets('Can create message room and delete message room',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showUser method

    //process to enter a message room
    await tester.tap(find.text('Message new patient'));
    await tester.pump();

    expect(find.text('user2@gmail.com'), findsOneWidget);

    String userName = generateUniqueName('2');

    await tester.tap(find.text('user2@gmail.com'));
    await tester.pumpAndSettle();
    expect(find.text(userName), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);

    //process to send a message which should create a message room
    final textBox = find.byType(TextField);
    await tester.enterText(textBox, 'hello world!');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    expect(find.byType(MessageBubble), findsOneWidget);
    expect(find.text('hello world!'), findsOneWidget);

    //process to check if message room exists
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(MessageRoomCard);

    expect(cardFinder, findsNWidgets(2));
    expect(find.byType(MessageView), findsOneWidget);
    expect(find.text('user2@gmail.com'), findsOneWidget);

    //process to delete the message room
    Finder deleteButton = find.byIcon(Icons.delete).last;

    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    //process to check room and messages are deleted
    expect(find.text('user2@gmail.com'), findsNothing);
    await tester.tap(find.text('Message new patient'));
    await tester.pump();

    expect(find.text('user2@gmail.com'), findsOneWidget);

    await tester.tap(find.text('user2@gmail.com'));
    await tester.pumpAndSettle();
    expect(find.text(userName), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);

    //expect the message to have deleted
    expect(find.text('hello world!'), findsNothing);
  });
}
