import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';




class ExperienceCard extends StatefulWidget {
  final Experience _experience;
  const ExperienceCard(this._experience, {super.key});



  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool isSwitched = false;


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(widget._experience.title.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),),
                )
              ],
            ),
            Row(
              children: [ 
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(widget._experience.description.toString()),
                    )
                  )
              ],
            ),
          ]
        ),
      ),
    );
  }

  




}