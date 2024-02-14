import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/create_topic.dart';

void main() {
  testWidgets('Topic with title and description save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Test title',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Test description',
      ),
      isTrue,
    );
  });

  testWidgets('Topic with no title does not save', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic no description does not save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic inavlid article link does not save',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.enterText(find.byKey(const Key('linkField')), 'invalidLink');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.isEmpty, isTrue);
  });

  testWidgets('Topic with valid article link saves',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');

    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.enterText(find.byKey(const Key('linkField')),
        'https://pub.dev/packages?q=cloud_firestore_mocks');

    await tester.tap(find.byType(OutlinedButton));

    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("topics").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
      documents.any(
        (doc) => doc.data()?['title'] == 'Test title',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) => doc.data()?['description'] == 'Test description',
      ),
      isTrue,
    );

    expect(
      documents.any(
        (doc) =>
            doc.data()?['articleLink'] ==
            'https://pub.dev/packages?q=cloud_firestore_mocks',
      ),
      isTrue,
    );
  });

  testWidgets('Test all form fields are present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    expect(find.text('Title *'), findsOneWidget);

    expect(find.text('Description *'), findsOneWidget);

    expect(find.text('Link article'), findsOneWidget);

    expect(find.text('Upload a video'), findsOneWidget);
  });

  testWidgets('Navigates back after submitting form',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MaterialApp(
      home: CreateTopicScreen(
        firestore: firestore,
      ),
    ));

    await tester.enterText(find.byKey(const Key('titleField')), 'Test title');
    await tester.enterText(
        find.byKey(const Key('descField')), 'Test description');

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTopicScreen), findsNothing);
  });
}
