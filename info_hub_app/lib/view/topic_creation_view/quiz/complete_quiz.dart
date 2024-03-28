import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/controller/quiz_controllers/quiz_controller.dart';
import 'package:info_hub_app/model/topic_models/quiz_model.dart';
import 'package:info_hub_app/view/topic_creation_view/quiz/user_quiz_question_card.dart';
import 'package:info_hub_app/model/topic_models/topic_model.dart';

class CompleteQuiz extends StatefulWidget {
  final FirebaseFirestore firestore;
  final Topic topic;
  final FirebaseAuth auth;

  CompleteQuiz({
    super.key,
    required this.firestore,
    required this.topic,
    required this.auth,
  });

  @override
  State<CompleteQuiz> createState() => _CompleteQuizState();
}

class _CompleteQuizState extends State<CompleteQuiz> {
  late QuizController controller;
  List<QuizQuestion> _questions = [];
  int _questionListLength = 0;
  bool _quizCompleted = false;
  bool _quizCompletedBefore = false;
  List<bool> _correctQuestions = [];
  int _score = 0;
  String _oldScore = '';

  @override
  void initState() {
    super.initState();
    controller = QuizController(firestore: widget.firestore, auth: widget.auth);
    _getQuestionsList();
    _checkIfCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questionListLength,
            itemBuilder: (context, index) {
              return UserQuizQuestionCard(
                firestore: widget.firestore,
                questionNo: index + 1,
                question: _questions[index],
                completed: _quizCompleted,
                onUpdateAnswer: (isCorrect) {
                  _updateScore(isCorrect, index);
                },
              );
            },
          ),
          if (_quizCompleted)
            Text('Your new score is $_score out of $_questionListLength'),
          if (_quizCompletedBefore) Text('your old score is $_oldScore'),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Align buttons in the center horizontally
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _calculateScore();
                    setState(() {
                      _quizCompleted = true;
                    });
                  },
                  child: const Text('Done'),
                ),
                const SizedBox(width: 16), // Add some space between buttons
                ElevatedButton(
                  onPressed: _resetPage,
                  child: const Text('Reset'),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  // Fetch the list of quiz questions
  Future<void> _getQuestionsList() async {
    final List<QuizQuestion> tempList =
        await controller.getQuizQuestions(widget.topic);
    setState(() {
      _questions = tempList;
      _questionListLength = _questions.length;
      _correctQuestions = List.generate(_questionListLength, (index) => false);
    });
  }

  // Check if the user has completed the quiz before
  Future<void> _checkIfCompleted() async {
    if (await controller.checkQuizScore(widget.topic.quizID!)) {
      final String temp = await controller.getQuizScore(widget.topic.quizID!);
      setState(() {
        _oldScore = temp;
        _quizCompletedBefore = true;
      });
    }
  }

  // Update the score based on the user's answer
  void _updateScore(bool isCorrect, int index) {
    if (isCorrect) {
      setState(() {
        _correctQuestions[index] = true;
        _score = _correctQuestions.where((element) => element == true).length;
      });
    }
    _score = _correctQuestions.where((element) => element == true).length;
    controller.handleQuizCompletion(
      widget.topic,
      "$_score/$_questionListLength",
    );
  }

  // Calculate the final score
  void _calculateScore() {
    _score = _correctQuestions.where((element) => element == true).length;
  }

  // Reset the quiz page
  void _resetPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteQuiz(
          firestore: widget.firestore,
          topic: widget.topic,
          auth: widget.auth,
        ),
      ),
    );
  }
}
