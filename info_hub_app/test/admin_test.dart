import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/screens/admin_dash.dart';

void main() {
late FirebaseFirestore firestore = FakeFirebaseFirestore();;
late Widget adminWidget;

  setUp((){
      firestore = FakeFirebaseFirestore();
      adminWidget = MaterialApp(
      home: adminHomepage(firestore: firestore),
    );
  });
  testWidgets('Add admin test', (WidgetTester tester) async {
    CollectionReference userCollectionRef =
      firestore.collection('Users');
    userCollectionRef.add(
      {
        'email': 'test@nhs.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'roleType': 'Healthcare Professional'
      }
    );
    userCollectionRef.add(
      {
        'email': 'test@outlook.com',
        'firstName': 'Jane',
        'lastName': 'Doe',
        'roleType': 'Patient'
      }
    );
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminWidget);
    // Trigger the _showUser method
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // Verify that the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);
    Finder textFinder = find.text('test@nhs.com');

    //Verify that only healthcare professionals are showing
    expect(textFinder, findsOneWidget);
    expect(tester.widget<Text>(textFinder).data, 'test@nhs.com');
    //Select user
    await tester.tap(textFinder.first);
    //Tap the submit button
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    QuerySnapshot data = await firestore.collection('Users')
    .where('roleType', isEqualTo: 'admin')
    .get();
    List<dynamic> users = List.from(data.docs);
    expect(users[0]['email'], 'test@nhs.com');
    // Verify that the dialog is closed
    expect(find.byType(AlertDialog), findsNothing);
  });

testWidgets('Add admin search test', (WidgetTester tester) async {
    CollectionReference userCollectionRef =
      firestore.collection('Users');
    userCollectionRef.add(
      {
        'email': 'john@nhs.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'roleType': 'Healthcare Professional'
      }
    );
    userCollectionRef.add(
      {
        'email': 'jane@nhs.com',
        'firstName': 'Jane',
        'lastName': 'Doe',
        'roleType': 'Healthcare Professional'
      }
    );
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminWidget);
    await tester.pumpAndSettle();
    // Trigger the _showUser method
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    final searchTextField = find.byType(TextField);
    await tester.enterText(searchTextField,'jo');
    await tester.pump();
    
    Finder textFinder = find.text('john@nhs.com');
    expect(tester.widget<Text>(textFinder).data, 'john@nhs.com');

    await tester.enterText(searchTextField,'There is no user with this email');
    await tester.pump();
    textFinder = find.text('Sorry there are no healthcare professionals matching this email.');
    expect(tester.widget<Text>(textFinder).data, 'Sorry there are no healthcare professionals matching this email.');
  });
}
