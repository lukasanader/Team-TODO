import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/activity_view.dart';
import 'package:info_hub_app/screens/admin_dash.dart';
import 'package:info_hub_app/screens/create_topic.dart';
import 'package:info_hub_app/screens/home_page.dart';
import 'package:info_hub_app/screens/question_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseAuth auth = MockFirebaseAuth();
  late Widget activityWidget;

  setUp(() async{
    await auth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password');
    activityWidget = MaterialApp(
      home: ActivityView(firestore: firestore, auth: auth,),
    );
    CollectionReference topicCollectionRef= firestore
    .collection('topics');
     topicCollectionRef.add({
      'title': 'test 1',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 10,
      'date': DateTime.now(),
    });
     topicCollectionRef.add({
      'title': 'test 2',
      'description': 'this is also a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 10,
      'date': DateTime.now(),
    });
  });

  testWidgets('Test activity tracker', (WidgetTester tester) async {
    //Create an activity
    await tester.pumpWidget(MaterialApp(home: HomePage(firestore: firestore, auth: auth)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('test 1'));
    await tester.tap(find.text('test 2'));
    await tester.pumpAndSettle();
   
    //Check if activity is recorded
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await firestore.collection("activity").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
      querySnapshot.docs;
    // Check if the collection contains a document with the type of activity
    expect(
      documents.any(
        (doc) => doc.data()?['type'] == 'topic',
      ),
      isTrue,
    );

    await tester.pumpWidget(activityWidget);
    await tester.pumpAndSettle();
    expect(find.text('test 1'), findsOneWidget);
  });

  
}