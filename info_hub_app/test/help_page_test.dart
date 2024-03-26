import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/settings/help_page_view.dart';


void main() {
  testWidgets('App bar title should be "Help Page"',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));
    expect(find.text('Help Page'), findsOneWidget);
  });

  testWidgets('General section title should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));
    expect(find.text('General'), findsOneWidget);
  });

  testWidgets('General description should be displayed',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('General'));
    await tester.pump();

    expect(
        find.text(
            "This is an information hub app that allows you to view and share information on matters regarding living with liver issues."),
        findsOneWidget);
  });

  testWidgets('Guide section title should be displayed',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(find.text('Guide'), findsOneWidget);
  });

  testWidgets('Topics tile should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(find.text('Topics'), findsOneWidget);
  });

  testWidgets('Topics description should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(
        find.text(
            '"Topics" is a section within the app that provides users with information on various aspects related to liver diseases. Each topic delves into specific issues, concerns, and aspects of liver diseases, offering users a general understanding of the subject matter. Users can explore different topics to gain insights into symptoms, treatments, lifestyle changes, and other relevant information pertinent to managing liver diseases effectively.'),
        findsOneWidget);
  });

  testWidgets('Submit Questions tile should be displayed',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(find.text('Submit Questions'), findsOneWidget);
  });

  testWidgets('Submit Questions description should be displayed',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(
        find.text(
            'Questions submitted will be carefully reviewed by Healthcare Professionals and answered privately.'),
        findsOneWidget);
  });

  testWidgets('Patient Experience tile should be displayed',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(find.text('Patient Experience'), findsOneWidget);
  });

  testWidgets('Patient Experience description should be displayed',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(
        find.text(
            'Patient Experiences have been carefully reviewed by Healthcare Professionals and are shared to provide insights and support to other patients and caregivers.'),
        findsOneWidget);
  });

  testWidgets('Webinar tile should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(find.text('Webinar'), findsOneWidget);
  });

  testWidgets('Webinar description should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('Guide'));
    await tester.pump();

    expect(
        find.text(
            'Webinars are live sessions conducted by Healthcare Professionals to provide insights and support to patients and caregivers. Users can view upcoming and past webinars.'),
        findsOneWidget);
  });

  testWidgets('FAQs section title should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));
    expect(find.text('FAQs'), findsOneWidget);
  });

  testWidgets('FAQs first question should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('FAQs'));
    await tester.pump();

    expect(find.text('What are the common symptoms of liver disease?'),
        findsOneWidget);
  });

  testWidgets('FAQs first answer should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('FAQs'));
    await tester.pump();

    expect(
        find.text(
            'Common symptoms of liver disease include jaundice, abdominal pain and swelling, nausea, vomiting, fatigue, and dark urine. However, symptoms may vary depending on the specific liver condition and its severity.'),
        findsOneWidget);
  });

  testWidgets('FAQs second question should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('FAQs'));
    await tester.pump();

    expect(find.text('How is liver disease diagnosed?'), findsOneWidget);
  });

  testWidgets('FAQs second answer should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('FAQs'));
    await tester.pump();

    expect(
        find.text(
            'Liver disease is diagnosed through a combination of medical history, physical examination, blood tests, imaging studies (such as ultrasound or MRI), and sometimes liver biopsy. These tests help determine the cause, severity, and extent of liver damage.'),
        findsOneWidget);
  });

  testWidgets('FAQs third question should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('FAQs'));
    await tester.pump();

    expect(
        find.text(
            'What are some lifestyle changes recommended for managing liver disease?'),
        findsOneWidget);
  });

  testWidgets('FAQs third answer should be displayed',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    await tester.tap(find.text('FAQs'));
    await tester.pump();

    expect(
        find.text(
            "Lifestyle changes that may help manage liver disease include maintaining a healthy diet low in fat and processed foods, avoiding alcohol and tobacco, exercising regularly, managing stress, and following prescribed treatment plans. It's essential to consult healthcare professionals for personalized recommendations based on individual health conditions."),
        findsOneWidget);
  });
}
