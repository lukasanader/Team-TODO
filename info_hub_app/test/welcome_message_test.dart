import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/welcome_message/welcome_message.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/helpers/base.dart';

void main() {
  testWidgets('Test if Welcome Message is present',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
        home: WelcomePage(
            firestore: firestore, storage: storage, auth: auth)));
    expect(
        find.text('Welcome to Info Hub App!'), findsOneWidget);
  });

  testWidgets('Test if how to use this app text is present', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  final storage = MockFirebaseStorage();

  await tester.pumpWidget(MaterialApp(
    home: WelcomePage(
      firestore: firestore,
      storage: storage,
      auth: auth,
    ),
  ));

  expect(find.text('How to use this app'), findsOneWidget);
});

  testWidgets('Test if General ExpansionTile is present', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  final storage = MockFirebaseStorage();

  await tester.pumpWidget(MaterialApp(
    home: WelcomePage(
      firestore: firestore,
      storage: storage,
      auth: auth,
    ),
  ));

  expect(find.text('General'), findsOneWidget);
});

      testWidgets(
  'Test if description in General ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

    final generalExpansionTileFinder = find.byKey(const Key('general_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    expect(find.text("This is a information hub app that allows you to view and share information on matters regarding living with liver issues."), findsOneWidget);
  },
);

testWidgets('Test if Guide ExpansionTile is present', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  final storage = MockFirebaseStorage();

  await tester.pumpWidget(MaterialApp(
    home: WelcomePage(
      firestore: firestore,
      storage: storage,
      auth: auth,
    ),
  ));

  expect(find.text('Guide'), findsOneWidget);
});

testWidgets('Test if FAQs ExpansionTile is present', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  final storage = MockFirebaseStorage();

  await tester.pumpWidget(MaterialApp(
    home: WelcomePage(
      firestore: firestore,
      storage: storage,
      auth: auth,
    ),
  ));

  expect(find.text('FAQs'), findsOneWidget);
});

  testWidgets('Test if button navigates to Home Page',(WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
        home: WelcomePage(
            firestore: firestore, storage: storage, auth: auth)));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(Base), findsOneWidget);
  });

      testWidgets(
  'Test if "Topics" option in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

    
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

   
    expect(find.text('Topics'), findsOneWidget);
  },
);
        testWidgets(
  'Test if "Topics" description in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

    
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    
    expect(find.text('"Topics" is a section within the app that provides users with information on various aspects related to liver diseases. Each topic delves into specific issues, concerns, and aspects of liver diseases, offering users a general understanding of the subject matter. Users can explore different topics to gain insights into symptoms, treatments, lifestyle changes, and other relevant information pertinent to managing liver diseases effectively.'), findsOneWidget);
  },
);

    testWidgets(
  'Test if "Submit Questions" option in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

    
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    
    expect(find.text('Submit Questions'), findsOneWidget);
  },
);

      testWidgets(
  'Test if "Submit Questions" description in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

    
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    
    expect(find.text('Questions submitted will be carefully reviewed by Healthcare Professionals and answered privately.'), findsOneWidget);
  },
);

  testWidgets(
  'Test if "Patient Experience" option in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

   
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    // Tap to expand the General ExpansionTile
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    
    expect(find.text('Patient Experience'), findsOneWidget);
  },
);

    testWidgets(
  'Test if "Patient Experience" description in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

   
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    // Tap to expand the General ExpansionTile
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    
    expect(find.text('Patient Experiences have been carefully reviewed by Healthcare Professionals and are shared to provide insights and support to other patients and caregivers.'), findsOneWidget);
  },
);

  testWidgets(
  'Test if "Webinars" option in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));

    
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    // Tap to expand the General ExpansionTile
    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    
    expect(find.text('Webinar'), findsOneWidget);
  },
);

      testWidgets(
  'Test if "Webinars" description in Guide ExpansionTile dropdown is displayed',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();

    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        firestore: firestore,
        storage: storage,
        auth: auth,
      ),
    ));
    final generalExpansionTileFinder = find.byKey(const Key('guide_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();

    expect(find.text('Webinars are live sessions conducted by Healthcare Professionals to provide insights and support to patients and caregivers. Users can view upcoming and past webinars.'), findsOneWidget);
  },
);

}






