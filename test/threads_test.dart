import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/thread_screens/thread_app.dart';
import 'package:info_hub_app/thread_screens/custom_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();

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

    expect(find.byType(CustomCard), findsNWidgets(2));
  });

  testWidgets('CustomCard allows editing of a thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    final editButton = find.byIcon(FontAwesomeIcons.edit).first;
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('Author')), 'Edited Author');
    await tester.enterText(find.byKey(const Key('Title')), 'Edited Title');
    await tester.enterText(
        find.byKey(const Key('Description')), 'Edited description');

    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(find.text('Edited Title'), findsOneWidget);
  });

  testWidgets('ThreadApp allows users to add a new thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('Author')), 'New Author');
    await tester.enterText(find.byKey(const Key('Title')), 'New Thread Title');
    await tester.enterText(
        find.byKey(const Key('Description')), 'New thread description');

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomCard), findsNWidgets(3));
  });

  testWidgets('CustomCard allows deletion of a thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ThreadApp(firestore: firestore)));
    await tester.pumpAndSettle();

    expect(find.byType(CustomCard), findsNWidgets(2));

    final deleteButton = find.byIcon(FontAwesomeIcons.trashAlt).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byType(CustomCard), findsNWidgets(1));
  });
}
