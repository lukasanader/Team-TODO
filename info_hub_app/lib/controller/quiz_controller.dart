import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/model/quiz_model.dart';

class QuizController {
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  QuizController({required this.firestore,required this.auth});



   Future addQuestion(String question, List<String> correctAnswers, List<String> wrongAnswers, String quizID) async{
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

  Future deleteQuestion(QuizQuestion question) async{
    await firestore.collection('quizQuestions').doc(question.id).delete();
  }

  Future deleteQuiz(String quizID) async {
    CollectionReference quizQuestionsRef = firestore.collection('quizQuestions');
    QuerySnapshot querySnapshot = await quizQuestionsRef.where('quizID', isEqualTo: quizID).get();
    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });
  }

  Future<bool> checkQuizScore(String quizID) async {
    CollectionReference quizQuestionsRef = firestore.collection('Quiz');
    QuerySnapshot querySnapshot = await quizQuestionsRef.where('quizID', isEqualTo: quizID).where('uid', isEqualTo: auth.currentUser!.uid).get();
    if (querySnapshot.size>0){
      return true;
    }else{
      return false;
    }
  }

  Future<String> getQuizScore(String quizID) async {
    CollectionReference quizQuestionsRef = firestore.collection('Quiz');
    QuerySnapshot querySnapshot = await quizQuestionsRef.where('quizID', isEqualTo: quizID).where('uid', isEqualTo: auth.currentUser!.uid).get();
    return querySnapshot.docs.first['score'];
  }

  Future updateQuestion(QuizQuestion question, List<String> correctAnswers, List<String> wrongAnswers, String quizID) async {
    CollectionReference quizQuestionCollectionRef = firestore.collection('quizQuestions');
    await quizQuestionCollectionRef.doc(question.id).set({
      'question' : question.question,
      'correctAnswers' : correctAnswers,
      'wrongAnswers' : wrongAnswers,
      'quizID' : quizID, 
    });
  }

  Future<void> saveQuiz(Quiz quiz) async {
    QuerySnapshot querySnapshot = await firestore.collection('Quiz')
        .where('quizID', isEqualTo: quiz.id)
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If there is a matching document, update it
      String documentId = querySnapshot.docs.first.id;
      await firestore.collection('Quiz').doc(documentId).update({
        'score': quiz.score,
      });
    } else {
      // If there is no matching document, add a new one
      await firestore.collection('Quiz').add({
        'quizID': quiz.id,
        'topicID': quiz.topicID,
        'uid': quiz.uid,
        'score': quiz.score,
      });
    }
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