import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/helpers/base.dart';
import 'package:info_hub_app/welcome_message/welcome_message.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

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

    testWidgets('FAQs first question should be displayed', 
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
    final generalExpansionTileFinder = find.byKey(const Key('faq_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('What are the common symptoms of liver disease?'));
      expect(find.text('What are the common symptoms of liver disease?'), findsOneWidget);
  });

  testWidgets('FAQs first answer should be displayed', 
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
    final generalExpansionTileFinder = find.byKey(const Key('faq_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();
    expect(find.text('Common symptoms of liver disease include jaundice, abdominal pain and swelling, nausea, vomiting, fatigue, and dark urine. However, symptoms may vary depending on the specific liver condition and its severity.'), findsOneWidget);
  });

    testWidgets('FAQs second question should be displayed', 
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
    final generalExpansionTileFinder = find.byKey(const Key('faq_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('How is liver disease diagnosed?'));
    expect(find.text('How is liver disease diagnosed?'), findsOneWidget);
  });

    testWidgets('FAQs second answer should be displayed',
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
    final generalExpansionTileFinder = find.byKey(const Key('faq_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();
    expect(find.text('Liver disease is diagnosed through a combination of medical history, physical examination, blood tests, imaging studies (such as ultrasound or MRI), and sometimes liver biopsy. These tests help determine the cause, severity, and extent of liver damage.'), findsOneWidget);
  });

    testWidgets('FAQs third question should be displayed',
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

    final generalExpansionTileFinder = find.byKey(const Key('faq_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();
    expect(find.text('What are some lifestyle changes recommended for managing liver disease?'), findsOneWidget);
  });

    testWidgets('FAQs third answer should be displayed', 
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
    final generalExpansionTileFinder = find.byKey(const Key('faq_expansion_tile'));
    expect(generalExpansionTileFinder, findsOneWidget);

    await tester.tap(generalExpansionTileFinder);
    await tester.pumpAndSettle();
    expect(find.text( "Lifestyle changes that may help manage liver disease include maintaining a healthy diet low in fat and processed foods, avoiding alcohol and tobacco, exercising regularly, managing stress, and following prescribed treatment plans. It's essential to consult healthcare professionals."), findsOneWidget);
  });

  testWidgets('WelcomePage "Get Started" button test if it brings you to the Home Page', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        auth: auth,
        firestore: firestore,
        storage: storage,
      ),
    ));
    await tester.ensureVisible(find.textContaining('Get Started'));
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(Base), findsOneWidget);
  });

    testWidgets('WelcomePage "Get Started" button is visible', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
      home: WelcomePage(
        auth: auth,
        firestore: firestore,
        storage: storage,
      ),
    ));

    await tester.ensureVisible(find.textContaining('Get Started'));
    expect(find.text('Get Started'), findsOneWidget);
    });

}







