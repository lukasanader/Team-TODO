import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/view/topic_creation_view/categories/category_dialogs.dart';
import '../../../controller/create_topic_controllers/form_controller.dart';

import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';

/// Widget responsible for showing form details
class TopicFormWidget extends StatelessWidget {
  final FormController formController;
  final TopicCreationViewState screen;
  final FirebaseFirestore firestore;

  const TopicFormWidget({
    super.key,
    required this.formController,
    required this.screen,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ChipsChoice<dynamic>.multiple(
            value: formController.tags,
            onChanged: (val) => updateTags(val),
            choiceItems: C2Choice.listFrom<String, String>(
              source: screen.options,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
            choiceCheckmark: true,
            choiceStyle: C2ChipStyle.outlined(),
          ),
        ),
        if (formController.tags.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Please select at least one tag.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        TextFormField(
          key: const Key('titleField'),
          controller: formController.titleController,
          maxLength: 70,
          decoration: const InputDecoration(
            labelText: 'Title *',
            prefixIcon: Icon(Icons.drive_file_rename_outline_outlined),
            border: OutlineInputBorder(),
          ),
          validator: formController.validateTitle,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    CategoryDialogManager(firestore, screen.categoriesOptions,
                            screen.getCategoryList)
                        .createNewCategoryDialog(context);
                  },
                  icon: const Icon(Icons.add)),
              IconButton(
                  onPressed: () {
                    CategoryDialogManager(firestore, screen.categoriesOptions,
                            screen.getCategoryList)
                        .deleteCategoryDialog(context);
                  },
                  icon: const Icon(Icons.close)),
              if (screen.categoriesOptions.isEmpty)
                const Text('Add a category'),
              if (screen.categoriesOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ChipsChoice<dynamic>.multiple(
                    value: formController.categories,
                    onChanged: (val) => updateCategories(val),
                    choiceItems: C2Choice.listFrom<String, String>(
                      source: screen.categoriesOptions,
                      value: (i, v) => v,
                      label: (i, v) => v,
                    ),
                    choiceCheckmark: true,
                    choiceStyle: C2ChipStyle.outlined(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          key: const Key('descField'),
          controller: formController.descriptionController,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Description *',
            prefixIcon: Icon(Icons.description_outlined),
            border: OutlineInputBorder(),
          ),
          validator: formController.validateDescription,
        ),
        const SizedBox(height: 10.0),
        TextFormField(
          key: const Key('linkField'),
          controller: formController.articleLinkController,
          decoration: const InputDecoration(
            labelText: 'Link article',
            prefixIcon: Icon(Icons.link_outlined),
            border: OutlineInputBorder(),
          ),
          validator: formController.validateArticleLink,
        ),
      ],
    );
  }

  void updateCategories(List<dynamic> selectedCategories) {
    formController.categories = selectedCategories;
    screen.updateState();
  }

  void updateTags(List<dynamic> selectedTags) {
    formController.tags = selectedTags;
    screen.updateState();
  }
}
