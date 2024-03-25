import 'package:flutter/material.dart';

class AnswerCard extends StatefulWidget {
  final String answer;
  final int answerNo;
  final bool Function(int, bool) onSelected;

  AnswerCard({
    required this.answer,
    required this.answerNo,
    required this.onSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle the selected state and invoke the callback
        setState(() {
          selected = !selected;
        });
        widget.onSelected(widget.answerNo - 1, selected);
      },
      child: Card(
        color: selected ? Colors.green : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("${widget.answerNo}. ${widget.answer}"),
        ),
      ),
    );
  }
}
