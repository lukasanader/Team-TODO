import 'package:flutter/material.dart';
import 'package:info_hub_app/view/settings_view/help_page_widget.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, Key? customKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDropDown(
              title: 'General',
              content: const Text(
                "This is an information hub app that allows you to view and share information on matters regarding living with liver issues.",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            buildDropDown(
              title: 'Guide',
              content: Column(
                children: [
                  HelpPageControllers.buildGuideItem(
                    title: 'Topics',
                    subtitle:
                        '"Topics" is a section within the app that provides users with information on various aspects related to liver diseases. Each topic delves into specific issues, concerns, and aspects of liver diseases, offering users a general understanding of the subject matter. Users can explore different topics to gain insights into symptoms, treatments, lifestyle changes, and other relevant information pertinent to managing liver diseases effectively.',
                  ),
                  HelpPageControllers.buildGuideItem(
                    title: 'Submit Questions',
                    subtitle:
                        'Questions submitted will be carefully reviewed by Healthcare Professionals and answered privately.',
                  ),
                  HelpPageControllers.buildGuideItem(
                    title: 'Patient Experience',
                    subtitle:
                        'Patient Experiences have been carefully reviewed by Healthcare Professionals and are shared to provide insights and support to other patients and caregivers.',
                  ),
                  HelpPageControllers.buildGuideItem(
                    title: 'Webinar',
                    subtitle:
                        'Webinars are live sessions conducted by Healthcare Professionals to provide insights and support to patients and caregivers. Users can view upcoming and past webinars.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildDropDown(
              title: 'FAQs',
              content: Column(
                children: [
                  HelpPageControllers.buildFAQItem(
                    question: 'What are the common symptoms of liver disease?',
                    answer:
                        'Common symptoms of liver disease include jaundice, abdominal pain and swelling, nausea, vomiting, fatigue, and dark urine. However, symptoms may vary depending on the specific liver condition and its severity.',
                  ),
                  HelpPageControllers.buildFAQItem(
                    question: 'How is liver disease diagnosed?',
                    answer:
                        'Liver disease is diagnosed through a combination of medical history, physical examination, blood tests, imaging studies (such as ultrasound or MRI), and sometimes liver biopsy. These tests help determine the cause, severity, and extent of liver damage.',
                  ),
                  HelpPageControllers.buildFAQItem(
                    question:
                        'What are some lifestyle changes recommended for managing liver disease?',
                    answer:
                        "Lifestyle changes that may help manage liver disease include maintaining a healthy diet low in fat and processed foods, avoiding alcohol and tobacco, exercising regularly, managing stress, and following prescribed treatment plans. It's essential to consult healthcare professionals for personalized recommendations based on individual health conditions.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildDropDown({required String title, required Widget content}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: content,
          ),
        ],
      ),
    );
  }
}
