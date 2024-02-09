import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/holder/discovery_view.dart';


void main() {
  late FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  late CollectionReference topicsCollectionRef;
  late Widget discoveryViewWidget;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    topicsCollectionRef = firestore.collection('topics');

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

    discoveryViewWidget = MaterialApp(
      home: DiscoveryView(firestore: firestore),
    );

  });


  testWidgets('DiscoveryView has appbar with back button, search bar and search icon', (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);

    expect(find.widgetWithIcon(IconButton, Icons.arrow_back), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.search), findsOneWidget);

  });

  /*
  testWidgets('DiscoveryView back button pops user out of search screen', (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);

    expect(find.byWidget(discoveryViewWidget), findsOneWidget);

    final backButton = find.widgetWithIcon(IconButton, Icons.arrow_back);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byWidget(discoveryViewWidget), findsNothing);

  });
  */

  testWidgets('DiscoveryView search button does nothing (is null)', (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);

    final searchButton = find.widgetWithIcon(IconButton, Icons.search);

    await tester.tap(searchButton);
    await tester.pump();

    expect(find.byWidget(discoveryViewWidget), findsOneWidget);

  });

  testWidgets('DiscoveryView will display topics based on search accurately', (WidgetTester tester) async {
    topicsCollectionRef.add({
      'title': 'Multiple will show',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
    });
    topicsCollectionRef.add({
      'title': 'Multiple will show 2',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
    });
    topicsCollectionRef.add({
      'title': 'Multiple will show 3',
      'description': 'this is a test',
      'articleLink': '',
      'videoUrl': '',
    });


    await tester.pumpWidget(discoveryViewWidget);

    final searchTextField = find.byType(TextField);

    await tester.enterText(searchTextField, 'multiple');
    await tester.pump();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));

    final textFinders = find.byType(Text);

    expect((textFinders.first.evaluate().single.widget as Text).data, 'Multiple will show');
    expect((textFinders.at(1).evaluate().single.widget as Text).data, 'Multiple will show 2');
    expect((textFinders.at(2).evaluate().single.widget as Text).data, 'Multiple will show 3');
  });



  testWidgets('DiscoveryView will display "Sorry there are no topics for this!" if no existing topic exists', (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);

    final searchTextField = find.byType(TextField);

    await tester.enterText(searchTextField, 'There is not test with this name');
    await tester.pump();

    expect(find.text('Sorry there are no topics for this!'), findsOneWidget);
  });



  testWidgets('DiscoveryView topics are in alphabetical order', (WidgetTester tester) async {

    await tester.pumpWidget(discoveryViewWidget);
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
