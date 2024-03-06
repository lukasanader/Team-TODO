import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/message_feature/admin_message_view.dart';
import 'package:info_hub_app/message_feature/message_bubble.dart';
import 'package:info_hub_app/message_feature/message_model.dart';
import 'package:info_hub_app/message_feature/message_rooms_card.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:info_hub_app/patient_experience/admin_experience_view.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:info_hub_app/ask_question/question_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mockito/mockito.dart';

import '../mock.dart';

void main() {
  late MockFirebaseAuth auth;
  late FirebaseFirestore firestore;
  late Widget adminMessageViewWidget;



  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();


    await auth.createUserWithEmailAndPassword(email: 'admin@gmail.com', password: 'Admin123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });

    CollectionReference userCollectionRef = firestore.collection('Users');
    userCollectionRef.doc('123456789').set({
      'email': 'user@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });


    CollectionReference chatRoomMembersCollectionReference = firestore.collection('message_rooms_members');

    chatRoomMembersCollectionReference.doc('1').set({
      'adminId' : uid,
      'patientId' : '123456789'
    });

    adminMessageViewWidget = MaterialApp(
      home: MessageView(firestore: firestore, auth: auth),
    );
  });




  testWidgets('Will display 3 existing chats', (WidgetTester tester) async {
    CollectionReference chatRoomMembersCollectionReference = firestore.collection('message_rooms_members');

    chatRoomMembersCollectionReference.doc('2').set({
      'adminId' : auth.currentUser!.uid,
      'patientId' : '2'
    });
    chatRoomMembersCollectionReference.doc('3').set({
      'adminId' : auth.currentUser!.uid,
      'patientId' : '3'
    });
  
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));

  });



  testWidgets('Show dialogue to message patient test', (WidgetTester tester) async {
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
    textFinder = find.text(
        'Sorry there are no patients matching this email.');
    expect(tester.widget<Text>(textFinder).data,
        'Sorry there are no patients matching this email.');
  });

  testWidgets('Can message correct patient through dialogue', (WidgetTester tester) async {


    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showUser method
    await tester.tap(find.text('Message new patient'));
    await tester.pump();

    Finder textFinder = find.text('user@gmail.com');
    expect(tester.widget<Text>(textFinder).data, 'user@gmail.com');


    await tester.tap(find.text('user@gmail.com'));
    await tester.pumpAndSettle();
    expect(find.text('123456789'), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);


  });

  testWidgets('Pressing onto existing chat leads to correct message room view', (WidgetTester tester) async {
    
    firestore
      .collection('message_rooms')
      .doc('1')
      .collection('messages')
      .add({
        'senderId' : auth.currentUser!.uid,
        'receiverId' : '123456789',
        'message' : 'Hello world',
        'timestamp' : DateTime.now(),
      });
    

    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(MessageRoomCard);
    expect(cardFinder, findsNWidgets(1));


    await tester.tap(find.byType(MessageRoomCard));
    await tester.pumpAndSettle();

    expect(find.text('123456789'), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);

  });


}
