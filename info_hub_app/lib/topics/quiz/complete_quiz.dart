import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:info_hub_app/controller/quiz_controller.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/topics/quiz/user_quiz_question_card.dart';
import 'package:info_hub_app/topics/create_topic/topic_model.dart';

class CompleteQuiz extends StatefulWidget {
  final FirebaseFirestore firestore;
  final Topic topic;
  final FirebaseAuth auth;

  const CompleteQuiz({
    Key? key,
    required this.firestore,
    required this.topic,
    required this.auth,
  }) : super(key: key);

  @override
  State<CompleteQuiz> createState() => _CompleteQuizState();
}

class _CompleteQuizState extends State<CompleteQuiz> {
  List<QuizQuestion> questions = [];
  int questionListLength = 0;
  bool completed = false;
  bool completedBefore = false;
  List<bool> correctQuestions = [];
  int score = 0;
  String oldScore = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getQuestionsList();
    checkIfCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questionListLength,
              itemBuilder: (context, index) {
                return UserQuizQuestionCard(
                  firestore: widget.firestore,
                  questionNo: index + 1,
                  question: questions[index],
                  completed: completed,
                  onUpdateAnswer: (isCorrect) {
                    if (isCorrect) {
                      setState(() {
                        correctQuestions[index] = true;
                        score = correctQuestions
                            .where((element) => element == true)
                            .length;
                      });
                      QuizController(
                              firestore: widget.firestore, auth: widget.auth)
                          .handleQuizCompletion(
                              widget.topic, "$score/$questionListLength");
                    }
                  },
                );
              },
            ),
            if (completed)
              Text('Your new score is $score out of $questionListLength'),
            if (completedBefore) Text('Your old is score is $oldScore'),
            ElevatedButton(
              onPressed: () async {
                score =
                    correctQuestions.where((element) => element == true).length;
                setState(() {
                  completed = true;
                });
              },
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: () {
                resetPage();
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getQuestionsList() async {
    List<QuizQuestion> tempList =
        await QuizController(firestore: widget.firestore, auth: widget.auth)
            .getQuizQuestions(widget.topic);
    setState(() {
      questions = tempList;
      questionListLength = questions.length;
      correctQuestions = List.generate(questionListLength, (index) => false);
    });
  }

  Future checkIfCompleted() async {
    QuizController controller =
        QuizController(firestore: widget.firestore, auth: widget.auth);

    if (await controller.checkQuizScore(widget.topic.quizID!)) {
      String temp = await controller.getQuizScore(widget.topic.quizID!);
      setState(() {
        oldScore = temp;
        completedBefore = true;
      });
    }
  }

  void resetPage() {
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
