import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/quiz_model.dart';
import 'package:info_hub_app/model/topic_model.dart';

class QuizController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  QuizController({
    required this.firestore,
    required this.auth,
  });

  // Add a new question to the 'quizQuestions' collection
  Future<void> addQuestion(
    String question,
    List<String> correctAnswers,
    List<String> wrongAnswers,
    String quizID,
  ) async {
    final CollectionReference quizQuestionCollectionRef =
        firestore.collection('quizQuestions');
    await quizQuestionCollectionRef.add({
      'question': question,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'quizID': quizID,
    });
  }

  // Get a list of quiz questions for the given topic
  Future<List<QuizQuestion>> getQuizQuestions(Topic topic) async {
    final String quizID = topic.quizID!;
    final QuerySnapshot data = await firestore
        .collection('quizQuestions')
        .where('quizID', isEqualTo: quizID)
        .get();
    final List<QuizQuestion> questions =
        data.docs.map((doc) => QuizQuestion.fromSnapshot(doc)).toList();
    return questions;
  }

  // Delete a quiz question from the 'quizQuestions' collection
  Future<void> deleteQuestion(QuizQuestion question) async {
    await firestore.collection('quizQuestions').doc(question.id).delete();
  }

  // Delete all questions for a given quiz ID
  Future<void> deleteQuiz(String quizID) async {
    final CollectionReference quizQuestionsRef =
        firestore.collection('quizQuestions');
    final QuerySnapshot querySnapshot =
        await quizQuestionsRef.where('quizID', isEqualTo: quizID).get();
    for (final doc in querySnapshot.docs) {
      doc.reference.delete();
    }
  }

  // Remove the quizID from the given topic
  Future<void> deleteTopicQuiz(Topic topic) async {
    topic.quizID = '';
    await firestore.collection('topics').doc(topic.id).set(topic.toJson());
  }

  // Check if the user has already completed the quiz for the given quizID
  Future<bool> checkQuizScore(String quizID) async {
    final CollectionReference quizQuestionsRef = firestore.collection('Quiz');
    final QuerySnapshot querySnapshot = await quizQuestionsRef
        .where('quizID', isEqualTo: quizID)
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .get();
    return querySnapshot.size > 0;
  }

  // Get the user's score for the given quizID
  Future<String> getQuizScore(String quizID) async {
    final CollectionReference quizQuestionsRef = firestore.collection('Quiz');
    final QuerySnapshot querySnapshot = await quizQuestionsRef
        .where('quizID', isEqualTo: quizID)
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .get();
    return querySnapshot.docs.first['score'];
  }

  // Update an existing question in the 'quizQuestions' collection
  Future<void> updateQuestion(
    QuizQuestion question,
    List<String> correctAnswers,
    List<String> wrongAnswers,
    String quizID,
  ) async {
    final CollectionReference quizQuestionCollectionRef =
        firestore.collection('quizQuestions');
    await quizQuestionCollectionRef.doc(question.id).set({
      'question': question.question,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'quizID': quizID,
    });
  }

  // Save the user's quiz score
  Future<void> saveQuiz(Quiz quiz) async {
    final QuerySnapshot querySnapshot = await firestore
        .collection('Quiz')
        .where('quizID', isEqualTo: quiz.id)
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If there is a matching document, update it
      final String documentId = querySnapshot.docs.first.id;
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

  // Handle quiz completion and save the user's score
  Future<void> handleQuizCompletion(Topic topic, String score) async {
    final String quizID = topic.quizID!;
    final Quiz quiz = Quiz(
      id: quizID,
      score: score,
      topicID: topic.id!,
      uid: auth.currentUser!.uid,
    );
    await saveQuiz(quiz);
  }

  // Get a list of answers based on the selection and answer type
  List<String> getAnswers(
    bool isCorrect,
    List<bool> selected,
    List<dynamic> answers,
  ) {
    final List<String> filteredAnswers = [];
    for (int i = 0; i < answers.length; i++) {
      if ((isCorrect && selected[i]) || (!isCorrect && !selected[i])) {
        filteredAnswers.add(answers[i]);
      }
    }
    return filteredAnswers;
  }
}
