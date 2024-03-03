import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/topics/quiz/quiz_service.dart';
import 'package:info_hub_app/topics/quiz/user_quiz_question_card.dart';

class CompleteQuiz extends StatefulWidget {

final FirebaseFirestore firestore;
final QueryDocumentSnapshot topic;
final FirebaseAuth auth;

const CompleteQuiz({super.key, required this.firestore,required this.topic, required this.auth});


  @override
  State<CompleteQuiz> createState() => _CompleteQuizState();
}

class _CompleteQuizState extends State<CompleteQuiz> {
  List<dynamic> questions=[]; 
  int questionListLength=0;
  bool completed =false; 
  List<bool> correctQuestions=[];
  int score=0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getQuestionsList();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
      child:
        Column(
          children: [
            ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questionListLength,
            itemBuilder: (context, index) {
              return UserQuizQuestionCard(
                  firestore: widget.firestore,
                  questionNo: index + 1,
                  question: questions[index] as QueryDocumentSnapshot,
                  completed: completed,
                  onUpdateAnswer: (isCorrect) {
                    if (isCorrect) {
                        setState(() {
                          correctQuestions[index] = true;

                        });
                        getScore();
                    }
                  }
            );
            }
            ),
            if (completed)
            Text('Your score is $score out of $questionListLength'),
            ElevatedButton(onPressed: () async{
                setState(() {
                  completed=true;
                });
              },
            child:
              const Text('Done')),
            
          ]
          ),
      )
    );
    
  }
 Future getQuestionsList() async {
    List<dynamic> tempList = await QuizService(firestore: widget.firestore).getQuizQuestions(widget.topic);
    setState(() {
      questions = tempList;
      questionListLength = questions.length;
      correctQuestions=List.generate(questionListLength, (index) => false);
    });
  }

void getScore(){
  setState(() {
    score = correctQuestions.where((element) => element == true).length;
  });
  QuizService(firestore: widget.firestore).saveQuiz(widget.topic,widget.auth.currentUser!.uid,questions[0]['quizID'],"$score/$questionListLength");
}
}
