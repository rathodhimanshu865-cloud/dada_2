import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String productTitle;
  final double price;
  final int quantity;
  final String image;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productTitle: map['productTitle'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      image: map['image'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String shippingAddress;
  final String contactNumber;
  final String paymentStatus; // 'pending', 'paid', 'failed'
  final String orderStatus; // 'processing', 'shipped', 'delivered', 'cancelled'
  final DateTime createdAt;
  final String razorpayOrderId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.contactNumber,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    required this.razorpayOrderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'contactNumber': contactNumber,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'razorpayOrderId': razorpayOrderId,
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List? ?? []).map((i) => OrderItem.fromMap(i)).toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      shippingAddress: map['shippingAddress'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      orderStatus: map['orderStatus'] ?? 'processing',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      razorpayOrderId: map['razorpayOrderId'] ?? '',
    );
  }
}
