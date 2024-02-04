import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class Search extends StatefulWidget {
  @override
  _Search createState() => _Search();
}


class _Search extends State<Search>{
  List<String> listItems = [];

  Future getAllTopicList() async {
    List<String> topicListStrings = [];
    QuerySnapshot data = await FirebaseFirestore.instance.collection('topics').get();
    List<Object> topicListObjects = List.from(data.docs);

    for (int i = 0; i < topicListObjects.length; i++) {
      QueryDocumentSnapshot topic = topicListObjects[i] as QueryDocumentSnapshot<Object?>;
      topicListStrings.add(topic['title'].toLowerCase());
    }

    listItems = topicListStrings;
  }


  @override
  Widget build(BuildContext context) {
    getAllTopicList();
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return listItems.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String value) {
        print("Selected value: $value");
      },
    );
  }
}