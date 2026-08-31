import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String productName;
  final String userId;
  final String userName;
  final String userPhone;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    this.productName = '',
    required this.userId,
    required this.userName,
    this.userPhone = '',
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Devotee',
      userPhone: data['userPhone'] ?? '',
      rating: double.tryParse(data['rating']?.toString() ?? '0.0') ?? 0.0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
