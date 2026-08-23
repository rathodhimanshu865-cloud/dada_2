class ProductModel {
  final String id;
  final String title;
  final String category;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final bool isNew;

  ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    this.originalPrice = 0.0,
    required this.imageUrl,
    this.isNew = false,
  });
}
