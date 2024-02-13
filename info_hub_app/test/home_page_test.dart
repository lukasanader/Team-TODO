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
  late FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  late Widget TrendingTopicWidget;
  setUp(() {
    TrendingTopicWidget = MaterialApp(
      home:trendingTopic(firestore: firestore),
    );
  });
  testWidgets('Trendings topic are in right order', (WidgetTester tester) async {
    // Build your widget
    
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
    await tester.pumpWidget(TrendingTopicWidget);
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
    CollectionReference topicCollectionRef =
        firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 4',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 5,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 5',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 4,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 6',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 3,
      'date': DateTime.now(),
    });
    topicCollectionRef.add({
      'title': 'test 7',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 1,
      'date': DateTime.now(),
    });

    await tester.pumpWidget(TrendingTopicWidget);
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
}

