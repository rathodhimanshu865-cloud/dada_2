import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id;
  final String code;
  final String discountType; // 'percentage' or 'flat'
  final double discountValue;
  final double minOrderValue;
  final int usageLimitPerUser;
  final String terms;
  final String termsHi;
  final String termsGu;
  final bool isActive;
  final DateTime? createdAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.usageLimitPerUser = 2,
    this.terms = 'Maximum 2 uses per devotee.',
    this.termsHi = '',
    this.termsGu = '',
    this.isActive = true,
    this.createdAt,
  });

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CouponModel(
      id: doc.id,
      code: data['code'] ?? '',
      discountType: data['discountType'] ?? 'flat',
      discountValue: (data['discountValue'] ?? 0.0).toDouble(),
      minOrderValue: (data['minOrderValue'] ?? 0.0).toDouble(),
      usageLimitPerUser: data['usageLimitPerUser'] ?? 2,
      terms: data['terms'] ?? 'Maximum 2 uses per devotee.',
      termsHi: data['termsHi'] ?? '',
      termsGu: data['termsGu'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code.toUpperCase(),
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'usageLimitPerUser': usageLimitPerUser,
      'terms': terms,
      'termsHi': termsHi,
      'termsGu': termsGu,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  String localizedTerms(String langCode) {
    if (langCode == 'hi' && termsHi.isNotEmpty) return termsHi;
    if (langCode == 'gu' && termsGu.isNotEmpty) return termsGu;
    return terms;
  }
}
