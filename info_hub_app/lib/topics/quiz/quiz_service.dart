import 'package:cloud_firestore/cloud_firestore.dart';


class QuizService {

  final FirebaseFirestore firestore;

  // Constructor
  QuizService({required this.firestore});

  void addQuestion(String question, List<String> correctAnswers, List<String> wrongAnswers, String quizID) async{
    CollectionReference quizQuestionCollectionRef = firestore.collection('quizQuestions');
    await quizQuestionCollectionRef.add({
      'question' : question,
      'correctAnswers' : correctAnswers,
      'wrongAnswers' : wrongAnswers,
      'quizID' : quizID, 
    });
  }

  Future<List<dynamic>> getQuizQuestions(DocumentSnapshot topic) async{
    String quizID = topic['quizID'];
    QuerySnapshot data = await firestore.collection('quizQuestions').where('quizID', isEqualTo: quizID).get();
    return List.from(data.docs);
  }

  Future saveQuiz(DocumentSnapshot topic,String uid,String quizID,String score) async{
    await firestore.collection('Quiz').doc(quizID).set({
        'topicID': topic.id,
        'uid': uid,
        'score': score,
      }
    );
  }
}
