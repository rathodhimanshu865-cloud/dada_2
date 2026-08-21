class ProductVariant {
  final String id;
  final String name;
  final String format; // Paperback, Hardcover, PDF, Audio CD, MP3
  final String language; // Gujarati, Hindi, English
  final String size; // For apparel
  final String bundleSize; 
  final double? price; // Override price
  final int stockQuantity;
  final String sku;
  final String imageUrl;

  ProductVariant({
    this.id = '',
    this.name = '',
    this.format = '',
    this.language = '',
    this.size = '',
    this.bundleSize = '',
    this.price,
    this.stockQuantity = 0,
    this.sku = '',
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'format': format,
      'language': language,
      'size': size,
      'bundleSize': bundleSize,
      'price': price,
      'stockQuantity': stockQuantity,
      'sku': sku,
      'imageUrl': imageUrl,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      format: map['format'] ?? '',
      language: map['language'] ?? '',
      size: map['size'] ?? '',
      bundleSize: map['bundleSize'] ?? '',
      price: map['price']?.toDouble(),
      stockQuantity: map['stockQuantity']?.toInt() ?? 0,
      sku: map['sku'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
