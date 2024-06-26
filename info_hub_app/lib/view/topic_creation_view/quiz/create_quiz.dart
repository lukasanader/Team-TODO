// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/controller/quiz_controllers/quiz_controller.dart';
import 'package:info_hub_app/model/topic_models/quiz_model.dart';
import 'package:uuid/uuid.dart';
import 'package:info_hub_app/model/topic_models/topic_model.dart';

import 'quiz_question_card.dart';

class CreateQuiz extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final void Function(String)? addQuiz;
  final bool isEdit;
  final Topic? topic;

  const CreateQuiz({
    super.key,
    required this.firestore,
    required this.auth,
    this.addQuiz,
    required this.isEdit,
    this.topic,
  });

  @override
  _CreateQuizState createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final TextEditingController _questionController = TextEditingController();
  List<String> questions = [];
  List<QuizQuestion> editQuestions = [];
  String quizID = const Uuid().v4();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.isEdit) {
      getQuestionsList();
    }
  }

  // Function to handle the back button press
  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content:
                const Text('Do you want to leave without saving the quiz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  // Delete the quiz if the user confirms
                  QuizController controller = QuizController(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  );
                  if (widget.topic != null) {
                    quizID = widget.topic!.quizID!;
                    controller.deleteTopicQuiz(widget.topic!);
                  }
                  controller.deleteQuiz(quizID);
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        leading: BackButton(
          onPressed: () async {
            // Handle back button press
            final shouldPop = await _onWillPop();
            if (shouldPop) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount:
                    widget.isEdit ? editQuestions.length : questions.length,
                itemBuilder: (context, index) {
                  return QuizQuestionCard(
                    question: widget.isEdit
                        ? editQuestions[index].question
                        : questions[index],
                    questionNo: index + 1,
                    quizID: widget.isEdit &&
                            widget.topic != null &&
                            widget.topic!.quizID != ''
                        ? widget.topic!.quizID!
                        : quizID,
                    firestore: widget.firestore,
                    auth: widget.auth,
                    editQuestion: widget.isEdit ? editQuestions[index] : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                hintText: 'Enter your question',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add a new question
                    if (_questionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a question',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        if (widget.isEdit) {
                          // Add question to editQuestions list if in edit mode
                          QuizQuestion newQuestion = QuizQuestion(
                            id: const Uuid().v4(),
                            correctAnswers: [],
                            question: _questionController.text,
                            wrongAnswers: [],
                          );
                          editQuestions.add(newQuestion);
                        } else {
                          // Add question to questions list if in create mode
                          questions.add(_questionController.text);
                        }
                        _questionController.clear();
                      });
                    }
                  },
                  child: const Text('Add Question'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Save the quiz
                    if (questions.isNotEmpty || editQuestions.isNotEmpty) {
                      widget.addQuiz!(quizID);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please add at least one question to save the quiz',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Quiz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to fetch questions list if in edit mode
  Future<void> getQuestionsList() async {
    if (widget.topic != null) {
      List<QuizQuestion> tempList = await QuizController(
        firestore: widget.firestore,
        auth: widget.auth,
      ).getQuizQuestions(widget.topic!);
      setState(() {
        editQuestions = tempList;
      });
    }
  }

}
