import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/screens/view_topic.dart';

void main() {
  testWidgets('ViewTopicScreen shows correct fields with no video passes',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
      ),
    ));
    await tester.pumpAndSettle();

    // Verify the presence of the AppBar title
    expect(find.text('no video topic'), findsOneWidget);

    // Verify the presence of the description for the first topic
    expect(find.text('Test Description'), findsOneWidget);

    // Verify the presence of the Read Article button
    expect(find.widgetWithText(ElevatedButton, 'Read Article'), findsOneWidget);
  });

  testWidgets('ViewTopicScreen shows correct fields with video passes',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    CollectionReference topicCollectionRef = firestore.collection('topics');

    await topicCollectionRef.add({
      'title': 'no video topic',
      'description': 'Test Description',
      'articleLink': 'https://www.javatpoint.com/heap-sort',
      'videoUrl': '',
    });

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    await tester.pumpWidget(MaterialApp(
      home: ViewTopicScreen(
        topic: data.docs[0] as QueryDocumentSnapshot<Object>,
      ),
    ));
    await tester.pumpAndSettle();

    // Verify the presence of the AppBar title
    expect(find.text('no video topic'), findsOneWidget);

    // Verify the presence of the description for the first topic
    expect(find.text('Test Description'), findsOneWidget);

    // Verify the presence of the Read Article button
    expect(find.widgetWithText(ElevatedButton, 'Read Article'), findsOneWidget);
  });
}
