import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/ask_question/question_card.dart';
import 'package:english_words/english_words.dart';

class ViewQuestionPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  const ViewQuestionPage({super.key, required this.firestore});
  @override
  _ViewQuestionPageState createState() => _ViewQuestionPageState();
}

class _ViewQuestionPageState extends State<ViewQuestionPage>{
List<Object> _questionList = [];


@override
void didChangeDependencies() {
    super.didChangeDependencies();
    getQuestionList();
}

@override
Widget build(BuildContext context) {
  return Scaffold( appBar: AppBar(
    leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Topic Questions"),
  ),
    body: SafeArea(
      child: Column(children: [
        Expanded(child: ListView.builder(
          itemCount: _questionList.isEmpty ? 1: _questionList.length,
          itemBuilder: (context, index) {
            if (_questionList.isEmpty){
              return const ListTile(
                title: Text('There are currently no more questions!'),
              );
            }else{
              return QuestionCard(_questionList[index] as QueryDocumentSnapshot,widget.firestore,getQuestionList);
            }
          }
        ))
      ]),
    )

    );
    }

    Future getQuestionList() async {
    QuerySnapshot data = await widget.firestore.collection('questions').orderBy('question').get();
    setState(() {
      _questionList = List.from(data.docs);
    });
  }
}