import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/create_topic_controllers/topic_question_controller.dart';

///dialog used in discovery view, for users to leave a question for admins
Future<void> addQuestionDialog(
  BuildContext context,
  FirebaseFirestore firestore,
  FirebaseAuth auth,
) async {
  final TextEditingController questionController = TextEditingController();

  // Show a dialog to get the user's question input
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Ask a question'),
        content: TextField(
          controller: questionController,
          decoration: const InputDecoration(
            labelText: 'Enter your question...',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get the entered question text and trim whitespace
              final String questionText = questionController.text.trim();

              // Validate question text
              if (questionText.isNotEmpty) {
                final TopicQuestionController controller =
                    TopicQuestionController(
                  firestore: firestore,
                  auth: auth,
                );

                // Handle the question
                controller.handleQuestion(questionText);

                // Clear the text field
                questionController.clear();

                // Close the dialog
                Navigator.of(context).pop();

                // Show a success dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Message'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Thank you!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Your question has been submitted.\n'
                            'An admin will get back to you shortly.',
                            textAlign: TextAlign.center,
                          ),
                        ],
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

                // Show a success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question submitted successfully!'),
                  ),
                );
              } else {
                // Show an error message if the question is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a question.'),
                    backgroundColor: Colors.white,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}