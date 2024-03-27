import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/topic_model.dart';
import 'package:info_hub_app/topics/view_topic/view/topic_view.dart';
import 'package:info_hub_app/controller/activity_controller.dart';
import 'media_controller.dart';

/// Controller class responsible for managing the form data and actions in the topic creation process.
class InteractionController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  Topic topic;
  TopicViewState screen;
  MediaController mediaController;

  InteractionController(
      this.auth, this.firestore, this.screen, this.topic, this.mediaController);

  bool hasLiked = false;
  bool hasDisliked = false;
  int likes = 0;
  int dislikes = 0;
  bool saved = false;

  /// Initializes form data based on whether the form is for editing an existing topic or creating a new one.
  void initializeData() {
    checkUserLikedAndDislikedTopics();
    updateLikesAndDislikesCount();
    hasSavedTopic();
  }

  Future<bool> hasLikedTopic() async {
    User? user = auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await firestore.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          List<dynamic>? likedTopics = userData['likedTopics'];

          if (likedTopics != null && likedTopics.contains(topic.id)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<bool> hasDislikedTopic() async {
    User? user = auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await firestore.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          List<dynamic>? dislikedTopics = userData['dislikedTopics'];

          if (dislikedTopics != null && dislikedTopics.contains(topic.id)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void updateLikesAndDislikesCount() {
    firestore.collection('topics').doc(topic.id).get().then((doc) {
      likes = doc['likes'];
      dislikes = doc['dislikes'];
      screen.updateState();
    });
  }

  Future<void> likeTopic() async {
    final user = auth.currentUser;

    if (user != null) {
      final userDocRef = firestore.collection('Users').doc(user.uid);

      if (hasLiked) {
        likes -= 1;
        await userDocRef.update({
          'likedTopics': FieldValue.arrayRemove([topic.id])
        });
        hasLiked = false;
      } else {
        likes += 1;
        await userDocRef.update({
          'likedTopics': FieldValue.arrayUnion([topic.id])
        });
        hasLiked = true;

        if (hasDisliked) {
          dislikes -= 1;
          await userDocRef.update({
            'dislikedTopics': FieldValue.arrayRemove([topic.id])
          });
          hasDisliked = false;
        }
      }

      screen.updateState();

      firestore
          .collection('topics')
          .doc(topic.id)
          .update({'likes': likes, 'dislikes': dislikes});
    }
  }

  Future<void> dislikeTopic() async {
    final user = auth.currentUser;

    if (user != null) {
      final userDocRef = firestore.collection('Users').doc(user.uid);

      if (hasDisliked) {
        dislikes -= 1;
        await userDocRef.update({
          'dislikedTopics': FieldValue.arrayRemove([topic.id])
        });
        hasDisliked = false;
      } else {
        dislikes += 1;
        await userDocRef.update({
          'dislikedTopics': FieldValue.arrayUnion([topic.id])
        });
        hasDisliked = true;

        if (hasLiked) {
          likes -= 1;
          await userDocRef.update({
            'likedTopics': FieldValue.arrayRemove([topic.id])
          });
          hasLiked = false;
        }
      }

      screen.updateState();

      firestore
          .collection('topics')
          .doc(topic.id)
          .update({'dislikes': dislikes, 'likes': likes});
    }
  }

  Future<void> checkUserLikedAndDislikedTopics() async {
    hasLiked = await hasLikedTopic();
    hasDisliked = await hasDislikedTopic();
  }

  Future<void> hasSavedTopic() async {
    final user = auth.currentUser;
    if (user != null) {
      final userDocSnapshot =
          await firestore.collection('Users').doc(user.uid).get();

      if (userDocSnapshot.exists) {
        Map<String, dynamic> userData = userDocSnapshot.data()!;

        if (userData['savedTopics'] != null) {
          saved = userData['savedTopics'].contains(topic.id);
        }
      }
    }
  }

  Future<void> saveTopic() async {
    final user = auth.currentUser;
    if (user != null) {
      final userDocRef = firestore.collection('Users').doc(user.uid);
      if (!saved) {
        await userDocRef.update({
          'savedTopics': FieldValue.arrayUnion([topic.id])
        });
        saved = true;
      } else {
        await userDocRef.update({
          'savedTopics': FieldValue.arrayRemove([topic.id])
        });
        saved = false;
      }
      screen.updateState();
    }
  }

  Future<void> removeTopicFromUsers() async {
    // get all users
    QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await firestore.collection('Users').get();

    // go through each user
    for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
        in usersSnapshot.docs) {
      Map<String, dynamic> userData = userSnapshot.data();

      // Check if user has liked topic
      if (userData.containsKey('likedTopics') &&
          userData['likedTopics'].contains(topic.id)) {
        // Remove the topic from liked topics list
        userData['likedTopics'].remove(topic.id);
      }

      // Check if user has disliked topic
      if (userData.containsKey('dislikedTopics') &&
          userData['dislikedTopics'].contains(topic.id)) {
        // Remove the topic from disliked topics list
        userData['dislikedTopics'].remove(topic.id);
      }

      if (userData.containsKey('savedTopics') &&
          userData['savedTopics'].contains(topic.id)) {
        // Remove the topic from saved topics list
        userData['savedTopics'].remove(topic.id);
      }

      await userSnapshot.reference.update(userData);
    }
  }

  deleteTopic() async {
    ActivityController(firestore: firestore, auth: auth)
        .deleteActivity(topic.id!);
    removeTopicFromUsers();
    // If the topic has a video URL, delete the corresponding video from storage
    if (topic.media!.isNotEmpty) {
      for (var item in topic.media!) {
        await mediaController
            .deleteMediaFromStorage(topic.media!.indexOf(item));
      }
    }

    // Delete the topic document from Firestore
    await firestore.collection('topics').doc(topic.id).delete();

    screen.popScreen();
  }
}
