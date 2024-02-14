import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/screens/admin_dash.dart';
import 'package:info_hub_app/screens/create_topic.dart';
import 'package:info_hub_app/screens/question_view.dart';

void main() {
late FirebaseFirestore firestore = FakeFirebaseFirestore();
late Widget questionWidget;

  setUp((){
      firestore = FakeFirebaseFirestore();
      questionWidget = MaterialApp(
      home: ViewQuestionPage(firestore: firestore),
    );
    CollectionReference questionsCollectionRef =
        firestore.collection('questions');
  questionsCollectionRef.add({
    'question' : 'This is test question number 1',
    'uid' : 1,
    'date' : DateTime.now().toString()
  }
  );
  questionsCollectionRef.add({
    'question' : 'This is test question number 2',
    'uid' : 1,
    'date' : DateTime.now().toString()
  }
  );
  });

 testWidgets('View question test', (WidgetTester tester) async {
  
  await tester.pumpWidget(questionWidget);
  await tester.pumpAndSettle();
    // Tap into the ListView
  Finder listViewFinder = find.byType(ListView);
  expect(listViewFinder, findsOneWidget);
  Finder cardFinder = find.byType(Card);
  expect(cardFinder, findsNWidgets(2));
  final textFinders = find.byType(Text);
  expect((textFinders.first.evaluate().single.widget as Text).data, 'This is test question number 1 0 days ago');
  expect((textFinders.at(1).evaluate().single.widget as Text).data, 'This is test question number 2 0 days ago');
 });
testWidgets('Delete question test', (WidgetTester tester) async {
  
  await tester.pumpWidget(questionWidget);
  await tester.pumpAndSettle();
    // Tap into the ListView
  final tickIcon = find.byType(IconButton);
  await tester.tap(tickIcon.first);
  await tester.pumpAndSettle();
  Finder cancelButton = find.text('Cancel');

  await tester.tap(cancelButton);
  await tester.pumpAndSettle();
  //Verify nothings changed
  Finder cardFinder = find.byType(Card);
  expect(cardFinder, findsNWidgets(2));
  Finder textFinders = find.byType(Text);
  expect((textFinders.first.evaluate().single.widget as Text).data, 'This is test question number 1 0 days ago');
  expect((textFinders.at(1).evaluate().single.widget as Text).data, 'This is test question number 2 0 days ago');
  textFinders = find.byType(Text);
  cardFinder = find.byType(Card);
  //Click confirm
  await tester.tap(tickIcon.first);
  await tester.pumpAndSettle();
  Finder confirmButton = find.text('Confirm');
  await tester.tap(confirmButton);
  await tester.pumpAndSettle();
  expect(cardFinder, findsNWidgets(1));
  expect((textFinders.first.evaluate().single.widget as Text).data, 'This is test question number 2 0 days ago');
 });
 
}

