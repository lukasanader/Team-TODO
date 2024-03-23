import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/topic_model.dart';

class FormController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  Topic? topic;
  Topic? draft;

  FormController(this.auth, this.firestore, this.topic, this.draft);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController articleLinkController = TextEditingController();
  String appBarTitle = "";

  bool editing = false;
  bool drafting = false;
  List<dynamic> tags = [];
  List<dynamic> categories = [];

  void initializeData() {
    editing = topic != null;
    drafting = draft != null;
    appBarTitle = "Create a Topic";
    if (editing) {
      appBarTitle = "Edit Topic";
      String prevTitle = topic!.title!;
      String prevDescription = topic!.description!;
      String prevArticleLink = topic!.articleLink!;
      titleController = TextEditingController(text: prevTitle);
      descriptionController = TextEditingController(text: prevDescription);
      articleLinkController = TextEditingController(text: prevArticleLink);
      tags = topic!.tags!;
    } else if (drafting) {
      appBarTitle = "Draft";
      String prevTitle = draft!.title!;
      String prevDescription = draft!.description!;
      String prevArticleLink = draft!.articleLink!;
      titleController = TextEditingController(text: prevTitle);
      descriptionController = TextEditingController(text: prevDescription);
      articleLinkController = TextEditingController(text: prevArticleLink);
      tags = draft!.tags!;
      categories = draft!.categories!;
    }
  }

  // Validation functions
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Title.';
    }
    return null;
  }

  String? validateArticleLink(String? value) {
    if (value != null && value.isNotEmpty) {
      final url = Uri.tryParse(value);
      if (url == null || !url.hasAbsolutePath || !url.isAbsolute) {
        return 'Link is not valid, please enter a valid link';
      }
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Description';
    }
    return null;
  }
}
