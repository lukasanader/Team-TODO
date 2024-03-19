import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRoom {
  String? adminId; 
  String? patientId;

  MessageRoom({this.adminId, this.patientId});


  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'patientId': patientId,
    };
  }
}