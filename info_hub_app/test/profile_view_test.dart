import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/change_profile/change_profile.dart';

void main() {
  testWidgets('Test if profile view displays first name', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
    final fakeUserId = auth.currentUser!.uid;
    final fakeUser = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'profileview@example.org',
      'roleType' : 'Patient',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

    await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
    await tester.pumpAndSettle(); 

    expect(find.text('John'), findsOneWidget);
  });

  testWidgets('Test if profile view displays last name', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
    final fakeUserId = auth.currentUser!.uid;
    final fakeUser = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'profileview@example.org',
      'roleType' : 'Patient',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

    await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
    await tester.pumpAndSettle(); 

    expect(find.text('Doe'), findsOneWidget);
  });

  testWidgets('Test if profile view displays email', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
    final fakeUserId = auth.currentUser!.uid;
    final fakeUser = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'profileview@example.org',
      'roleType' : 'Patient',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

    await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
    await tester.pumpAndSettle(); 

    expect(find.text('profileview@example.org'), findsOneWidget);
  });

    testWidgets('Test if profile view displays roletype', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
     auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
    final fakeUserId = auth.currentUser!.uid;
    final fakeUser = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'profileview@example.org',
      'roleType' : 'Patient',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);
    await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
    await tester.pumpAndSettle(); 

    expect(find.text('Patient'), findsOneWidget);
  });

  testWidgets('Test if default profile photo is the placeholder', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
  final fakeUserId = auth.currentUser!.uid;
  final fakeUser = {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'profileview@example.org',
    'roleType' : 'Patient',
  };
  await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

  await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
  await tester.pumpAndSettle(); 

  expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
  // Verify that the AssetImage matches the default profile photo
  final CircleAvatar circleAvatar = tester.widget(find.byType(CircleAvatar));
  final AssetImage assetImage = circleAvatar.backgroundImage as AssetImage;
  expect(assetImage.assetName, 'assets/default_profile_photo.png');
});

  testWidgets('Test if default profile photo is the placeholder', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
  final fakeUserId = auth.currentUser!.uid;
  final fakeUser = {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'profileview@example.org',
    'roleType' : 'Patient',
  };
  await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

  await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
  await tester.pumpAndSettle(); 

  // Verify that the CircleAvatar widget with AssetImage is found
  expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);

  // Tap on the CircleAvatar to trigger the dialog
  await tester.tap(find.byType(CircleAvatar));
  await tester.pumpAndSettle();

  // Verify that the 'Dog' text appears in the dialog
  expect(find.text('Dog'), findsOneWidget);
});

  testWidgets('Test if default profile photo is the placeholder', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
  final fakeUserId = auth.currentUser!.uid;
  final fakeUser = {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'profileview@example.org',
    'roleType' : 'Patient',
  };
  await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

  await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
  await tester.pumpAndSettle(); 

  // Verify that the CircleAvatar widget with AssetImage is found
  expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);

  // Tap on the CircleAvatar to trigger the dialog
  await tester.tap(find.byType(CircleAvatar));
  await tester.pumpAndSettle();

  // Verify that the 'Dog' text appears in the dialog
  expect(find.text('Penguin'), findsOneWidget);
});

  testWidgets('Test if default profile photo is the placeholder', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
  final fakeUserId = auth.currentUser!.uid;
  final fakeUser = {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'profileview@example.org',
    'roleType' : 'Patient',
  };
  await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

  await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
  await tester.pumpAndSettle(); 

  // Verify that the CircleAvatar widget with AssetImage is found
  expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);

  // Tap on the CircleAvatar to trigger the dialog
  await tester.tap(find.byType(CircleAvatar));
  await tester.pumpAndSettle();

  // Verify that the 'Dog' text appears in the dialog
  expect(find.text('Penguin'), findsOneWidget);
});

  testWidgets('Test if default profile photo is the placeholder', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
  final fakeUserId = auth.currentUser!.uid;
  final fakeUser = {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'profileview@example.org',
    'roleType' : 'Patient',
  };
  await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

  await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
  await tester.pumpAndSettle(); 

  // Verify that the CircleAvatar widget with AssetImage is found
  expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);

  // Tap on the CircleAvatar to trigger the dialog
  await tester.tap(find.byType(CircleAvatar));
  await tester.pumpAndSettle();

  // Verify that the 'Dog' text appears in the dialog
  expect(find.text('Walrus'), findsOneWidget);
});

testWidgets('Test if tapping Change Profile button navigates to ChangeProfile page', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  auth.createUserWithEmailAndPassword(email: 'profileview@example.org', password: 'Password123!');
  final fakeUserId = auth.currentUser!.uid;
  final fakeUser = {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'profileview@example.org',
    'roleType' : 'Patient',
  };
  await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

  await tester.pumpWidget(MaterialApp(home: ProfileView(firestore: firestore, auth: auth)));
  await tester.pumpAndSettle(); 

  // Verify that the "Change Profile" button is present and ensure it's visible
  expect(find.text('Change Profile'), findsOneWidget);
  await tester.ensureVisible(find.text('Change Profile'));

  // Tap the "Change Profile" button
  await tester.tap(find.text('Change Profile'));
  await tester.pumpAndSettle();

  // Verify that the navigation occurred
  expect(find.byType(ChangeProfile), findsOneWidget);
});

}

