import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String nameHi;
  final String nameGu;
  final String description;
  final String descriptionHi;
  final String descriptionGu;
  final double price; // Selling Price
  final double costPrice; // Cost Price for profit calculation
  final double? comparePrice; // Original Price for discount display
  final double? discountPrice; // Legacy field for compatibility
  final String categoryId;
  final String sku;
  final String consecrationBadge; // e.g., Sanctified, Bestseller
  final String shortSummary;
  final String shortSummaryHi;
  final String shortSummaryGu;
  final List<String> highlights;
  final List<String> highlightsHi;
  final List<String> highlightsGu;
  final String imageUrl; 
  final List<String> imageUrls; 
  final List<String> finishes;
  final List<String> sizes;
  final int stock;
  final int minStockAlert;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int salesCount;
  final double rating;
  final int reviewCount;

  // Compatibility & Utility getters
  bool get isAvailable => isActive && stock > 0;
  int get stockCount => stock;
  bool get isPopular => salesCount > 50 || consecrationBadge == 'Popular'; 
  bool get isNew => consecrationBadge == 'New Arrival';
  String get title => name;
  String get category => categoryId;

  // Calculate discount percentage
  int get discountPercentage {
    if (comparePrice == null || comparePrice! <= price) return 0;
    return (((comparePrice! - price) / comparePrice!) * 100).round();
  }

  ProductModel({
    required this.id,
    required this.name,
    this.nameHi = '',
    this.nameGu = '',
    this.description = '',
    this.descriptionHi = '',
    this.descriptionGu = '',
    required this.price,
    this.costPrice = 0.0,
    this.comparePrice,
    this.discountPrice,
    required this.categoryId,
    this.sku = '',
    this.consecrationBadge = '',
    this.shortSummary = '',
    this.shortSummaryHi = '',
    this.shortSummaryGu = '',
    this.highlights = const [],
    this.highlightsHi = const [],
    this.highlightsGu = const [],
    this.imageUrl = '',
    this.imageUrls = const [],
    this.finishes = const [],
    this.sizes = const [],
    this.stock = 0,
    this.minStockAlert = 5,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.salesCount = 0,
    this.rating = 4.9,
    this.reviewCount = 0,
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
    double? costPrice,
    double? comparePrice,
    double? discountPrice,
    String? categoryId,
    String? sku,
    String? consecrationBadge,
    String? shortSummary,
    String? shortSummaryHi,
    String? shortSummaryGu,
    List<String>? highlights,
    List<String>? highlightsHi,
    List<String>? highlightsGu,
    String? imageUrl,
    List<String>? imageUrls,
    List<String>? finishes,
    List<String>? sizes,
    int? stock,
    int? minStockAlert,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? salesCount,
    double? rating,
    int? reviewCount,
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
      costPrice: costPrice ?? this.costPrice,
      comparePrice: comparePrice ?? this.comparePrice,
      discountPrice: discountPrice ?? this.discountPrice,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      consecrationBadge: consecrationBadge ?? this.consecrationBadge,
      shortSummary: shortSummary ?? this.shortSummary,
      shortSummaryHi: shortSummaryHi ?? this.shortSummaryHi,
      shortSummaryGu: shortSummaryGu ?? this.shortSummaryGu,
      highlights: highlights ?? this.highlights,
      highlightsHi: highlightsHi ?? this.highlightsHi,
      highlightsGu: highlightsGu ?? this.highlightsGu,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      finishes: finishes ?? this.finishes,
      sizes: sizes ?? this.sizes,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      salesCount: salesCount ?? this.salesCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Defensive parsing for lists
    List<String> parseList(dynamic field) {
      if (field is List) return List<String>.from(field.map((e) => e.toString()));
      return [];
    }

    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameHi: data['nameHi'] ?? '',
      nameGu: data['nameGu'] ?? '',
      description: data['description'] ?? '',
      descriptionHi: data['descriptionHi'] ?? '',
      descriptionGu: data['descriptionGu'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      costPrice: (data['costPrice'] ?? 0.0).toDouble(),
      comparePrice: data['comparePrice'] != null ? (data['comparePrice'] as num).toDouble() : null,
      discountPrice: data['discountPrice'] != null ? (data['discountPrice'] as num).toDouble() : null,
      categoryId: data['categoryId'] ?? '',
      sku: data['sku'] ?? '',
      consecrationBadge: data['consecrationBadge'] ?? '',
      shortSummary: data['shortSummary'] ?? '',
      shortSummaryHi: data['shortSummaryHi'] ?? '',
      shortSummaryGu: data['shortSummaryGu'] ?? '',
      highlights: parseList(data['highlights']),
      highlightsHi: parseList(data['highlightsHi']),
      highlightsGu: parseList(data['highlightsGu']),
      imageUrl: data['imageUrl'] ?? '',
      imageUrls: parseList(data['imageUrls']),
      finishes: parseList(data['finishes']),
      sizes: parseList(data['sizes']),
      stock: data['stock'] ?? 0,
      minStockAlert: data['minStockAlert'] ?? 5,
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      salesCount: data['salesCount'] ?? 0,
      rating: (data['rating'] ?? 4.9).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameLower': name.toLowerCase(),
      'nameHi': nameHi,
      'nameGu': nameGu,
      'description': description,
      'descriptionHi': descriptionHi,
      'descriptionGu': descriptionGu,
      'price': price,
      'costPrice': costPrice,
      'comparePrice': comparePrice,
      'discountPrice': discountPrice,
      'categoryId': categoryId.toLowerCase().trim(), 
      'sku': sku,
      'consecrationBadge': consecrationBadge,
      'shortSummary': shortSummary,
      'shortSummaryHi': shortSummaryHi,
      'shortSummaryGu': shortSummaryGu,
      'highlights': highlights,
      'highlightsHi': highlightsHi,
      'highlightsGu': highlightsGu,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'finishes': finishes,
      'sizes': sizes,
      'stock': stock,
      'minStockAlert': minStockAlert,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'salesCount': salesCount,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  Map<String, dynamic> toUpdateFirestore() {
    final map = toFirestore();
    map.remove('createdAt'); 
    return map;
  }

  String localizedName(String langCode) {
    if (langCode == 'hi' && nameHi.isNotEmpty) return nameHi;
    if (langCode == 'gu' && nameGu.isNotEmpty) return nameGu;
    return name;
  }

  String localizedDescription(String langCode) {
    if (langCode == 'hi' && descriptionHi.isNotEmpty) return descriptionHi;
    if (langCode == 'gu' && descriptionGu.isNotEmpty) return descriptionGu;
    return description;
  }

  String localizedShortSummary(String langCode) {
    if (langCode == 'hi' && shortSummaryHi.isNotEmpty) return shortSummaryHi;
    if (langCode == 'gu' && shortSummaryGu.isNotEmpty) return shortSummaryGu;
    return shortSummary;
  }

  List<String> localizedHighlights(String langCode) {
    if (langCode == 'hi' && highlightsHi.isNotEmpty) return highlightsHi;
    if (langCode == 'gu' && highlightsGu.isNotEmpty) return highlightsGu;
    return highlights;
  }
}
