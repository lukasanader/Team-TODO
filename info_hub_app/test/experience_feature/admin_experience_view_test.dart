import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/view/experience_view/admin_experience/admin_experience_view.dart';
import 'package:info_hub_app/model/experience_models/experience_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late CollectionReference experienceCollectionRef;
  late Widget experienceViewWidget;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    experienceCollectionRef = firestore.collection('experiences');

    experienceCollectionRef.add({
      'title': 'Example 1',
      'description': 'Example experience',
      'userEmail': 'test@example.org',
      'verified': true,
      'userRoleType': 'Patient'
    });
    experienceCollectionRef.add({
      'title': 'Example 2',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': false,
      'userRoleType': 'Patient'
    });

    experienceViewWidget = MaterialApp(
      home: AdminExperienceView(
        firestore: firestore,
        auth: auth,
      ),
    );
  });



  testWidgets('Displays verified experiences', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    expect(find.text('Example 1'), findsOneWidget);
  });

  testWidgets('Displays unverified experiences', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unverify_navbar_button')));
    await tester.pumpAndSettle();

    expect(find.text('Example 2'), findsOneWidget);
  });

  testWidgets('Button can verify experience correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unverify_navbar_button')));
    await tester.pumpAndSettle();

    Finder checkButton = find.byIcon(Icons.check_circle_outline).first;

    await tester.ensureVisible(checkButton);
    await tester.tap(checkButton.first);
    await tester.pumpAndSettle();

    QuerySnapshot<Map<String, dynamic>> data = await firestore
        .collection('experiences')
        .where('title', isEqualTo: 'Example 2')
        .get();

    List<Experience> experienceList =
        List.from(data.docs.map((doc) => Experience.fromSnapshot(doc)));

    expect(experienceList[0].title, equals('Example 2'));
    expect(experienceList[0].verified, isTrue);
  });

  testWidgets('Button can unverify experience correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder checkButton = find.byIcon(Icons.highlight_off_outlined).first;

    await tester.ensureVisible(checkButton);
    await tester.tap(checkButton.first);
    await tester.pumpAndSettle();

    QuerySnapshot<Map<String, dynamic>> data = await firestore
        .collection('experiences')
        .where('title', isEqualTo: 'Example 1')
        .get();

    List<Experience> experienceList =
        List.from(data.docs.map((doc) => Experience.fromSnapshot(doc)));

    expect(experienceList[0].verified, isFalse);
  });

  testWidgets('Delete button removes an experience from verified list',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder deleteButton = find.byIcon(Icons.delete_outline).first;

    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Example 1'), findsNothing);
  });

  testWidgets('Cancel button does not remove an experience from verified list',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder deleteButton = find.byIcon(Icons.delete_outline).first;

    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Example 1'), findsOneWidget);
  });

  testWidgets('Delete button removes an experience from unverified list',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder deleteButton = find.byIcon(Icons.delete_outline).last;

    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Example 2'), findsNothing);
  });

  testWidgets(
      'Cancel button does not remove an experience from unverified list',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unverify_navbar_button')));
    await tester.pumpAndSettle();

    //experience should be present
    expect(find.text('Example 2'), findsOneWidget);

    Finder deleteButton = find.byIcon(Icons.delete_outline);

    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();


    //experience should still be present
    expect(find.text('Example 2'), findsOneWidget);
  });

  testWidgets(
      'Appbar help button displays a dialog with the correct information',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder helpButton = find.byIcon(Icons.help_outline);

    await tester.ensureVisible(helpButton);
    await tester.tap(helpButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.byWidget(experienceViewWidget), findsOneWidget);
  });

  testWidgets('There is padding between two experiences',
      (WidgetTester tester) async {

    experienceCollectionRef.add({
      'title': 'Example 3',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': true
    });

    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();


    expect(find.byKey(const ValueKey<String>('between_experience_padding')), findsWidgets);
  });


  testWidgets('Displays verified experiences filtered by patients correctly', (WidgetTester tester) async {
    experienceCollectionRef.add({
      'title': 'Parent experience',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': true,
      'userRoleType': 'Parent'
    });


    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    Finder dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_Patient'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //patient experience is displayed
    expect(find.text('Example 1'), findsOneWidget);

    //previous experience is no longer displayed
    expect(find.text('Parent experience'), findsNothing);
  });

  testWidgets('Displays verified experiences filtered by parents correctly', (WidgetTester tester) async {
    experienceCollectionRef.add({
      'title': 'Experience should only display with correct roletype',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': true,
      'userRoleType': 'Parent'
    });


    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    Finder dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_Parent'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //patient experience is displayed
    expect(find.text('Experience should only display with correct roletype'), findsOneWidget);

    //previous experience is no longer displayed
    expect(find.text('Example 1'), findsNothing);
  });


  testWidgets('Displays verified experiences filtered by healthcare professionals correctly', (WidgetTester tester) async {
    experienceCollectionRef.add({
      'title': 'Experience should only display with correct roletype',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': true,
      'userRoleType': 'Healthcare Professional'
    });


    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    Finder dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_Healthcare Professional'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //patient experience is displayed
    expect(find.text('Experience should only display with correct roletype'), findsOneWidget);

    //previous experience is no longer displayed
    expect(find.text('Example 1'), findsNothing);
  });


  testWidgets('Displays unverified experiences filtered by patients correctly', (WidgetTester tester) async {
    experienceCollectionRef.add({
      'title': 'Experience should only display with correct roletype',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': false,
      'userRoleType': 'Parent'
    });


    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unverify_navbar_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    Finder dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_Patient'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //experience not displayed
    expect(find.text('Experience should only display with correct roletype'), findsNothing);

    //previous experience is no longer displayed
    expect(find.text('Example 2'), findsOneWidget);
  });

  testWidgets('Displays unverified experiences filtered by parents correctly', (WidgetTester tester) async {
    experienceCollectionRef.add({
      'title': 'Experience should only display with correct roletype',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': false,
      'userRoleType': 'Parent'
    });


    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unverify_navbar_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    Finder dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_Parent'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //patient experience is displayed
    expect(find.text('Experience should only display with correct roletype'), findsOneWidget);

    //previous experience is no longer displayed
    expect(find.text('Example 2'), findsNothing);
  });


  testWidgets('Displays unverified experiences filtered by healthcare professionals correctly', (WidgetTester tester) async {
    experienceCollectionRef.add({
      'title': 'Experience should only display with correct roletype',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': false,
      'userRoleType': 'Healthcare Professional'
    });


    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unverify_navbar_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    Finder dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_Healthcare Professional'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //patient experience is displayed
    expect(find.text('Experience should only display with correct roletype'), findsOneWidget);

    //previous experience is no longer displayed
    expect(find.text('Example 2'), findsNothing);
  });


  testWidgets('Changing filters works in verified', (WidgetTester tester) async {
    experienceCollectionRef.add({
      'title': 'Experience should only display with correct roletype',
      'description': 'Example experience',
      'userEmail': 'test2@example.org',
      'verified': true,
      'userRoleType': 'Parent'
    });




    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    //shows all
    expect(find.text('Experience should only display with correct roletype'), findsOneWidget);
    expect(find.text('Example 1'), findsOneWidget);


    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    Finder dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_Patient'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //Filters by patient
    expect(find.text('Experience should only display with correct roletype'), findsNothing);
    expect(find.text('Example 1'), findsOneWidget);

    //switch back to all
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    dropDownOption = find.byKey(const ValueKey<String>('dropdown_menu_All'));

    await tester.ensureVisible(dropDownOption);
    await tester.pumpAndSettle();

    await tester.tap(dropDownOption, warnIfMissed: false);
    await tester.pumpAndSettle();

    //shows all experiences again
    expect(find.text('Experience should only display with correct roletype'), findsOneWidget);
    expect(find.text('Example 1'), findsOneWidget);


  });

}
