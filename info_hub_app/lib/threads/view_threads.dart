import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewThreads extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ViewThreads({Key? key, required this.firestore, required this.auth})
      : super(key: key);

  @override
  State<ViewThreads> createState() => _ViewThreadsState();
}

class _ViewThreadsState extends State<ViewThreads> {
  late Stream<QuerySnapshot> threadsStream;

  @override
  void initState() {
    super.initState();
    threadsStream = widget.firestore.collection("thread").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Threads"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: threadsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> thread =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.comment),
                title: Text(thread['title'] ?? 'No Title'),
                subtitle: Text('Author: ${thread['author']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteThread(document.id),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void deleteThread(String threadId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Thread'),
          content: const Text(
              "Are you sure you want to delete this thread and all its replies?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first

                // Delete all replies associated with the thread
                final replyQuerySnapshot = await widget.firestore
                    .collection("replies")
                    .where('threadId', isEqualTo: threadId)
                    .get();

                final WriteBatch batch = widget.firestore.batch();
                for (DocumentSnapshot replyDoc in replyQuerySnapshot.docs) {
                  batch.delete(replyDoc.reference);
                }

                // Commit the batch deletion of replies
                await batch.commit();

                // Now delete the thread itself
                await widget.firestore
                    .collection("thread")
                    .doc(threadId)
                    .delete();
              },
            ),
          ],
        );
      },
    );
  }
}
