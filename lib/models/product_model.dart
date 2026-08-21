import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_variant_model.dart';

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

  // New fields
  String productType; // physical, digital, ticket, bundle
  String sku;
  int stockQuantity;
  int lowStockThreshold;
  String stockStatus; // In Stock, Out of Stock, Pre-order
  double? salePrice;
  DateTime? saleStartDate;
  DateTime? saleEndDate;
  List<String> badges;
  String author;
  String? videoUrl;
  String? audioSampleUrl;
  double? weight;
  String? dimensions;
  String? shippingClass;
  List<String> keyHighlights;
  String? aboutItem;
  List<ProductVariant> variants;
  String? digitalFileUrl;
  int? downloadLimit;
  String? eventId;
  String? metaTitle;
  String? metaDescription;

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
    this.productType = 'physical',
    this.sku = '',
    this.stockQuantity = 0,
    this.lowStockThreshold = 5,
    this.stockStatus = 'In Stock',
    this.salePrice,
    this.saleStartDate,
    this.saleEndDate,
    List<String>? badges,
    this.author = 'Jignesh Dada',
    this.videoUrl,
    this.audioSampleUrl,
    this.weight,
    this.dimensions,
    this.shippingClass,
    List<String>? keyHighlights,
    this.aboutItem,
    List<ProductVariant>? variants,
    this.digitalFileUrl,
    this.downloadLimit,
    this.eventId,
    this.metaTitle,
    this.metaDescription,
  })  : images = images ?? [],
        badges = badges ?? [],
        keyHighlights = keyHighlights ?? [],
        variants = variants ?? [];

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
      'productType': productType,
      'sku': sku,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'stockStatus': stockStatus,
      'salePrice': salePrice,
      'saleStartDate': saleStartDate != null ? Timestamp.fromDate(saleStartDate!) : null,
      'saleEndDate': saleEndDate != null ? Timestamp.fromDate(saleEndDate!) : null,
      'badges': badges,
      'author': author,
      'videoUrl': videoUrl,
      'audioSampleUrl': audioSampleUrl,
      'weight': weight,
      'dimensions': dimensions,
      'shippingClass': shippingClass,
      'keyHighlights': keyHighlights,
      'aboutItem': aboutItem,
      'variants': variants.map((v) => v.toMap()).toList(),
      'digitalFileUrl': digitalFileUrl,
      'downloadLimit': downloadLimit,
      'eventId': eventId,
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
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
      productType: map['productType'] ?? 'physical',
      sku: map['sku'] ?? '',
      stockQuantity: map['stockQuantity']?.toInt() ?? 0,
      lowStockThreshold: map['lowStockThreshold']?.toInt() ?? 5,
      stockStatus: map['stockStatus'] ?? 'In Stock',
      salePrice: map['salePrice']?.toDouble(),
      saleStartDate: map['saleStartDate'] != null ? (map['saleStartDate'] as Timestamp).toDate() : null,
      saleEndDate: map['saleEndDate'] != null ? (map['saleEndDate'] as Timestamp).toDate() : null,
      badges: List<String>.from(map['badges'] ?? []),
      author: map['author'] ?? 'Jignesh Dada',
      videoUrl: map['videoUrl'],
      audioSampleUrl: map['audioSampleUrl'],
      weight: map['weight']?.toDouble(),
      dimensions: map['dimensions'],
      shippingClass: map['shippingClass'],
      keyHighlights: List<String>.from(map['keyHighlights'] ?? []),
      aboutItem: map['aboutItem'],
      variants: (map['variants'] as List<dynamic>?)?.map((v) => ProductVariant.fromMap(v)).toList() ?? [],
      digitalFileUrl: map['digitalFileUrl'],
      downloadLimit: map['downloadLimit']?.toInt(),
      eventId: map['eventId'],
      metaTitle: map['metaTitle'],
      metaDescription: map['metaDescription'],
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
    String? productType,
    String? sku,
    int? stockQuantity,
    int? lowStockThreshold,
    String? stockStatus,
    double? salePrice,
    DateTime? saleStartDate,
    DateTime? saleEndDate,
    List<String>? badges,
    String? author,
    String? videoUrl,
    String? audioSampleUrl,
    double? weight,
    String? dimensions,
    String? shippingClass,
    List<String>? keyHighlights,
    String? aboutItem,
    List<ProductVariant>? variants,
    String? digitalFileUrl,
    int? downloadLimit,
    String? eventId,
    String? metaTitle,
    String? metaDescription,
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
      productType: productType ?? this.productType,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      stockStatus: stockStatus ?? this.stockStatus,
      salePrice: salePrice ?? this.salePrice,
      saleStartDate: saleStartDate ?? this.saleStartDate,
      saleEndDate: saleEndDate ?? this.saleEndDate,
      badges: badges ?? this.badges,
      author: author ?? this.author,
      videoUrl: videoUrl ?? this.videoUrl,
      audioSampleUrl: audioSampleUrl ?? this.audioSampleUrl,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      shippingClass: shippingClass ?? this.shippingClass,
      keyHighlights: keyHighlights ?? this.keyHighlights,
      aboutItem: aboutItem ?? this.aboutItem,
      variants: variants ?? this.variants,
      digitalFileUrl: digitalFileUrl ?? this.digitalFileUrl,
      downloadLimit: downloadLimit ?? this.downloadLimit,
      eventId: eventId ?? this.eventId,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
    );
  }
}
