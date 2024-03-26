import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/model/quiz_model.dart';

import 'quiz_answer_card.dart';

class UserQuizQuestionCard extends StatefulWidget {
  QuizQuestion question;
  int questionNo = -1;
  bool completed;
  final FirebaseFirestore firestore;
  final Function(bool) onUpdateAnswer;
  UserQuizQuestionCard({
    required this.question,
    required this.questionNo,
    required this.firestore,
    required this.completed,
    required this.onUpdateAnswer,
    Key? key,
  }) : super(key: key);

  @override
  State<UserQuizQuestionCard> createState() => _UserQuizQuestionCardState();
}

class _UserQuizQuestionCardState extends State<UserQuizQuestionCard> {
  List<dynamic> answers = [];
  List<bool> selected = [];
  bool correct = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAnswerList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.completed) {
      checkQuestion();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  // Wrap Row with Expanded
                  child: Text(
                    "${widget.questionNo}. ${widget.question.question}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (correct)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (!correct && widget.completed)
                  const Icon(Icons.cancel, color: Colors.red),
              ],
            ),
            if (!correct && widget.completed)
              Text(
                  'Correct answer(s) was: ${widget.question.correctAnswers.toString().replaceAll('[', '').replaceAll(']', '')}'),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  return AnswerCard(
                    key: Key('answerCard_$index'),
                    answer: answers[index],
                    answerNo: index + 1,
                    onSelected: onSelected,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool onSelected(int index, bool isSelected) {
    setState(() {
      for (int i = 0; i < selected.length; i++) {
        // Only update the selected state for the tapped answer
        if (i == index) {
          selected[i] = isSelected;
        }
      }
    });
    return true;
  }

  Future getAnswerList() async {
    List<dynamic> tempList =
        widget.question.correctAnswers + widget.question.wrongAnswers;
    setState(() {
      answers = tempList;
      answers.shuffle();
      selected = List.generate(answers.length, (index) => false);
    });
  }

  void checkQuestion() {
    List<int> indexOfAnswers = [];
    List<dynamic> chosenAnswers = [];
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        indexOfAnswers.add(i);
      }
    }
    for (int i = 0; i < indexOfAnswers.length; i++) {
      chosenAnswers.add(answers[indexOfAnswers[i]]);
    }
    if (const ListEquality()
            .equals(chosenAnswers, widget.question.correctAnswers) &&
        !correct) {
      Future.delayed(Duration.zero, () {
        setState(() {
          correct = true;
        });
        widget.onUpdateAnswer(true);
      });
    }else{
      widget.onUpdateAnswer(false);
    }
  }
}
