import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/login/login_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/reset_password/reset_password.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

void main() {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  final storage = MockFirebaseStorage();
  final themeManager = ThemeManager();
  testWidgets('test if login text exists', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    expect(find.text('Please fill in the login details.'), findsOneWidget);
  });

  testWidgets('test if email textfield exists', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test');
    expect(find.text('test'), findsOneWidget);
  });
  testWidgets('test if password textfield exists', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(passwordField, 'test');
    expect(find.text('test'), findsOneWidget);
  });

  testWidgets('test if log in validation works', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test');
    await test.enterText(passwordField, 'test');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Email or password is incorrect. Please try again'),
        findsNothing);
  });

  testWidgets('test if log in works on a valid user',
      (WidgetTester test) async {
    await auth.createUserWithEmailAndPassword(
        email: 'gamer@gmail.com', password: 'G@mer123');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'gamer@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'gamer@gmail.com');
    await test.enterText(passwordField, 'G@mer123');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('test if log in works on a valid admin',
      (WidgetTester test) async {
    await auth.createUserWithEmailAndPassword(
        email: 'admin@gmail.com', password: 'Admin123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'admin@gmail.com');
    await test.enterText(passwordField, 'Admin123!');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.byType(AdminHomepage), findsOneWidget);
  });

  testWidgets('test if stops when email is empty', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(passwordField, 'test');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets('test if stops when password is empty',
      (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('test if stops when both are empty', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('test if user forgets password', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
      firestore: firestore,
      auth: auth,
      storage: storage,
      themeManager: themeManager,
    )));
    await test.pumpAndSettle();

    await test.tap(find.text('Forgot Password?'));
    await test.pumpAndSettle();

    expect(find.byType(ResetPassword), findsOne);
  });

  testWidgets('test if show/hide password switches between both options', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(home: LoginScreen(firestore: firestore, auth: auth,storage: storage,)));
    await test.pumpAndSettle();

    final showHideButton = find.text('Show');
    await test.tap(showHideButton);
    await test.pumpAndSettle();
    expect(find.text('Hide'), findsOneWidget);
  });

  testWidgets('test if show/hide password works', (WidgetTester test) async{
    await test.pumpWidget(MaterialApp(home: LoginScreen(firestore: firestore, auth: auth,storage: storage,)));
    await test.pumpAndSettle();

    final showHideButton = find.ancestor(
      of: find.text('Show'),
      matching: find.byType(ElevatedButton),
    );

    final passwordfield = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );

    await test.enterText(passwordfield, 'test');
    await test.tap(showHideButton);
    await test.pumpAndSettle();
    expect(find.text('test'), findsOneWidget);
    
  });
}