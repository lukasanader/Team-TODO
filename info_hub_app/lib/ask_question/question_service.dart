
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';

class QuestionService {

  final FirebaseFirestore firestore;

  QuestionService({required this.firestore});

  Future<List<dynamic>> getRelevantQuestions(String title) async{
    QuerySnapshot data = await firestore.collection('questions').get();
    List<dynamic> questionList=List.from(data.docs);
    List<String> keywords =[];
    List<String> titleWords = title.split(' ');
    for(int index=0; index<titleWords.length; index++){
      if(nouns.contains(titleWords[index])){
        keywords.add(titleWords[index]);
      }
    }
    List<dynamic> questions =[];
    for(int i=0; i<questionList.length; i++){
      List<String> questionWords = questionList[i]['question'].split(' ');
      for(int j=0; j<questionWords.length; j++){
        if(keywords.contains(questionWords[j])){
          questions.add(questionList[i]);
        }
      }
    }

    return questions;
    
  }

  Future<void> deleteQuestions(List<dynamic> questions) async {
    for(int i=0; i< questions.length; i++){
      await firestore.collection('questions').doc(questions[i].id).delete();
    }
  }
}