import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRoom {
  String? id;
  String? adminId; 
  String? patientId;
  String? adminDisplayName;
  String? patientDisplayName;

  MessageRoom({this.id, this.adminId, this.patientId, this.adminDisplayName, this.patientDisplayName});

  factory MessageRoom.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return MessageRoom(
      id: snapshot.id,
      adminId: data['adminId'], 
      patientId: data['patientId'],
      adminDisplayName: data['adminDisplayName'],
      patientDisplayName: data['patientDisplayName']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'patientId': patientId,
      'adminDisplayName': adminDisplayName,
      'patientDisplayName': patientDisplayName
    };
  }
}