import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/controller/quiz_controller.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:uuid/uuid.dart';

import 'quiz_question_card.dart';

class CreateQuiz extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  void Function(String)? addQuiz;
  bool isEdit;
  DocumentSnapshot? topic;
  
  CreateQuiz({super.key, required this.firestore, required this.auth, this.addQuiz, required this.isEdit,this.topic});

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  final TextEditingController _questionController = TextEditingController();
  List<String> questions = [];
  List<QuizQuestion> editQuestions = [];
  String quizID = const Uuid().v4();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(widget.isEdit){getQuestionsList();}
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to leave without saving the quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              if(widget.topic!=null){quizID=widget.topic!['quizID'];}
              QuizController(firestore: widget.firestore, auth: widget.auth).deleteQuiz(quizID);
              Navigator.of(context).pop(true);
              },
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        leading: BackButton(
          onPressed: () async {
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
                itemCount: widget.isEdit ? editQuestions.length : questions.length,
                itemBuilder: (context, index) {
                  return QuizQuestionCard(
                    question: widget.isEdit ? editQuestions[index].question : questions[index],
                    questionNo: index + 1,
                    quizID: widget.isEdit && widget.topic != null ? widget.topic!['quizID'] : quizID,
                    firestore: widget.firestore,
                    auth: widget.auth,
                    editQuestion: widget.isEdit ? editQuestions[index] : null,
                    onDelete: onDeleteQuestion
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
                    if (_questionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a question', style: TextStyle(color: Colors.red)),
                        ),
                      );
                    } else {
                      setState(() {
                        if(widget.isEdit){
                          QuizQuestion newQuestion = QuizQuestion(id: const Uuid().v4(), correctAnswers: [], question: _questionController.text, wrongAnswers: []);
                          editQuestions.add(newQuestion);
                        }else{
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
                    if (questions.isNotEmpty || editQuestions.isNotEmpty) {
                      if(!widget.isEdit){
                        widget.addQuiz!(quizID);
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add at least one question to save the quiz', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
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
  Future getQuestionsList() async {
    if (widget.topic != null) {
    List<QuizQuestion> tempList = await QuizController(firestore: widget.firestore, auth: widget.auth).getQuizQuestions(widget.topic!);
    setState(() {
      editQuestions = tempList;
    });
  }
  }
  void onDeleteQuestion(int index) {
    setState(() {
      if (widget.isEdit) {
        editQuestions.removeAt(index);
      } else {
        questions.removeAt(index);
      }
    });
  }
}
