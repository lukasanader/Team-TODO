import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CustomCard extends StatelessWidget {
  final QuerySnapshot? snapshot;
  final int index;

  const CustomCard({Key? key, this.snapshot, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var docData = snapshot!.docs[index].data()
        as Map<String, dynamic>; // Cast the document data to a Map
    var title = docData['title'] ?? 'No title';
    var description = docData['description'] ?? 'No description';
    var timestamp = docData['timestamp']?.toDate();
    'Timestamp not available'; // Safely access the timestamp
    var formatter = timestamp != null
        ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp)
        : 'Timestamp not available';

    return Column(
      children: <Widget>[
        Container(
          height: 125,
          child: Card(
            elevation: 8.5,
            child: ListTile(
              title: Text(title),
              subtitle: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align the text to the start
                mainAxisSize: MainAxisSize.min, // Use minimum space
                children: <Widget>[
                  Text(description), // The original subtitle text
                  Padding(padding: const EdgeInsets.all(2)),
                  const SizedBox(
                      height:
                          4), // Add some spacing between the description and the timestamp
                  Text(
                    //"posted " +
                    formatter,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                ],
              ),
              leading: CircleAvatar(
                radius: 34,
                child: Text(title[
                    0]), // Assumes title is not empty place holder for avatar
              ),
            ),
          ),
        ),
        //Text(timestamp), // Display the timestamp or 'Timestamp not available'
      ],
    );
  }

  /*

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //Text(snapshot!.docs[index]['title'])
        Container(
          height: 125,
          child: Card(
            elevation: 8.5,
            child: ListTile(
              title: Text(snapshot!.docs[index]['title']),
              subtitle: Text(snapshot!.docs[index]['description']),
              leading: CircleAvatar(
                radius: 34,
                child: Text(snapshot!.docs[index]['title'].toString()[0]),
              ),
            ),
          ),
        ),
        Text(
          snapshot!.docs[index]['timestamp'] == null
              ? 'Timestamp not available'
              : snapshot!.docs[index]['timestamp'].toString(),
        )
      ],
    );
  }
*/
}
