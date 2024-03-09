import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/message_feature/message_rooms_card.dart';
import 'package:info_hub_app/message_feature/patient_message_view.dart';
import 'package:info_hub_app/message_feature/message_model.dart';
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
  late Widget patientMessageViewWidget;



  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();


    await auth.createUserWithEmailAndPassword(
      email: 'patient@gmail.com',
      password: 'Patient123!');
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


    CollectionReference chatRoomMembersCollectionReference = firestore.collection('message_rooms_members');

    chatRoomMembersCollectionReference.add({
      'adminId' : '1',
      'patientId' : uid
    });

    patientMessageViewWidget = MaterialApp(
      home: PatientMessageView(firestore: firestore, auth: auth),
    );
  });




  testWidgets('Will display 3 existing chats', (WidgetTester tester) async {
    CollectionReference chatRoomMembersCollectionReference = firestore.collection('message_rooms_members');

    chatRoomMembersCollectionReference.add({
      'adminId' : '2',
      'patientId' : auth.currentUser!.uid
    });
    chatRoomMembersCollectionReference.add({
      'adminId' : '3',
      'patientId' : auth.currentUser!.uid
    });
  
    // Build our app and trigger a frame.
    await tester.pumpWidget(patientMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));

  });


  testWidgets('Pressing onto existing chat leads to correct message room view', (WidgetTester tester) async {
    
    firestore
      .collection('message_rooms')
      .doc('1')
      .collection('messages')
      .add({
        'senderId' : '1',
        'receiverId' : auth.currentUser!.uid,
        'message' : 'Hello world',
        'timestamp' : DateTime.now(),
      });
    

    await tester.pumpWidget(patientMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(MessageRoomCard);
    expect(cardFinder, findsNWidgets(1));


    await tester.tap(find.byType(MessageRoomCard));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.byType(MessageRoomView), findsOne);

  });


}