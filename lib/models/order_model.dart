import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final String? couponCode;
  final double tax;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? note;
  final String? trackingCarrier;
  final String? trackingId;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    this.couponCode,
    required this.tax,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.createdAt,
    this.updatedAt,
    this.note,
    this.trackingCarrier,
    this.trackingId,
  });

  OrderModel copyWith({
    String? orderStatus,
    String? paymentStatus,
    String? trackingCarrier,
    String? trackingId,
  }) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      customerName: customerName,
      phone: phone,
      email: email,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      items: items,
      subtotal: subtotal,
      deliveryCharge: deliveryCharge,
      discount: discount,
      couponCode: couponCode,
      tax: tax,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      note: note,
      trackingCarrier: trackingCarrier ?? this.trackingCarrier,
      trackingId: trackingId ?? this.trackingId,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId: doc.id,
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryCharge: (data['deliveryCharge'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      couponCode: data['couponCode'],
      tax: (data['tax'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      orderStatus: data['orderStatus'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      note: data['note'],
      trackingCarrier: data['trackingCarrier'],
      trackingId: data['trackingId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'customerName': customerName,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'items': items,
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'discount': discount,
      'couponCode': couponCode,
      'tax': tax,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'note': note,
      'trackingCarrier': trackingCarrier,
      'trackingId': trackingId,
    };
  }
}
