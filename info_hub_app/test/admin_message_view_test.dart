import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/message_feature/admin_message_view.dart';
import 'package:info_hub_app/message_feature/message_model.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:info_hub_app/patient_experience/admin_experience_view.dart';
import 'package:info_hub_app/topics/create_topic.dart';
import 'package:info_hub_app/ask_question/question_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseAuth auth = MockFirebaseAuth();
  late Widget adminMessageViewWidget;
  late CollectionReference chatRoomMembersCollectionReference;
  CollectionReference userCollectionRef = firestore.collection('Users');
  late String uid;




  setUp(() async {
    await auth.createUserWithEmailAndPassword(email: 'admin@gmail.com', password: 'Admin123!');
    uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });

    userCollectionRef.doc('1').set({
      'email': 'user@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });

    chatRoomMembersCollectionReference = firestore.collection('message_rooms_members');

    chatRoomMembersCollectionReference.add({
      'adminId' : uid,
      'patientId' : '1'
    });

    adminMessageViewWidget = MaterialApp(
      home: MessageView(firestore: firestore, auth: auth),
    );
  });




  testWidgets('Will display 3 existing chats', (WidgetTester tester) async {
    chatRoomMembersCollectionReference.add({
      'adminId' : uid,
      'patientId' : '2'
    });
    chatRoomMembersCollectionReference.add({
      'adminId' : uid,
      'patientId' : '3'
    });
  
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));

  });



  testWidgets('Show dialogue to message patient test', (WidgetTester tester) async {
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

  testWidgets('Can message patient through dialogue', (WidgetTester tester) async {


    // Build our app and trigger a frame.
    await tester.pumpWidget(adminMessageViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showUser method
    await tester.tap(find.text('Message new patient'));
    await tester.pump();

    Finder textFinder = find.text('user@gmail.com');
    expect(tester.widget<Text>(textFinder).data, 'user@gmail.com');

    // QuerySnapshot data = await firestore
    //   .collection('Users')
    //   .where('roleType', isEqualTo: 'Patient')
    //   .get();
    // List<dynamic> users = List.from(data.docs);
    // dynamic test = users[0];
    // print(test.id);
    // print(test['email']);


    await tester.tap(find.text('user@gmail.com'));
    await tester.pumpAndSettle();
    // expect(find.byType(MessageRoomView), findsOne);


  });

}
