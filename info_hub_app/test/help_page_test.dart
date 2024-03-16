import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/settings/help_page.dart'; // Replace 'your_app_name' with your actual app name

void main() {
  testWidgets('App bar title should be "Help Page"', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the app bar title is 'Help Page'
    expect(find.text('Help Page'), findsOneWidget);
  });

  testWidgets('General section title should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'General' section title is displayed
    expect(find.text('General'), findsOneWidget);
  });

    testWidgets('General description should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'General' section title is displayed
    expect(find.text("This is an information hub app that allows you to view and share information on matters regarding living with liver issues."), findsOneWidget);
  });

  testWidgets('Guide section title should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Guide' section title is displayed
    expect(find.text('Guide'), findsOneWidget);
  });

  testWidgets('Topics tile should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Topics' tile is displayed
    expect(find.text('Topics'), findsOneWidget);
  });

    testWidgets('Topics description should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Topics' tile is displayed
    expect(find.text('"Topics" is a section within the app that provides users with information on various aspects related to liver diseases. Each topic delves into specific issues, concerns, and aspects of liver diseases, offering users a general understanding of the subject matter. Users can explore different topics to gain insights into symptoms, treatments, lifestyle changes, and other relevant information pertinent to managing liver diseases effectively.'), findsOneWidget);
  });

  testWidgets('Submit Questions tile should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Submit Questions' tile is displayed
    expect(find.text('Submit Questions'), findsOneWidget);
  });

    testWidgets('Submit Questions description should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Submit Questions' tile is displayed
    expect(find.text('Questions submitted will be carefully reviewed by Healthcare Professionals and answered privately.'), findsOneWidget);
  });

  testWidgets('Patient Experience tile should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Patient Experience' tile is displayed
    expect(find.text('Patient Experience'), findsOneWidget);
  });

    testWidgets('Patient Experience description should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Patient Experience' tile is displayed
    expect(find.text('Patient Experiences have been carefully reviewed by Healthcare Professionals and are shared to provide insights and support to other patients and caregivers.'), findsOneWidget);
  });

  testWidgets('Webinar tile should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Webinar' tile is displayed
    expect(find.text('Webinar'), findsOneWidget);
  });

    testWidgets('Webinar description should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));

    // Verify if the 'Webinar' tile is displayed
    expect(find.text('Webinars are live sessions conducted by Healthcare Professionals to provide insights and support to patients and caregivers. Users can view upcoming and past webinars.'), findsOneWidget);
  });

  testWidgets('FAQs section title should be displayed', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));
    expect(find.text('FAQs'), findsOneWidget);
  });

  testWidgets('FAQs information should be displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HelpPage(),
    ));
    expect(find.text('FAQs information goes here.'), findsOneWidget);
  });
}
