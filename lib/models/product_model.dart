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
  List<Map<String, dynamic>> addOns;
  
  // Mantra fields
  String? mantraText;
  String? mantraTransliteration;
  String? mantraSignificance;
  String? mantraAudioUrl;

  // Tab content fields
  Map<String, String> specifications;
  List<String> careInstructions;
  List<Map<String, String>> faqs;

  // Bundle / cross-sell fields
  List<String> bundleProductSlugs; // slugs of companion products in the bundle
  double bundleDiscountPercent;    // e.g. 15.0 = 15% off when buying the complete set

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
    List<Map<String, dynamic>>? addOns,
    this.mantraText,
    this.mantraTransliteration,
    this.mantraSignificance,
    this.mantraAudioUrl,
    Map<String, String>? specifications,
    List<String>? careInstructions,
    List<Map<String, String>>? faqs,
    List<String>? bundleProductSlugs,
    this.bundleDiscountPercent = 0,
  })  : images = images ?? [],
        badges = badges ?? [],
        keyHighlights = keyHighlights ?? [],
        variants = variants ?? [],
        addOns = addOns ?? [],
        specifications = specifications ?? {},
        careInstructions = careInstructions ?? [],
        faqs = faqs ?? [],
        bundleProductSlugs = bundleProductSlugs ?? [];

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
      'addOns': addOns,
      'mantraText': mantraText,
      'mantraTransliteration': mantraTransliteration,
      'mantraSignificance': mantraSignificance,
      'mantraAudioUrl': mantraAudioUrl,
      'specifications': specifications,
      'careInstructions': careInstructions,
      'faqs': faqs,
      'bundleProductSlugs': bundleProductSlugs,
      'bundleDiscountPercent': bundleDiscountPercent,
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
      addOns: List<Map<String, dynamic>>.from(map['addOns'] ?? []),
      mantraText: map['mantraText'],
      mantraTransliteration: map['mantraTransliteration'],
      mantraSignificance: map['mantraSignificance'],
      mantraAudioUrl: map['mantraAudioUrl'],
      specifications: map['specifications'] != null
          ? Map<String, String>.from(
              (map['specifications'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
          : {},
      careInstructions: map['careInstructions'] != null
          ? List<String>.from(map['careInstructions'])
          : [],
      faqs: map['faqs'] != null
          ? List<Map<String, String>>.from(
              (map['faqs'] as List).map((e) =>
                Map<String, String>.from((e as Map).map((k, v) => MapEntry(k.toString(), v.toString())))))
          : [],
      bundleProductSlugs: List<String>.from(map['bundleProductSlugs'] ?? []),
      bundleDiscountPercent: (map['bundleDiscountPercent'] ?? 0).toDouble(),
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
    List<Map<String, dynamic>>? addOns,
    String? mantraText,
    String? mantraTransliteration,
    String? mantraSignificance,
    String? mantraAudioUrl,
    Map<String, String>? specifications,
    List<String>? careInstructions,
    List<Map<String, String>>? faqs,
    List<String>? bundleProductSlugs,
    double? bundleDiscountPercent,
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
      addOns: addOns ?? this.addOns,
      mantraText: mantraText ?? this.mantraText,
      mantraTransliteration: mantraTransliteration ?? this.mantraTransliteration,
      mantraSignificance: mantraSignificance ?? this.mantraSignificance,
      mantraAudioUrl: mantraAudioUrl ?? this.mantraAudioUrl,
      specifications: specifications ?? this.specifications,
      careInstructions: careInstructions ?? this.careInstructions,
      faqs: faqs ?? this.faqs,
      bundleProductSlugs: bundleProductSlugs ?? this.bundleProductSlugs,
      bundleDiscountPercent: bundleDiscountPercent ?? this.bundleDiscountPercent,
    );
  }
}
