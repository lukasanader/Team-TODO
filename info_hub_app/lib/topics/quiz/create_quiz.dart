import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'quiz_question_card.dart';


class CreateQuiz extends StatefulWidget {

final FirebaseFirestore firestore;
void Function(String) addQuiz;
CreateQuiz({super.key, required this.firestore, required this.addQuiz});


  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
final TextEditingController _questionController = TextEditingController();
List<String> questions = [];
bool invalid = false;
String quizID = const Uuid().v4();

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return QuizQuestionCard(question: questions[index],questionNo: index+1,quizID: quizID,firestore: widget.firestore);
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
              children: [
            const SizedBox(width: 125,),
            ElevatedButton(
              onPressed: () {
                if(_questionController.text.isEmpty){
                  setState(() {
                    invalid =true;
                  });
                }else{
                setState(() {
                  invalid =false;
                  questions.add(_questionController.text);
                  _questionController.clear();
                });
                }
              },
              child: const Text('Add Question'),
            ),
            const SizedBox(width: 10,),
             SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      if(questions.isNotEmpty){
                      setState(() {
                        widget.addQuiz(quizID);
                      });
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Save Quiz'),
                  ),
                )
              ],
              
            ),
            if(invalid)
            const Text('Please enter a question', style: TextStyle(color: Colors.red),)
            
          ],
            
        ),
      ),
    );
  }
}
