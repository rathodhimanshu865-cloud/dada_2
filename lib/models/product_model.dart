import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  String title;
  String slug;
  String description;
  double? price;
  List<String> images;
  String category;
  bool featured;
  bool visible;
  DateTime? createdAt;
  DateTime? updatedAt;

  Product({
    this.id = '',
    this.title = '',
    this.slug = '',
    this.description = '',
    this.price,
    List<String>? images,
    this.category = '',
    this.featured = false,
    this.visible = true,
    this.createdAt,
    this.updatedAt,
  }) : images = images ?? [];

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'slug': slug,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'featured': featured,
      'visible': visible,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      title: map['title'] ?? '',
      slug: map['slug'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      featured: map['featured'] ?? false,
      visible: map['visible'] ?? true,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Product copyWith({
    String? id,
    String? title,
    String? slug,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    bool? featured,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      category: category ?? this.category,
      featured: featured ?? this.featured,
      visible: visible ?? this.visible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
