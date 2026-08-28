import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String role;
  final DateTime? createdAt;
  final bool isActive;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage = '',
    this.role = 'user',
    this.createdAt,
    this.isActive = true,
    this.address,
    this.city,
    this.state,
    this.pincode,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      address: data['address'],
      city: data['city'],
      state: data['state'],
      pincode: data['pincode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'isActive': isActive,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
