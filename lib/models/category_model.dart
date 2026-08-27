import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? iconUrl;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.iconUrl,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      iconUrl: data['iconUrl'],
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'sortOrder': sortOrder,
    };
  }
}
