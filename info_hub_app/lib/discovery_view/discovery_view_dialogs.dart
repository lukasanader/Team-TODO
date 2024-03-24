import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/topic_question_controller.dart';




Future<void> addQuestionDialog(context, FirebaseFirestore firestore, FirebaseAuth auth) async {
  final TextEditingController questionController = TextEditingController();
  // Show dialog to get user input
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
              // Get the entered question text
              String questionText = questionController.text.trim();

              // Validate question text
              if (questionText.isNotEmpty) {
                TopicQuestionController(
                        firestore: firestore, auth: auth)
                    .handleQuestion(questionText);
                // Clear the text field
                questionController.clear();
                // Close the dialog
                Navigator.of(context).pop();
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

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question submitted successfully!'),
                  ),
                );
              } else {
                // Show error message if question is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a question.'),
                    backgroundColor: Colors.red,
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