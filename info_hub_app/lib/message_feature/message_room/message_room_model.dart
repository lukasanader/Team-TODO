class MessageRoom {
  String? adminId; 
  String? patientId;
  String? adminDisplayName;
  String? patientDisplayName;

  MessageRoom({this.adminId, this.patientId, this.adminDisplayName, this.patientDisplayName});


  Map<String, dynamic> toJson() {
    return {
      'adminId': adminId,
      'patientId': patientId,
      'adminDisplayName': adminDisplayName,
      'patientDisplayName': patientDisplayName
    };
  }
}