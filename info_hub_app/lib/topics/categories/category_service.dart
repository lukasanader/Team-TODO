

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/topics/categories/category_model.dart';

class CategoryController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CategoryController(
    this._auth,
    this._firestore
  );

  void addCategory(String name) async {
    Category newCategory = Category();

    newCategory.name = name;

    CollectionReference db = _firestore.collection('categories');
    await db.add(newCategory.toJson());
  }

  void deleteCategory(String categoryName) async {
    QuerySnapshot categoryToDelete = await _firestore
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    QueryDocumentSnapshot category = categoryToDelete.docs[0];
    await _firestore.collection('categories').doc(category.id).delete();
  }

  Future<List<Category>> getCategoryList() async {
    QuerySnapshot data =
        await _firestore.collection('categories').orderBy('name').get();

    List<Category> categoryList = List.from(data.docs.map((doc) => Category.fromSnapshot(doc)));

    return categoryList;
  }


}