import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/threads/thread_app.dart';
import 'package:info_hub_app/threads/custom_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    // Seed the database with initial data
    firestore.collection('thread').add({
      'name': 'John Doe',
      'title': 'First Thread',
      'description': 'This is the first test thread',
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
    firestore.collection('thread').add({
      'name': 'Jane Smith',
      'title': 'Second Thread',
      'description': 'This is the second test thread',
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });
  });

  testWidgets('ThreadApp displays threads from Firestore',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    // Verify that threads are displayed
    expect(find.byType(CustomCard), findsNWidgets(2));
  });

  /* testWidgets('CustomCard allows editing of a thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    // Find the edit button for the first thread and tap it
    final editButton = find.byIcon(FontAwesomeIcons.edit).first;
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Fill out the edit form
    await tester.enterText(find.byType(TextField).at(0), 'Edited Author');
    await tester.enterText(find.byType(TextField).at(1), 'Edited Title');
    await tester.enterText(find.byType(TextField).at(2), 'Edited Description');

    // Tap the "Update" button
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    // Verify the update by checking if "Edited Title" is now displayed
    expect(find.text('Edited Title'), findsOneWidget);
  });

  testWidgets('CustomCard allows deletion of a thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    // Initial count check
    expect(find.byType(CustomCard), findsNWidgets(2));

    // Find the delete button for the first thread and tap it
    final deleteButton = find.byIcon(FontAwesomeIcons.trashAlt).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify the thread was deleted by checking the count
    expect(find.byType(CustomCard), findsNWidgets(1));
  });

*/

  testWidgets('ThreadApp allows users to add a new thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    // Tap on the FloatingActionButton to add a new thread
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill out the form in the dialog
    await tester.enterText(find.byKey(const Key('Author')), 'New Author');
    await tester.enterText(find.byKey(const Key('Title')), 'New Thread Title');
    await tester.enterText(
        find.byKey(const Key('Description')), 'New thread description');

    // Submit the form
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify that a new thread has been added
    // This expects the thread count to increase by one
    expect(find.byType(CustomCard), findsNWidgets(3));
  });

  testWidgets('CustomCard allows deletion of a thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    // Initial count check
    expect(find.byType(CustomCard), findsNWidgets(2));

    // Find the delete button for the first thread and tap it

    final deleteButton = find.byIcon(FontAwesomeIcons.trashAlt).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify the thread was deleted by checking the count
    expect(find.byType(CustomCard), findsNWidgets(1));
  });
}
