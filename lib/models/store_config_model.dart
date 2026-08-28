import 'package:cloud_firestore/cloud_firestore.dart';

class StoreConfigModel {
  final String logoUrl;
  final String storeName;
  final String storeDescription;
  final String bannerUrl;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String facebookUrl;
  final String instagramUrl;
  final String twitterUrl;
  final double deliveryCharge;
  final double freeDeliveryThreshold;
  final bool enableCOD;

  StoreConfigModel({
    this.logoUrl = '',
    this.storeName = 'Dada Store',
    this.storeDescription = '',
    this.bannerUrl = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.address = '',
    this.facebookUrl = '',
    this.instagramUrl = '',
    this.twitterUrl = '',
    this.deliveryCharge = 0.0,
    this.freeDeliveryThreshold = 0.0,
    this.enableCOD = true,
  });

  factory StoreConfigModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return StoreConfigModel();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoreConfigModel(
      logoUrl: data['logoUrl'] ?? '',
      storeName: data['storeName'] ?? 'Dada Store',
      storeDescription: data['storeDescription'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      address: data['address'] ?? '',
      facebookUrl: data['facebookUrl'] ?? '',
      instagramUrl: data['instagramUrl'] ?? '',
      twitterUrl: data['twitterUrl'] ?? '',
      deliveryCharge: (data['deliveryCharge'] ?? 0.0).toDouble(),
      freeDeliveryThreshold: (data['freeDeliveryThreshold'] ?? 0.0).toDouble(),
      enableCOD: data['enableCOD'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'logoUrl': logoUrl,
      'storeName': storeName,
      'storeDescription': storeDescription,
      'bannerUrl': bannerUrl,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'twitterUrl': twitterUrl,
      'deliveryCharge': deliveryCharge,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'enableCOD': enableCOD,
    };
  }
}
