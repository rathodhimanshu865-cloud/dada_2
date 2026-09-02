import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String productName;
  final String productNameHi;
  final String productNameGu;
  final double price;
  final String imageUrl;
  int quantity;
  final DateTime addedAt;

  CartItem({
    required this.productId,
    required this.productName,
    this.productNameHi = '',
    this.productNameGu = '',
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.addedAt,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartItem(
      productId: doc.id,
      productName: data['productName'] ?? '',
      productNameHi: data['productNameHi'] ?? '',
      productNameGu: data['productNameGu'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productName': productName,
      'productNameHi': productNameHi,
      'productNameGu': productNameGu,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'addedAt': addedAt,
    };
  }

  String localizedProductName(String langCode) {
    if (langCode == 'hi' && productNameHi.isNotEmpty) return productNameHi;
    if (langCode == 'gu' && productNameGu.isNotEmpty) return productNameGu;
    return productName;
  }
}
