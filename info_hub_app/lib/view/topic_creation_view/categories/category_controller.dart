import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/view/topic_creation_view/categories/category_model.dart';

class CategoryController {
  final FirebaseFirestore _firestore;

  CategoryController(this._firestore);

  void addCategory(String name) async {
    Category newCategory = Category();

    newCategory.name = name;

    CollectionReference db = _firestore.collection('categories');
    await db.add(newCategory.toJson());
  }

  ///deletes category and removes cateogry from all topics with said category
  void deleteCategory(Category category) async {
    await _firestore.collection('categories').doc(category.id).delete();

    QuerySnapshot topicsWithCategory = await _firestore
        .collection('topics')
        .where('categories', arrayContains: category.name)
        .get();

    for (QueryDocumentSnapshot topic in topicsWithCategory.docs) {
      final topicReference = topic.reference;
      await topicReference.update({
        'categories': FieldValue.arrayRemove([category.name])
      });
    }
  }

  ///returns the category based on the name - category names are unique by
  ///design
  Future<Category> getCategoryFromName(String categoryName) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    QueryDocumentSnapshot queryDocumentSnapshot = querySnapshot.docs[0];
    Category category = Category.fromSnapshot(queryDocumentSnapshot);

    return category;
  }

  ///returns list of all existing categories
  Future<List<Category>> getCategoryList() async {
    QuerySnapshot data =
        await _firestore.collection('categories').orderBy('name').get();

    List<Category> categoryList =
        List.from(data.docs.map((doc) => Category.fromSnapshot(doc)));

    return categoryList;
  }
}
