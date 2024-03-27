import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/quiz_controller.dart';
import 'package:info_hub_app/model/quiz_model.dart';
import 'package:info_hub_app/topics/create_topic/helpers/quiz/quiz_answer_card.dart';

class QuizQuestionCard extends StatefulWidget {
  final String quizID;
  String question;
  final int questionNo;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final QuizQuestion? editQuestion;
  final Function(int)? onDelete;

  QuizQuestionCard({
    required this.question,
    required this.questionNo,
    required this.quizID,
    required this.firestore,
    required this.auth,
    this.editQuestion,
    this.onDelete,
    super.key,
  });

  @override
  State<QuizQuestionCard> createState() => _QuizQuestionCardState();
}

class _QuizQuestionCardState extends State<QuizQuestionCard> {
  final TextEditingController _answerController = TextEditingController();
  List<dynamic> answers = [];
  List<bool> selected = [];
  bool isExpanded = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.editQuestion != null) {
      getAnswerList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: isExpanded
          ? buildExpandedQuestionTile()
          : buildCollapsedQuestionTile(),
    );
  }

  Widget buildExpandedQuestionTile() {
    return ExpansionTile(
      title: Text(
        "${widget.questionNo}. ${widget.question}",
        style: const TextStyle(fontSize: 18),
      ),
      initiallyExpanded: isExpanded,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildAnswerListView(),
              buildAnswerInputRow(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: saveQuestion,
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: onDeleteQuestion,
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCollapsedQuestionTile() {
    return SizedBox(
      height: 60,
      child: ListTile(
        title: Text(
          "${widget.questionNo}. ${widget.question}",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget buildAnswerListView() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: answers.length,
        itemBuilder: (context, index) {
          return AnswerCard(
            key: Key('answerCard_$index'),
            answer: answers[index],
            answerNo: index + 1,
            onSelected: onSelected,
          );
        },
      ),
    );
  }

  Widget buildAnswerInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: const Key('answerField'),
            controller: _answerController,
            decoration: const InputDecoration(
              hintText: 'Enter a possible answer',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: addAnswer,
            child: const Icon(Icons.add),
          ),
        )
      ],
    );
  }

  Future<void> getAnswerList() async {
    List tempList =
        widget.editQuestion!.correctAnswers + widget.editQuestion!.wrongAnswers;
    setState(() {
      answers = tempList;
      selected = List.generate(answers.length, (index) => false);
    });
  }

  bool onSelected(int index, bool isSelected) {
    setState(() {
      for (int i = 0; i < selected.length; i++) {
        if (i == index) {
          selected[i] = isSelected;
        } else {
          selected[i] = false;
        }
      }
    });
    return true;
  }

  void addAnswer() {
    setState(() {
      if (_answerController.text.isEmpty) {
        showSnackBar(context, 'Enter a valid answer');
      } else {
        answers.add(_answerController.text);
        selected.add(false);
        _answerController.clear();
      }
    });
  }

  void onDeleteQuestion() {
      QuizController controller = QuizController(
        firestore: widget.firestore,
        auth: widget.auth,
      );
      if (widget.editQuestion != null) {
        controller.deleteQuestion(widget.editQuestion!);
      }
      setState(() {
        widget.question='[Deleted]';
        isExpanded=false;
      }); // Trigger onDelete callback
  }

  void saveQuestion() {
    QuizController controller = QuizController(
      firestore: widget.firestore,
      auth: widget.auth,
    );
    if (!selected.contains(true)) {
      showSnackBar(context, 'Select at least one correct answer');
    } else {
      if (widget.editQuestion != null) {
        controller.updateQuestion(
          widget.editQuestion!,
          controller.getAnswers(true, selected, answers),
          controller.getAnswers(false, selected, answers),
          widget.quizID,
        );
      } else {
        controller.addQuestion(
          widget.question,
          controller.getAnswers(true, selected, answers),
          controller.getAnswers(false, selected, answers),
          widget.quizID,
        );
      }
      showSnackBar(context, 'Question has been saved!');
      setState(() {
        _answerController.clear();
        isExpanded = false; // Collapse the ExpansionTile
      });
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
