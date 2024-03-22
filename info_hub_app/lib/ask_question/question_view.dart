import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/ask_question/question_card.dart';
import 'package:info_hub_app/controller/topic_question_controller.dart';
import 'package:info_hub_app/model/model.dart';

class ViewQuestionPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const ViewQuestionPage({super.key, required this.firestore, required this.auth});
  @override
  _ViewQuestionPageState createState() => _ViewQuestionPageState();
}

class _ViewQuestionPageState extends State<ViewQuestionPage>{
List<TopicQuestion> _questionList = [];


@override
void didChangeDependencies() async{
    super.didChangeDependencies();
    getQuestions();
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
              return QuestionCard(_questionList[index],widget.firestore,getQuestions,widget.auth);
            }
          }
        ))
      ]),
    )

    );
    }

    Future<void> getQuestions() async{
      List<TopicQuestion> temp = await TopicQuestionController(firestore: widget.firestore,auth: widget.auth).getQuestionList();
      setState(() {
        _questionList=temp;
      });
    }
}