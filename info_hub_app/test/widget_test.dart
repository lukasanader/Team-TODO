// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:info_hub_app/main.dart';

void main() {
  /*
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final firestore = FakeFirebaseFirestore();
    await tester.pumpWidget(MyApp(firestore: firestore));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
  testWidgets('Show Post Dialog Test', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(firestore: firestore,)); // Replace MyApp with the name of your app widget.
    // Trigger the _showPostDialog method
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // Verify that the AlertDialog is displayed
    //expect(find.byType(AlertDialog), findsOneWidget);
    // Enter text into the TextField
    await tester.enterText(find.byType(TextField), 'Test question');
    // Tap the Submit button
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await firestore.collection("questions").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
      querySnapshot.docs;
    // Check if the collection contains a document with the expected question
    expect(
      documents.any(
        (doc) => doc.data()?['question'] == 'Test question',
      ),
      isTrue,
    );
    // Verify that the dialog is closed
    expect(find.byType(AlertDialog), findsNothing);
  });
  */
}
