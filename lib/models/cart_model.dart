import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => (product.price ?? 0) * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
      // Store current snapshot of product data in case it changes
      'productTitle': product.title,
      'productPrice': product.price,
      'productImage': product.images.isNotEmpty ? product.images.first : '',
    };
  }
}
