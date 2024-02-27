import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/patient_experience/admin_experience_view.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CollectionReference topicsCollectionRef;
  late Widget experienceViewWidget;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    topicsCollectionRef = firestore.collection('experiences');

    topicsCollectionRef.add({
      'title': 'Example 1',
      'description': 'Example experience',
      'verified': true
    });
    topicsCollectionRef.add({
      'title': 'Example 2',
      'description': 'Example experience',
      'verified': false
    });

    experienceViewWidget = MaterialApp(
      home: AdminExperienceView(firestore: firestore),
    );
  });

  testWidgets('There are two list views', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsNWidgets(2));
  });

  testWidgets('Displays both verified and unverified experiences',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(2));

    expect(find.text('Example 1'), findsOneWidget);
    expect(find.text('Example 2'), findsOneWidget);
  });

  testWidgets('Button can verify experience correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder checkButton = find.byIcon(Icons.check);
    await tester.tap(checkButton.last);
    await tester.pumpAndSettle();

    QuerySnapshot<Map<String, dynamic>> data = await firestore
        .collection('experiences')
        .where('title', isEqualTo: 'Example 2')
        .get();

    List<Experience> experienceList =
        List.from(data.docs.map((doc) => Experience.fromSnapshot(doc)));

    expect(experienceList[0].title, equals('Example 2'));
    expect(experienceList[0].verified, isTrue);
  });

  testWidgets('Button can unverify experience correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder checkButton = find.byIcon(Icons.check);
    await tester.tap(checkButton.first);
    await tester.pumpAndSettle();

    QuerySnapshot<Map<String, dynamic>> data = await firestore
        .collection('experiences')
        .where('title', isEqualTo: 'Example 1')
        .get();

    List<Experience> experienceList =
        List.from(data.docs.map((doc) => Experience.fromSnapshot(doc)));

    expect(experienceList[0].verified, isFalse);
  });

  testWidgets('Share experience works', (WidgetTester tester) async {});
}
