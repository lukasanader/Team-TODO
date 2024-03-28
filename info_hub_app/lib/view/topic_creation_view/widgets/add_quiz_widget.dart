import 'package:flutter/material.dart';
import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';
import 'package:info_hub_app/view/topic_creation_view/quiz/create_quiz.dart';

class AddQuizWidget extends StatelessWidget {
  final TopicCreationViewState screen;

  const AddQuizWidget({
    super.key,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateQuiz(
                firestore: screen.widget.firestore,
                auth: screen.widget.auth,
                addQuiz: addQuiz,
                isEdit: screen.editing,
                topic: screen.widget.topic,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "ADD QUIZ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (screen.quizAdded)
              const Icon(
                Icons.check,
                color: Colors.green,
              )
          ],
        ),
      ),
    );
  }

  void addQuiz(String qid) {
    screen.quizID = qid;
    screen.quizAdded = true;
    screen.updateState();
  }
}
