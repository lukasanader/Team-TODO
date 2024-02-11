import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class adminHomepage extends StatefulWidget {
  final FirebaseFirestore firestore;
  const adminHomepage({Key? key, required this.firestore});
  @override
  _adminHomepageState createState() => _adminHomepageState();
}

class _adminHomepageState extends State<adminHomepage>{
final TextEditingController _searchController = TextEditingController();
List<Object> _userList = [];
List<bool> selected = [];

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserList();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: (){
          selectUserDialog();
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add),
            Text(
              'Add admin',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    ),
  );
}

void selectUserDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context,) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
      return AlertDialog(
        title: TextField(
          controller: _searchController,
          onChanged: (query) async{
            await getUserList();
            setState((){});
          },
        ),
        content: SizedBox (
        height: 300,
        width: 200,
        child: 
        ListView.builder(
          itemCount: _userList.isEmpty ? 1: _userList.length,
          itemBuilder: (context, index) {
            if(_userList.isEmpty){
              return const ListTile(
                title: Text("Sorry there are no healthcare professionals matching this email."),
              );
            }else{
              return ListTile(
                title: Text(getEmail(_userList[index] as QueryDocumentSnapshot)),
                onTap: () {
                  setState(() {
                    selected[index] = !selected[index];
                  });
                  
                },
                tileColor: selected[index] ? Colors.blue.withOpacity(0.5) : null,
              );
          }
          }
        )
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              addAdmins();
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    }
    );
    }
    
  );
}

Future getUserList() async {
   QuerySnapshot data = await widget.firestore.collection('Users')
   .where('roleType', isEqualTo: 'Healthcare Professional')
   .get();
   List<Object> tempList= List.from(data.docs);
   String search = _searchController.text;
   if(search.isNotEmpty){
    for(int i=0; i< tempList.length; i++) {
      QueryDocumentSnapshot user = tempList[i] as QueryDocumentSnapshot;
      String email = user['email'].toString().toLowerCase();
      if (!email.contains(search.toLowerCase())) {
        tempList.removeAt(i);
        i=i-1;
      }
    }
   }
   setState(() {
     _userList=tempList;
     selected = List<bool>.filled(_userList.length, false);
   });
}

String getEmail(QueryDocumentSnapshot user){
  return user['email'];
}

void addAdmins() async {
  List<int> indicesToRemove = [];
  List<dynamic> selectedUsers = [];
  for (int i = 0; i < selected.length; i++) {
    if (selected[i]) {
      selectedUsers.add(_userList[i]);
      indicesToRemove.add(i); // Add the selected item to the list
    }
  }
  for (int i = 0; i < selectedUsers.length; i++) {
    await widget.firestore.collection('Users')
    .doc(selectedUsers[i].id).update({'roleType': 'admin'});
  }
  getUserList(); //refreshes the list
}
}
