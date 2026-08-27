import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final double? discountPrice;
  final List<String> imageUrls;
  final String categoryId;
  final int stockCount;
  final bool isAvailable;
  final bool isFeatured;
  final bool isPopular;
  final DateTime? createdAt;
  final int salesCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice,
    this.imageUrls = const [],
    required this.categoryId,
    this.stockCount = 0,
    this.isAvailable = true,
    this.isFeatured = false,
    this.isPopular = false,
    this.createdAt,
    this.salesCount = 0,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      discountPrice: data['discountPrice'] != null ? (data['discountPrice'] as num).toDouble() : null,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      categoryId: data['categoryId'] ?? '',
      stockCount: data['stockCount'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      isPopular: data['isPopular'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      salesCount: data['salesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'stockCount': stockCount,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'salesCount': salesCount,
    };
  }
}
