import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/controller/create_topic_controllers/topic_question_controller.dart';
import 'package:info_hub_app/model/topic_models/topic_question_model.dart';

class QuestionCard extends StatelessWidget {
  final TopicQuestion _question;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Function() onDelete;

  const QuestionCard(this._question, this.firestore, this.onDelete, this.auth,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${_question.question} \n${TopicQuestionController(firestore: firestore, auth: auth).calculateDaysAgo(_question.date)} days ago",
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirmation"),
                        content: const Text(
                            "Are you sure you are finished with this question?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Delete the question from the database
                              TopicQuestionController(
                                      firestore: firestore, auth: auth)
                                  .deleteQuestion(_question);
                              onDelete();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Confirm"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
