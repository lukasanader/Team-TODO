import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/home_page.dart';
import 'package:info_hub_app/screens/registration_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
void main() {
  
  testWidgets('Register button is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: HomePage(firestore: firestore,auth:auth)));
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Login button is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: HomePage(firestore: firestore,auth:auth)));
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Image is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: HomePage(firestore: firestore,auth:auth)));
    expect(find.image(const AssetImage('assets/base_image.png')), findsOneWidget); 
  });

  testWidgets('Team text is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: HomePage(firestore: firestore,auth:auth)));
    expect(find.text('Team TODO'), findsOneWidget);
  });

  testWidgets('Register button press leads to register screen', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(firestore: firestore,auth: auth),
        ),
    );

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.byType(RegistrationScreen), findsOneWidget);
  });

  // testWidgets('Login button press leads to login screen', (WidgetTester tester) async {
  //   final firestore = FakeFirebaseFirestore();
  //   final auth = MockFirebaseAuth();
    
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: HomePage(firestore: firestore,auth: auth),
  //       ),
  //   );

  //   await tester.tap(find.text('Login'));
  //   await tester.pumpAndSettle();
  //   expect(find.byType(LoginScreen), findsOneWidget);
  // });

}
