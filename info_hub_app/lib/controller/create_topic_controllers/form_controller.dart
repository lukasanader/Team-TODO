import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/topic_model.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'media_upload_controller.dart';
import 'dart:typed_data';

/// Controller class responsible for managing the form data and actions in the topic creation process.
class FormController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Topic? topic;
  Topic? draft;
  TopicCreationViewState screen;
  MediaUploadController? mediaUploadController;

  FormController(this.auth, this.firestore, this.topic, this.draft, this.screen,
      this.mediaUploadController);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController articleLinkController = TextEditingController();
  String appBarTitle = "";
  String? downloadURL;
  bool editing = false;
  bool drafting = false;
  List<dynamic> tags = [];
  List<dynamic> categories = [];

  /// Initializes form data based on whether the form is for editing an existing topic or creating a new one.
  void initializeData() {
    editing = topic != null;
    drafting = draft != null;
    appBarTitle = "Create a Topic";
    // if editing the topic or drafting, form fields should be initialized to their previous value
    if (editing) {
      appBarTitle = "Edit Topic";
      String prevTitle = topic!.title!;
      String prevDescription = topic!.description!;
      String prevArticleLink = topic!.articleLink!;
      titleController = TextEditingController(text: prevTitle);
      descriptionController = TextEditingController(text: prevDescription);
      articleLinkController = TextEditingController(text: prevArticleLink);
      tags = topic!.tags!;
      screen.updatedTopicDoc = topic!;
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

  // Form Validation functions

  /// Validates the title field.
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Title.';
    }
    return null;
  }

  /// Validates the article link field.
  String? validateArticleLink(String? value) {
    if (value != null && value.isNotEmpty) {
      final url = Uri.tryParse(value);
      if (url == null || !url.hasAbsolutePath || !url.isAbsolute) {
        return 'Link is not valid, please enter a valid link';
      }
    }
    return null;
  }

  /// Validates the description field.
  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Description';
    }
    return null;
  }

  /// Uploads the topic to Firestore, either as a draft or for publishing.
  Future<Topic> uploadTopic(context, bool saveAsDraft) async {
    List<Map<String, String>> mediaList = [];
    Topic newTopic = Topic();
    Uint8List thumbnailData;
    String? thumbnailUrl;
    for (var item in mediaUploadController!.mediaUrls) {
      String url = item['url']!;
      String mediaType = item['mediaType']!;

      if (mediaUploadController!.networkUrls.contains(url)) {
        downloadURL = url;
        thumbnailUrl = item['thumbnail'];
      } else {
        downloadURL = await mediaUploadController!.uploadMediaToStorage(url);
        if (mediaType == "video") {
          thumbnailData =
              await mediaUploadController!.getVideoThumbnailFromFile(url);

          thumbnailUrl = await mediaUploadController!
              .uploadThumbnailToStorage(thumbnailData);
        }
      }

      Map<String, String> uploadData = {
        'url': downloadURL!,
        'mediaType': mediaType,
        'thumbnail': mediaType == "image" ? downloadURL! : thumbnailUrl!
      };

      mediaList.add(uploadData);
    }

    CollectionReference topicCollectionRef = firestore.collection('topics');

    if (!editing && !drafting) {
      newTopic = Topic(
        title: titleController.text,
        description: descriptionController.text,
        articleLink: articleLinkController.text,
        media: mediaList,
        views: 0,
        likes: 0,
        dislikes: 0,
        tags: tags,
        categories: categories,
        date: DateTime.now(),
        quizID: screen.quizID,
      );
      if (saveAsDraft) {
        newTopic.userID = auth.currentUser?.uid;
        CollectionReference topicDraftsCollectionRef =
            firestore.collection('topicDrafts');
        final topicDraftRef =
            await topicDraftsCollectionRef.add(newTopic.toJson());
        final user = auth.currentUser;
        if (user != null) {
          final userDocRef = firestore.collection('Users').doc(user.uid);
          await userDocRef.update({
            'draftedTopics': FieldValue.arrayUnion([topicDraftRef.id])
          });
        }
      } else {
        final docRef = await topicCollectionRef.add(newTopic.toJson());
        newTopic.id = docRef.id;
      }
    } else {
      if (topic != null && topic!.quizID != '') {
        screen.quizID = topic!.quizID!;
      }
      newTopic = Topic(
          title: titleController.text,
          description: descriptionController.text,
          articleLink: articleLinkController.text,
          media: mediaList,
          views: editing ? topic!.views : draft!.views,
          likes: editing ? topic!.likes : draft!.likes,
          categories: categories,
          dislikes: editing ? topic!.dislikes : draft!.dislikes,
          date: editing ? topic!.date : draft!.date,
          tags: tags,
          quizID: screen.quizID);

      for (var item in mediaUploadController!.originalUrls) {
        if (!mediaList
            .map((map) => map['url'])
            .toList()
            .contains(item['url'])) {
          mediaUploadController!.deleteMediaFromStorage(item['url']);
          mediaUploadController!.deleteMediaFromStorage(item['thumbnail']);
        }
      }

      if (editing) {
        await topicCollectionRef.doc(topic!.id).update(newTopic.toJson());
        screen.updatedTopicDoc = newTopic;
      } else if (drafting) {
        await topicCollectionRef.add(newTopic.toJson());
        deleteDraft();
      }
      if (editing) {}
    }

    return newTopic;
  }

  /// Deletes the current draft from Firestore.
  void deleteDraft() async {
    final user = auth.currentUser;
    if (user != null) {
      final userDocRef = firestore.collection('Users').doc(user.uid);

      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Get the current list of drafted topics
        List<String> draftedTopics =
            List<String>.from(userDoc['draftedTopics']);

        // Remove the current draft ID from the list
        draftedTopics.remove(draft!.id);

        // Update the user document with the modified draftedTopics list
        await userDocRef.update({
          'draftedTopics': draftedTopics,
        });

        // Delete the draft from the topicDrafts collection
        await firestore.collection('topicDrafts').doc(draft!.id).delete();
      }
    }
  }
}
