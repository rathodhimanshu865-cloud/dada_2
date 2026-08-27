import 'package:cloud_firestore/cloud_firestore.dart';

class StoreConfigModel {
  final String logoUrl;
  final String storeName;
  final String bannerUrl;

  StoreConfigModel({
    this.logoUrl = '',
    this.storeName = 'Dada Store',
    this.bannerUrl = '',
  });

  factory StoreConfigModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return StoreConfigModel();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoreConfigModel(
      logoUrl: data['logoUrl'] ?? '',
      storeName: data['storeName'] ?? 'Dada Store',
      bannerUrl: data['bannerUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'logoUrl': logoUrl,
      'storeName': storeName,
      'bannerUrl': bannerUrl,
    };
  }
}
