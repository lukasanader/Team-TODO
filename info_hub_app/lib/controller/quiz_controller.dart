import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/model.dart';

class QuizController {
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  QuizController({required this.firestore,required this.auth});



   void addQuestion(String question, List<String> correctAnswers, List<String> wrongAnswers, String quizID) async{
    CollectionReference quizQuestionCollectionRef = firestore.collection('quizQuestions');
    await quizQuestionCollectionRef.add({
      'question' : question,
      'correctAnswers' : correctAnswers,
      'wrongAnswers' : wrongAnswers,
      'quizID' : quizID, 
    });
  }

  Future<List<QuizQuestion>> getQuizQuestions(DocumentSnapshot topic) async{
    String quizID = topic['quizID'];
    QuerySnapshot data = await firestore.collection('quizQuestions').where('quizID', isEqualTo: quizID).get();
    List<QuizQuestion> questions = data.docs.map((doc) => QuizQuestion.fromSnapshot(doc)).toList();
    return questions;
  }

  Future saveQuiz(Quiz quiz) async{
    await firestore.collection('Quiz').doc(quiz.id).set({
        'topicID': quiz.topicID,
        'uid': quiz.uid,
        'score': quiz.score,
      }
    );
  }
  

  Future handleQuizCompletion(DocumentSnapshot topic,String score) async{
    String quizID = topic['quizID'];
    Quiz quiz = Quiz(id: quizID, score: score, topicID: topic.id, uid: auth.currentUser!.uid);
    await saveQuiz(quiz); 
  }

  List<String> getAnswers(bool isCorrect,List<bool> selected, List<dynamic> answers) {
  List<String> filteredAnswers = [];
  for (int i = 0; i < answers.length; i++) {
    if ((isCorrect && selected[i]) || (!isCorrect && !selected[i])) {
      filteredAnswers.add(answers[i]);
    }
  }
  return filteredAnswers;
}

}