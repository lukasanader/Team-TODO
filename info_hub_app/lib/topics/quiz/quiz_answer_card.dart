import 'package:flutter/material.dart';

class AnswerCard extends StatefulWidget {
  
  String answer='';
  int anserNo = -1;
  final bool Function(int,bool) onSelected;

  AnswerCard({required this.answer,required this.anserNo, required this.onSelected, super.key});

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
         setState(() {
           selected = selected = !selected;

         });
         widget.onSelected(widget.anserNo-1,selected);
        },
        child: Card(
          color: selected ? Colors.green : null,
                  child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text("${widget.anserNo}. ${widget.answer}")
        ,
                  ),
                ));
  }
}
