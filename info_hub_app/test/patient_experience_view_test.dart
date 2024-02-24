import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';
import 'package:info_hub_app/patient_experience/patient_experience_view.dart';


void main() {
  late FakeFirebaseFirestore firestore;
  late CollectionReference topicsCollectionRef;
  late Widget experienceViewWidget;


  setUp(() {
    firestore = FakeFirebaseFirestore();
    topicsCollectionRef = firestore.collection('experiences');

    topicsCollectionRef.add({
      'title' : 'Example 1',
      'description' : 'Example experience',
      'verified' : true
    });
    topicsCollectionRef.add({
      'title' : 'Example 2',
      'description' : 'Example experience',
      'verified' : false
    });

    experienceViewWidget = MaterialApp(
      home: ExperienceView(firestore: firestore),
    );

  });

  testWidgets('The verified experiences are being displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(1));



    expect(find.text('Example 1'), findsOneWidget);
  });

  testWidgets('Share experience works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showPostDialog method
    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Verify that the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Enter text into the TextField
    await tester.enterText(find.byType(TextField).first, 'Test experience');

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await firestore.collection("experiences").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents = querySnapshot.docs;
    

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Test experience'
      ),
      isTrue);

    expect(find.byType(AlertDialog), findsNothing);
  });
}

