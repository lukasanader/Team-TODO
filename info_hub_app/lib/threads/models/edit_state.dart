import 'package:flutter/material.dart';

class EditState with ChangeNotifier {
  bool _isEdited = false;

  bool get isEdited => _isEdited;

  void setEdited(bool edited) {
    _isEdited = edited;
    notifyListeners();
  }
}
