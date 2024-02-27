import 'package:cloud_firestore/cloud_firestore.dart';


class QuizService {

  final FirebaseFirestore firestore;

  // Constructor
  QuizService({required this.firestore});

  void addQuestion(String question, List<String> correctAnswers, List<String> wrongAnswers, String quizID) async{
    CollectionReference quizQuestionCollectionRef = firestore.collection('quizQuestions');
    await quizQuestionCollectionRef.add({
      'queston' : question,
      'correctAnswers' : correctAnswers,
      'wrongAnswers' : wrongAnswers,
      'quizID' : quizID, 
    });
  }
}
