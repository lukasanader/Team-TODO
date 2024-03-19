import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/change_profile/change_profile.dart';
import 'package:info_hub_app/profile_view/profile_view_controller.dart';

void main() {

        testWidgets('Test if Your Profile title is visible at the top of the page', (WidgetTester tester) async {
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
    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth ))));
    await tester.pumpAndSettle(); 

    expect(find.text('Profile'), findsOneWidget);
  });

      testWidgets('Test if Your Profile title is visible', (WidgetTester tester) async {
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
    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.text('Your Profile'), findsOneWidget);
  });
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.text('John'), findsOneWidget);
  });

    testWidgets('Test if Last Name title is visible', (WidgetTester tester) async {
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.text('Last Name'), findsOneWidget);
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
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
    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.text('Patient'), findsOneWidget);
  });

    testWidgets('Test if Role Type title is visible', (WidgetTester tester) async {
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
    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.text('Role Type'), findsOneWidget);
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
    final CircleAvatar circleAvatar = tester.widget(find.byType(CircleAvatar));
    final AssetImage assetImage = circleAvatar.backgroundImage as AssetImage;
    expect(assetImage.assetName, 'assets/default_profile_photo.png');
  });

    testWidgets('Test if the option Dog is there', (WidgetTester tester) async {
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);

    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Dog'), findsOneWidget);
  });

  testWidgets('Test if the option Penguin is there', (WidgetTester tester) async {
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

  await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
  await tester.pumpAndSettle(); 

  expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);

  await tester.tap(find.byType(CircleAvatar));
  await tester.pumpAndSettle();

  expect(find.text('Penguin'), findsOneWidget);
});


  testWidgets('Test if the option Walrus is there', (WidgetTester tester) async {
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

  await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
  await tester.pumpAndSettle(); 


  expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);

  
  await tester.tap(find.byType(CircleAvatar));
  await tester.pumpAndSettle();

 
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

  await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
  await tester.pumpAndSettle(); 


  expect(find.text('Change Profile'), findsOneWidget);
  await tester.ensureVisible(find.text('Change Profile'));

 
  await tester.tap(find.text('Change Profile'));
  await tester.pumpAndSettle();

 
  expect(find.byType(ChangeProfile), findsOneWidget);
});

  testWidgets('Test if updating profile photo changes the displayed photo to a Dog', (WidgetTester tester) async {
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    
    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
    
   
    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

   
    await tester.tap(find.text('Dog'));
    await tester.pumpAndSettle();

    
    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
    final CircleAvatar circleAvatarAfter = tester.widget(find.byType(CircleAvatar));
    final AssetImage assetImageAfter = circleAvatarAfter.backgroundImage as AssetImage;
    final String updatedProfilePhoto = assetImageAfter.assetName;
    expect(updatedProfilePhoto, 'assets/profile_photo_1.png'); 

    
  });

    testWidgets('Test if updating profile photo changes the displayed photo to a Walrus', (WidgetTester tester) async {
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

   
    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
    
    // Tap on the CircleAvatar to trigger the dialog
    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    
    await tester.tap(find.text('Walrus'));
    await tester.pumpAndSettle();

    
    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
    final CircleAvatar circleAvatarAfter = tester.widget(find.byType(CircleAvatar));
    final AssetImage assetImageAfter = circleAvatarAfter.backgroundImage as AssetImage;
    final String updatedProfilePhoto = assetImageAfter.assetName;
    expect(updatedProfilePhoto, 'assets/profile_photo_2.png'); 

    
  });

    testWidgets('Test if updating profile photo changes the displayed photo to a Penguin', (WidgetTester tester) async {
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

    await tester.pumpWidget(MaterialApp(home: ProfileView(controller: ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle(); 

    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
    
    await tester.tap(find.byType(CircleAvatar));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Penguin'));
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((widget) => widget is CircleAvatar && widget.backgroundImage is AssetImage), findsOneWidget);
    final CircleAvatar circleAvatarAfter = tester.widget(find.byType(CircleAvatar));
    final AssetImage assetImageAfter = circleAvatarAfter.backgroundImage as AssetImage;
    final String updatedProfilePhoto = assetImageAfter.assetName;
    expect(updatedProfilePhoto, 'assets/profile_photo_3.png'); // Fix: include 'assets/' prefix

  });
}


