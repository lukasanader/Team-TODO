import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/change_profile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/screens/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() {
  late FirebaseFirestore firestore;
  late Widget changeProfileWidget;
  late FirebaseAuth auth;

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = FirebaseAuth.instance;
    changeProfileWidget = MaterialApp(
      home: ChangeProfile(firestore: firestore, auth: auth),
    );
  });

  testWidgets('Change profile test', (WidgetTester tester) async {
    await tester.pumpWidget(changeProfileWidget);

    // Simulate user input
    await tester.enterText(find.byType(TextField).at(0), 'John');
    await tester.enterText(find.byType(TextField).at(1), 'Doe');
    await tester.enterText(find.byType(TextField).at(2), 'NewPassword123!');
    await tester.enterText(find.byType(TextField).at(3), 'NewPassword123!');

    // Tap the save changes button
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify that changes were saved successfully
    expect(find.text('Changes saved'), findsOneWidget);
  });
}


