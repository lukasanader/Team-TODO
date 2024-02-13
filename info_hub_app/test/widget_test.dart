// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/screens/trending_topic.dart';

void main() {
  testWidgets('Trendings topic are in right order', (WidgetTester tester) async {
    // Build your widget
    final firestore = FakeFirebaseFirestore();
    CollectionReference topicCollectionRef =
        firestore.collection('topics');
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
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 5,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 3',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 2,
      'date': DateTime.now(),
    });
    await tester.pumpWidget(MyApp(firestore: firestore));
    await tester.pumpAndSettle();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));

    final textFinders = find.byType(Text);
    // Check the order of card titles
    expect((textFinders.first.evaluate().single.widget as Text).data, 'test 1');
    expect((textFinders.at(1).evaluate().single.widget as Text).data, 'test 2');
    expect((textFinders.last.evaluate().single.widget as Text).data, 'test 3');
  });

   testWidgets('Shows only first 6 trending topics', (WidgetTester tester) async {
    // Build your widget
    final firestore = FakeFirebaseFirestore();
    CollectionReference topicCollectionRef =
        firestore.collection('topics');
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
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 9,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 3',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 8,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 4',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 7,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 5',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 6,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 6',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 5,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 7',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 4,
      'date': DateTime.now(),
    });

    await tester.pumpWidget(MyApp(firestore: firestore));
    await tester.pumpAndSettle();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final textFinders = find.byType(Text);
    // Check that test 7 is ignored
    expect((textFinders.last.evaluate().single.widget as Text).data, 'test 6');
  });
  testWidgets('Show Post Dialog Test', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(firestore: firestore,)); // Replace MyApp with the name of your app widget.
    // Trigger the _showPostDialog method
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // Verify that the AlertDialog is displayed
    //expect(find.byType(AlertDialog), findsOneWidget);
    // Enter text into the TextField
    await tester.enterText(find.byType(TextField), 'Test question');
    // Tap the Submit button
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await firestore.collection("questions").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
      querySnapshot.docs;
    // Check if the collection contains a document with the expected question
    expect(
      documents.any(
        (doc) => doc.data()?['question'] == 'Test question',
      ),
      isTrue,
    );
    // Verify that the dialog is closed
    expect(find.byType(AlertDialog), findsNothing);
  });
}

