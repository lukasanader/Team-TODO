import 'package:flutter/material.dart';

class DisplayWebinarHelper {

  DisplayWebinarHelper();

  // Displays the guide dialog explaining the expectations of those participating in the webinar
  void showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Webinar Guide and Expectations'),
          content: const SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'What to expect from the webinar lead\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Our webinar leads are esteemed experts with advanced education and extensive training in their respective fields. '
                  'They are rich sources of valuable information and are always ready to assist you. Whether you have questions about the presentation '
                  'or seek additional insights, feel free to utilize the message box in order to communicate with the webinar lead.\n\n'
                  
                  'We understand that your queries are important, and the webinar lead will make every effort to respond promptly. '
                  'Please bear in mind that due to the high volume of questions, a brief delay may occur. Your patience is greatly appreciated, '
                  'and rest assured, the webinar lead is committed to providing thorough and helpful answers to enhance your webinar experience. '
                  'Thank you for your understanding and engagement during this interactive session.\n',
                  style: TextStyle(fontSize: 13.0),
                ),
                Text(
                  'What we expect from those watching\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'In our collaborative pursuit of knowledge, let\'s ensure a welcoming and respectful environment for all attendees. '
                  'Please observe the following behaviour expectations:\n\n'
                  '• Refrain from using foul language.\n'
                  '• Avoid disclosing personal identifiers in your messages.\n'
                  '• Prioritize respectful communication with fellow participants.\n\n'
                  
                  'Your cooperation in upholding these expectations contributes to an inclusive and positive webinar experience. '
                  'Thank you for being mindful of your behavior and actively participating in creating a conducive learning environment.',
                  style: TextStyle(fontSize: 13.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
