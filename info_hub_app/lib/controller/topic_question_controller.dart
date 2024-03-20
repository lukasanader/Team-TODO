import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/model.dart'; // Import your model class

class TopicQuestionController {
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  TopicQuestionController({required this.firestore,required this.auth});

  void handleQuestion(String questionText) {
    // Create a new TopicQuestion object based on the user input
    TopicQuestion question = TopicQuestion(
      id: '', 
      uid: auth.currentUser!.uid, 
      question: questionText,
      date: DateTime.now().toString(), 
    );

    // Add the question to Firestore
    addQuestion(question);
  }


    Future<void> addQuestion(TopicQuestion question) async{
      await firestore.collection('questions').add({
                      'uid': question.uid,
                      'question': question.question,
                      'date': question.date,
                    });
    }

    Future<List<TopicQuestion>> getQuestionList() async {
    QuerySnapshot snapshot = await firestore.collection('questions').orderBy('question').get();
    List<TopicQuestion> questions = snapshot.docs.map((doc) => TopicQuestion.fromSnapshot(doc)).toList();
    return questions;
  } 

  Future<List<TopicQuestion>> getRelevantQuestions(String title) async{
    QuerySnapshot data = await firestore.collection('questions').get();
    List<dynamic> questionList=List.from(data.docs);
    List<String> keywords =[];
    List<String> titleWords = title.split(' ');
    for(int index=0; index<titleWords.length; index++){
      if(nouns.contains(titleWords[index])){
        keywords.add(titleWords[index]);
      }
    }
    List<dynamic> tempQuestions =[];
    for(int i=0; i<questionList.length; i++){
      List<String> questionWords = questionList[i]['question'].split(' ');
      for(int j=0; j<questionWords.length; j++){
        if(keywords.contains(questionWords[j])){
          tempQuestions.add(questionList[i]);
        }
      }
    }
    List<TopicQuestion> questions = tempQuestions.map((doc) => TopicQuestion.fromSnapshot(doc)).toList();
    return questions;
    
  }

  Future<void> deleteAllQuestions(List<TopicQuestion> questions) async {
    for(int i=0; i< questions.length; i++){
      await firestore.collection('questions').doc(questions[i].id).delete();
    }
  }
  
  Future deleteQuestion(TopicQuestion question) async {
     CollectionReference questionCollectionRef = firestore.collection('questions');
     await questionCollectionRef.doc(question.id).delete();
  }

  String calculateDaysAgo(String questionDate){
    DateTime date =DateTime.parse(questionDate);
    return DateTime.now().difference(date).inDays.toString();
  }
  
  }
