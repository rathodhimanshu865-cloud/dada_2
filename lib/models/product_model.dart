import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String nameHi;
  final String nameGu;
  final String description;
  final String descriptionHi;
  final String descriptionGu;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final String imageUrl; 
  final List<String> imageUrls; 
  final int stock;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int salesCount;

  // Compatibility & Utility getters
  bool get isAvailable => isActive && stock > 0;
  int get stockCount => stock;
  bool get isPopular => salesCount > 50; 
  bool get isNew => createdAt != null && DateTime.now().difference(createdAt!).inDays < 30;
  String get title => name;
  String get category => categoryId;

  ProductModel({
    required this.id,
    required this.name,
    this.nameHi = '',
    this.nameGu = '',
    this.description = '',
    this.descriptionHi = '',
    this.descriptionGu = '',
    required this.price,
    this.discountPrice,
    required this.categoryId,
    this.imageUrl = '',
    this.imageUrls = const [],
    this.stock = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.salesCount = 0,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? nameHi,
    String? nameGu,
    String? description,
    String? descriptionHi,
    String? descriptionGu,
    double? price,
    double? discountPrice,
    String? categoryId,
    String? imageUrl,
    List<String>? imageUrls,
    int? stock,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? salesCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameHi: nameHi ?? this.nameHi,
      nameGu: nameGu ?? this.nameGu,
      description: description ?? this.description,
      descriptionHi: descriptionHi ?? this.descriptionHi,
      descriptionGu: descriptionGu ?? this.descriptionGu,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      salesCount: salesCount ?? this.salesCount,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameHi: data['nameHi'] ?? '',
      nameGu: data['nameGu'] ?? '',
      description: data['description'] ?? '',
      descriptionHi: data['descriptionHi'] ?? '',
      descriptionGu: data['descriptionGu'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      discountPrice: data['discountPrice'] != null ? (data['discountPrice'] as num).toDouble() : null,
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      stock: data['stock'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      salesCount: data['salesCount'] ?? 0,
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
      'price': price,
      'discountPrice': discountPrice,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'stock': stock,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'salesCount': salesCount,
    };
  }

  // Returns the localized name based on language code
  String localizedName(String langCode) {
    if (langCode == 'hi' && nameHi.isNotEmpty) return nameHi;
    if (langCode == 'gu' && nameGu.isNotEmpty) return nameGu;
    return name;
  }
}
