import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/analytics/topics/analytics_topic.dart';
import 'package:intl/intl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late Widget analyticsTopicPageWidget;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    CollectionReference topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'topic with most views',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 100,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
    });
    topicCollectionRef.add({
      'title': 'topic with least views',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 0,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
    });
    topicCollectionRef.add({
      'title': 'topic with most likes',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 8,
      'date': DateTime.now(),
      'likes': 100,
      'dislikes': 0,
    });
    topicCollectionRef.add({
      'title': 'topic with most dislikes',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 8,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 100,
    });
    topicCollectionRef.add({
      'title': 'alphabetically first topic',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 8,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
    });
    topicCollectionRef.add({
      'title': 'z topic',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 8,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
    });

    analyticsTopicPageWidget = MaterialApp(
      home: AnalyticsTopicView(storage: storage, firestore: firestore),
    );
  });

  testWidgets('AnalyticsTopicView with default view',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    // AppBar is displayed
    expect(find.text('Topic Analytics'), findsOneWidget);

    // DropdownButton is displayed
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('Name (A - Z)'), findsOneWidget);
  });

  testWidgets('DropdownButton changes value correctly for Name (Z - A)',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name (Z - A)').last);
    await tester.pumpAndSettle();

    expect(find.text('Name (Z - A)'), findsOneWidget);
    // Add more expectations for other dropdown values
  });

  testWidgets('DropdownButton changes value correctly for Most Popular',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Popular').last);
    await tester.pumpAndSettle();

    expect(find.text('Most Popular'), findsOneWidget);
    // Add more expectations for other dropdown values
  });

  testWidgets('DropdownButton changes value correctly for Trending',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trending').last);
    await tester.pumpAndSettle();

    expect(find.text('Trending'), findsOneWidget);
    // Add more expectations for other dropdown values
  });

  testWidgets('DropdownButton changes value correctly for Most Likes',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Likes').last);
    await tester.pumpAndSettle();

    expect(find.text('Most Likes'), findsOneWidget);
    // Add more expectations for other dropdown values
  });

  testWidgets('DropdownButton changes value correctly for Most Dislikes',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Dislikes').last);
    await tester.pumpAndSettle();

    expect(find.text('Most Dislikes'), findsOneWidget);
  });

  testWidgets('Topic shows correct like analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('topic with most likes'));
    await tester.pumpAndSettle();

    expect(find.text('Likes'), findsOneWidget);

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Topic shows correct dislikes analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('topic with most dislikes'));
    await tester.pumpAndSettle();

    expect(find.text('Dislikes'), findsOneWidget);

    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('Topic shows correct views analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('topic with most views'));
    await tester.pumpAndSettle();

    expect(find.text('Views'), findsOneWidget);

    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('Topic shows correct date analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('topic with most views'));
    await tester.pumpAndSettle();

    expect(find.text('Uploaded Date'), findsOneWidget);
  });

  testWidgets('Topic shows correct time analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('topic with most views'));
    await tester.pumpAndSettle();

    expect(find.text('Uploaded Time'), findsOneWidget);
  });
}
