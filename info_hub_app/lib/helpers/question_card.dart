import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class QuestionCard extends StatelessWidget {
  final QueryDocumentSnapshot _question;
  final FirebaseFirestore firestore;
  final Function() onDelete;

  const QuestionCard(this._question,this.firestore,this.onDelete,{super.key});

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
                  _question['question'] +
                      " " +
                      calculateDaysAgo(_question['date']) +
                      " days ago",
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
                              deleteQuestion();
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


  String calculateDaysAgo(String questionDate){
    DateTime date =DateTime.parse(questionDate);
    return DateTime.now().difference(date).inDays.toString();
  }
  Future deleteQuestion() async {
     CollectionReference questionCollectionRef = firestore.collection('questions');
     await questionCollectionRef.doc(_question.id).delete();
  }
}