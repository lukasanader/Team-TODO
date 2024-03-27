import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/topic_question_model.dart';

class TopicQuestionController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  TopicQuestionController({
    required this.firestore,
    required this.auth,
  });

  // Handle a new question by creating a TopicQuestion object and adding it to Firestore
  void handleQuestion(String questionText) {
    final TopicQuestion question = TopicQuestion(
      id: '',
      uid: auth.currentUser!.uid,
      question: questionText,
      date: DateTime.now().toString(),
    );

    addQuestion(question);
  }

  // Add a TopicQuestion to the 'questions' collection in Firestore
  Future<void> addQuestion(TopicQuestion question) async {
    await firestore.collection('questions').add({
      'uid': question.uid,
      'question': question.question,
      'date': question.date,
    });
  }

  // Get a list of all TopicQuestions ordered by question text
  Future<List<TopicQuestion>> getQuestionList() async {
    final QuerySnapshot snapshot =
        await firestore.collection('questions').orderBy('question').get();
    final List<TopicQuestion> questions =
        snapshot.docs.map((doc) => TopicQuestion.fromSnapshot(doc)).toList();
    return questions;
  }

  // Get a list of TopicQuestions relevant to the given title
  Future<List<TopicQuestion>> getRelevantQuestions(String title) async {
    final String cleanedTitle =
        title.replaceAll("?", "").replaceAll(".", "").toLowerCase();
    final QuerySnapshot data = await firestore.collection('questions').get();
    final List<dynamic> questionList = List.from(data.docs);
    final List<String> keywords = [];
    final List<String> titleWords = cleanedTitle.split(' ');

    for (final word in titleWords) {
      if (nouns.contains(word)) {
        keywords.add(word);
      }
    }

    final List<dynamic> tempQuestions = [];
    for (final question in questionList) {
      final List<String> questionWords = question['question']
          .replaceAll("?", "")
          .replaceAll(".", "")
          .toLowerCase()
          .split(' ');

      for (final word in questionWords) {
        if (keywords.contains(word)) {
          tempQuestions.add(question);
          break;
        }
      }
    }

    final List<TopicQuestion> questions =
        tempQuestions.map((doc) => TopicQuestion.fromSnapshot(doc)).toList();
    return questions;
  }

  // Delete all TopicQuestions from the 'questions' collection
  Future<void> deleteAllQuestions(List<TopicQuestion> questions) async {
    for (final question in questions) {
      await firestore.collection('questions').doc(question.id).delete();
    }
  }

  // Delete a single TopicQuestion from the 'questions' collection
  Future<void> deleteQuestion(TopicQuestion question) async {
    final CollectionReference questionCollectionRef =
        firestore.collection('questions');
    await questionCollectionRef.doc(question.id).delete();
  }

  // Calculate the number of days ago a question was asked
  String calculateDaysAgo(String questionDate) {
    final DateTime date = DateTime.parse(questionDate);
    return DateTime.now().difference(date).inDays.toString();
  }
}
