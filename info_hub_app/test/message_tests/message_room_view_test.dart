import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/message_feature/message_bubble.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';

void main() {
  late MockFirebaseAuth auth;
  late FirebaseFirestore firestore;
  late Widget messageRoomViewWidget;



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


    CollectionReference chatRoomMembersCollectionReference = firestore.collection('message_rooms');

    chatRoomMembersCollectionReference.doc('1').set({
      'adminId' : uid,
      'patientId' : '123456789'
    });

    messageRoomViewWidget = MaterialApp(
      home: MessageRoomView(firestore: firestore, auth: auth, senderId: uid, receiverId: '123456789', onNewMessageRoomCreated: () {},),
    );
  });


  testWidgets('User is able to send a message', (WidgetTester tester) async {
    await tester.pumpWidget(messageRoomViewWidget);
    await tester.pumpAndSettle();

    final textBox = find.byType(TextField);
    await tester.enterText(textBox, 'hello world!');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    expect(find.byType(MessageBubble), findsOneWidget);
    expect(find.text('hello world!'), findsOneWidget);

  });
}
