import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String nameHi;
  final String nameGu;
  final String description;
  final String descriptionHi;
  final String descriptionGu;
  final String imageUrl;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.nameHi = '',
    this.nameGu = '',
    this.description = '',
    this.descriptionHi = '',
    this.descriptionGu = '',
    required this.imageUrl,
    this.iconUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? nameHi,
    String? nameGu,
    String? description,
    String? descriptionHi,
    String? descriptionGu,
    String? imageUrl,
    String? iconUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameHi: nameHi ?? this.nameHi,
      nameGu: nameGu ?? this.nameGu,
      description: description ?? this.description,
      descriptionHi: descriptionHi ?? this.descriptionHi,
      descriptionGu: descriptionGu ?? this.descriptionGu,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameHi: data['nameHi'] ?? '',
      nameGu: data['nameGu'] ?? '',
      description: data['description'] ?? '',
      descriptionHi: data['descriptionHi'] ?? '',
      descriptionGu: data['descriptionGu'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      iconUrl: data['iconUrl'],
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameHi': nameHi,
      'nameGu': nameGu,
      'description': description,
      'descriptionHi': descriptionHi,
      'descriptionGu': descriptionGu,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String localizedName(String langCode) {
    if (langCode == 'hi' && nameHi.isNotEmpty) return nameHi;
    if (langCode == 'gu' && nameGu.isNotEmpty) return nameGu;
    return name;
  }
}
