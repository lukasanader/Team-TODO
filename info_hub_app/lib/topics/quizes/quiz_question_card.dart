import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/topics/quizes/quiz_service.dart';

import 'quiz_answer_card.dart';


class QuizQuestionCard extends StatefulWidget {
  String quizID = '';
  String question = '';
  int questionNo = -1;
  final FirebaseFirestore firestore;
  QuizQuestionCard({required this.question,required this.questionNo,required this.quizID,required this.firestore, super.key});

  @override
  State<QuizQuestionCard> createState() => _QuizQuestionCardState();
}


class _QuizQuestionCardState extends State<QuizQuestionCard> {
  List<String> answers = [];
  List<bool> selected = [];
  bool invalidAnswer = false;
  bool invalid =false;
  bool saved = false;
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "${widget.questionNo}. ${widget.question}",
              style: const TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 300,
              child: 
              ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  return AnswerCard(
                    key: Key('answerCard_$index'),
                    answer: answers[index],
                    anserNo: index + 1,
                    onSelected: onSelected,
                  );
                },
              ),
              
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('answerField'),
                    controller: _answerController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a possible answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if(_answerController.text.isEmpty){
                          invalidAnswer =true;
                          saved=false;
                        }else{
                          invalidAnswer = false;
                          invalid =false;
                          answers.add(_answerController.text);
                          selected.add(false);
                          _answerController.clear();
                        }
                      });
                    },
                    child: const Icon(Icons.add),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                if(!selected.contains(true)){
                  saved =false;
                  invalid = true;
                }else{
                  invalid = false;
                  invalidAnswer = false;
                  saved = true;
                  _answerController.clear();
                  QuizService(firestore: widget.firestore).addQuestion(widget.question,getCorrectAnswers(),getWrongAnswers(),widget.quizID);
                }
                });
              },
              child: const Text('Save'),
            ),
          if (saved)
          const Text('Question has been saved!')
          else if (invalidAnswer)
          const Text('Enter a valid answer')
          else if (invalid)
          const Text('Enter a valid question')
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
        } else {
          // If another answer was previously selected, unselect it
          selected[i] = false;
        }
      }
    });
    return true;
  }

List<String> getCorrectAnswers(){
  List<String> correctAnswers = [];
  for (int i = 0; i < answers.length; i++) {
    if (selected[i]) {
      correctAnswers.add(answers[i]);
    }
  }
  return correctAnswers;
}
List<String> getWrongAnswers(){
  List<String> wrongAnswers = [];
  for (int i = 0; i < answers.length; i++) {
    if (!selected[i]) {
      wrongAnswers.add(answers[i]);
    }
  }
  return wrongAnswers;
}
}