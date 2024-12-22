import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String fixedCategory = 'Umum';
  List<String> _customCategories = [];

  List<String> get categories => [fixedCategory, ..._customCategories];

  /// Memuat kategori dari Firebase
  Future<void> fetchCategories(String userId) async {
    final snapshot = await _firestore
    .collection('category')
    .where('userId', isEqualTo: userId)
    .get();
    _customCategories = snapshot.docs
        .map((doc) => doc['name'] as String)
        .where((name) => name != fixedCategory) // Pastikan tidak memuat ulang "Umum"
        .toList();
    notifyListeners();
  }

  /// Menambahkan kategori baru
  Future<void> addCategory(String userId, String category) async {
    if (!_customCategories.contains(category) && category != fixedCategory) {
      await _firestore
      .collection('category')
      .add({'name': category});
      _customCategories.add(category);
      notifyListeners();
    }
  }

  /// Mengedit kategori
  Future<void> editCategory(String userId, String oldCategory, String newCategory) async {
    final query = await _firestore
  .collection('category')
        .where('name', isEqualTo: oldCategory)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await _firestore
    .collection('category')
      .doc(docId)
      .update({'name': newCategory});
      final index = _customCategories.indexOf(oldCategory);
      if (index != -1) {
        _customCategories[index] = newCategory;
        notifyListeners();
      }
    }
  }

  /// Menghapus kategori
  Future<void> deleteCategory(String userId, String category) async {
    if (category != fixedCategory) {
      final query = await _firestore
 .collection('category')
          .where('name', isEqualTo: category)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await _firestore
    .collection('category')
        .doc(docId).delete();
        _customCategories.remove(category);
        notifyListeners();
      }
    }
  }
}
