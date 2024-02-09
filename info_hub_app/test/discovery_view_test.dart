import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/holder/discovery_view.dart';


void main() {
  testWidgets('DiscoveryView topics are in alphabetical order', (WidgetTester tester) async {

    final firestore = FakeFirebaseFirestore();
    CollectionReference topicsCollectionRef = firestore.collection('topics');

    topicsCollectionRef.add({
      'title': 'B test',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
    });
    topicsCollectionRef.add({
      'title': 'D test',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
    });
    topicsCollectionRef.add({
      'title': 'A test',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
    });
    topicsCollectionRef.add({
      'title': 'C test',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryView(firestore: firestore),
      ),
    );
    await tester.pumpAndSettle();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(4));

    final textFinders = find.byType(Text);
    // Check the order of card titles
    expect((textFinders.first.evaluate().single.widget as Text).data, 'A test');
    expect((textFinders.at(1).evaluate().single.widget as Text).data, 'B test');
    expect((textFinders.at(2).evaluate().single.widget as Text).data, 'C test');
    expect((textFinders.at(3).evaluate().single.widget as Text).data, 'D test');
  });

  

}

