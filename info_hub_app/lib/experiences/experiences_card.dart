import 'package:flutter/material.dart';
import 'package:info_hub_app/experiences/experience_model.dart';

class ExperienceCard extends StatefulWidget {
  final Experience _experience;
  const ExperienceCard(this._experience, {super.key});

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(children: [
          Row(
            children: [
              Center(
                child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10.0),
                    child: Text(
                      widget._experience.title.toString(),
                      style: Theme.of(context).textTheme.titleSmall,
                    )),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  widget._experience.description.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ))
            ],
          ),
        ]),
      ),
    );
  }
}
