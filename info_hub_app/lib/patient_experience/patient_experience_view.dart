import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/patient_experience_model.dart';

class ExperienceView extends StatefulWidget {
  final FirebaseFirestore firestore;
  const ExperienceView({super.key, required this.firestore});

  @override
  _ExperienceViewState createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final Experience _experience = Experience();
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paitent's Experiences"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showPostDialog();
            },
            child: const Text("Share your experience!"),
          )
        ],

      ) 
      

    );
  }



  void _showPostDialog() {
    _descriptionController.clear();
    _titleController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 1,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Share your experience!',
                  border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
                width: 100000,
                ),
              ElevatedButton(
                onPressed: () async{
                  _saveExperience();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveExperience() async {
    // FirebaseAuth auth = FirebaseAuth.instance;
    // User? user = auth.currentUser;

    _experience.title = _titleController.text;
    _experience.description = _descriptionController.text;
    // if (user != null) {
    //   _experience.uid = user.uid;
    // }
    _experience.verified = false;

    CollectionReference db = widget.firestore.collection('experiences');
    await db.add(_experience.toJson());
    
  }

}