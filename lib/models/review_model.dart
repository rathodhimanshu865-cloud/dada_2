import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userCity;
  final double rating;
  final String title;
  final String body;
  final bool verifiedPurchase;
  final List<String> photos;
  final int helpfulVotes;
  final DateTime? createdAt;
  final bool isApproved;

  Review({
    this.id = '',
    required this.productId,
    required this.userId,
    this.userName = '',
    this.userCity = '',
    required this.rating,
    this.title = '',
    this.body = '',
    this.verifiedPurchase = false,
    this.photos = const [],
    this.helpfulVotes = 0,
    this.createdAt,
    this.isApproved = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userCity': userCity,
      'rating': rating,
      'title': title,
      'body': body,
      'verifiedPurchase': verifiedPurchase,
      'photos': photos,
      'helpfulVotes': helpfulVotes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isApproved': isApproved,
    };
  }

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    return Review(
      id: id,
      productId: map['productId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userCity: map['userCity'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      verifiedPurchase: map['verifiedPurchase'] ?? false,
      photos: List<String>.from(map['photos'] ?? []),
      helpfulVotes: map['helpfulVotes']?.toInt() ?? 0,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      isApproved: map['isApproved'] ?? true,
    );
  }
}
