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
    // Add mock topics to the collection
    topicCollectionRef.add({
      'title': 'topic with most views',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 100,
      'date': DateTime.now(),
      'likes': 20,
      'dislikes': 20,
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
      'views': 5,
      'date': DateTime.now(),
      'likes': 100,
      'dislikes': 15,
    });
    topicCollectionRef.add({
      'title': 'topic with most dislikes',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 20,
      'date': DateTime.now(),
      'likes': 15,
      'dislikes': 100,
    });
    topicCollectionRef.add({
      'title': 'alphabetically first topic',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 15,
      'date': DateTime.now(),
      'likes': 10,
      'dislikes': 5,
    });
    topicCollectionRef.add({
      'title': 'z topic',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
      'views': 8,
      'date': DateTime.now(),
      'likes': 5,
      'dislikes': 3,
    });

    // Create the widget
    analyticsTopicPageWidget = MaterialApp(
      home: AnalyticsTopicView(storage: storage, firestore: firestore),
    );
  });

  testWidgets('AnalyticsTopicView with default view "Alphabet (A - Z)"',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    // AppBar is displayed
    expect(find.text('Topic Analytics'), findsOneWidget);

    // DropdownButton is displayed
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('Name (A - Z)'), findsOneWidget);
  });

  testWidgets('Topics are in correct order in default view "Alphabet (A - Z)"',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final cardTexts = <String>[
      'alphabetically first topic',
      'topic with least views',
      'topic with most dislikes',
      'topic with most likes',
      'topic with most views',
      'z topic',
    ];

    for (var i = 0; i < 6; i++) {
      final cardTextFinder = find.descendant(
        of: cardFinder.at(i),
        matching: find.byType(Text),
      );

      expect(
        (cardTextFinder.first.evaluate().single.widget as Text).data,
        cardTexts[i],
      );
    }
  });

  testWidgets('DropdownButton changes value correctly for Name (Z - A)',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name (Z - A)'));
    await tester.pumpAndSettle();

    expect(find.text('Name (Z - A)'), findsOneWidget);
  });

  testWidgets('Topics are in correct order in "Name (Z - A)" view',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name (Z - A)'));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final cardTexts = <String>[
      'z topic',
      'topic with most views',
      'topic with most likes',
      'topic with most dislikes',
      'topic with least views',
      'alphabetically first topic',
    ];

    for (var i = 0; i < 6; i++) {
      final cardTextFinder = find.descendant(
        of: cardFinder.at(i),
        matching: find.byType(Text),
      );

      expect(
        (cardTextFinder.first.evaluate().single.widget as Text).data,
        cardTexts[i],
      );
    }
  });

  testWidgets('DropdownButton changes value correctly for Most Popular',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Popular'));
    await tester.pumpAndSettle();

    expect(find.text('Most Popular'), findsOneWidget);
  });

  testWidgets('Topics are in correct order in "Most Popular" view',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Popular'));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final cardTexts = <String>[
      'topic with most views',
      'topic with most dislikes',
      'alphabetically first topic',
      'z topic',
      'topic with most likes',
      'topic with least views',
    ];

    for (var i = 0; i < 6; i++) {
      final cardTextFinder = find.descendant(
        of: cardFinder.at(i),
        matching: find.byType(Text),
      );

      expect(
        (cardTextFinder.first.evaluate().single.widget as Text).data,
        cardTexts[i],
      );
    }
  });

  testWidgets('DropdownButton changes value correctly for Trending',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trending'));
    await tester.pumpAndSettle();

    expect(find.text('Trending'), findsOneWidget);
  });

  testWidgets('Topics are in correct order in "Trending" view',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trending'));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final cardTexts = <String>[
      'topic with most views',
      'topic with most dislikes',
      'alphabetically first topic',
      'z topic',
      'topic with most likes',
      'topic with least views',
    ];

    for (var i = 0; i < 6; i++) {
      final cardTextFinder = find.descendant(
        of: cardFinder.at(i),
        matching: find.byType(Text),
      );

      expect(
        (cardTextFinder.first.evaluate().single.widget as Text).data,
        cardTexts[i],
      );
    }
  });

  testWidgets('DropdownButton changes value correctly for Most Likes',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Likes'));
    await tester.pumpAndSettle();

    expect(find.text('Most Likes'), findsOneWidget);
  });

  testWidgets('Topics are in correct order in "Most Likes" view',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Likes'));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final cardTexts = <String>[
      'topic with most likes',
      'topic with most views',
      'topic with most dislikes',
      'alphabetically first topic',
      'z topic',
      'topic with least views',
    ];

    for (var i = 0; i < 6; i++) {
      final cardTextFinder = find.descendant(
        of: cardFinder.at(i),
        matching: find.byType(Text),
      );

      expect(
        (cardTextFinder.first.evaluate().single.widget as Text).data,
        cardTexts[i],
      );
    }
  });

  testWidgets('DropdownButton changes value correctly for Most Dislikes',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Dislikes'));
    await tester.pumpAndSettle();

    expect(find.text('Most Dislikes'), findsOneWidget);
  });

  testWidgets('Topics are in correct order in "Most Dislikes" view',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Most Dislikes'));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final cardTexts = <String>[
      'topic with most dislikes',
      'topic with most views',
      'topic with most likes',
      'alphabetically first topic',
      'z topic',
      'topic with least views',
    ];

    for (var i = 0; i < 6; i++) {
      final cardTextFinder = find.descendant(
        of: cardFinder.at(i),
        matching: find.byType(Text),
      );

      expect(
        (cardTextFinder.first.evaluate().single.widget as Text).data,
        cardTexts[i],
      );
    }
  });

  // Test the analytics of the topics when a topic is selected
  testWidgets('Topic shows correct likes analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    // Tap on the topic with most likes
    await tester.tap(find.text('topic with most likes'));
    await tester.pumpAndSettle();

    // Check that the likes text is displayed
    expect(find.text('Likes'), findsOneWidget);

    // This topic only contains a single instance of 100 and that is the likes
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('Topic shows correct dislikes analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    // Tap on the topic with most dislikes
    await tester.tap(find.text('topic with most dislikes'));
    await tester.pumpAndSettle();

    // Check that the dislikes text is displayed
    expect(find.text('Dislikes'), findsOneWidget);

    // This topic only contains a single instance of 100 and that is the likes
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('Topic shows correct views analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    // Tap on the topic with most views
    await tester.tap(find.text('topic with most views'));
    await tester.pumpAndSettle();

    // Check that the views text is displayed
    expect(find.text('Views'), findsOneWidget);

    // This topic only contains a single instance of 100 and that is the dislikes
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('Topic shows correct date analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('topic with most views'));
    await tester.pumpAndSettle();

    // Check that the date text is displayed
    expect(find.text('Uploaded Date'), findsOneWidget);

    // Check that the date is displayed
    expect(find.text(DateFormat('dd-MM-yyyy').format(DateTime.now())),
        findsOneWidget);
  });

  testWidgets('Topic shows correct time analytics when topic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(analyticsTopicPageWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('topic with most views'));
    await tester.pumpAndSettle();

    // Check that the time text is displayed
    expect(find.text('Uploaded Time'), findsOneWidget);

    // Check that the time is displayed
    expect(
        find.text(DateFormat('HH:mm').format(DateTime.now())), findsOneWidget);
  });
}
