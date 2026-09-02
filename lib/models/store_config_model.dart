import 'package:cloud_firestore/cloud_firestore.dart';

class StoreConfigModel {
  final String logoUrl;
  final String storeName;
  final String storeNameHi;
  final String storeNameGu;
  final String storeDescription;
  final String storeDescriptionHi;
  final String storeDescriptionGu;
  final String bannerUrl;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String addressHi;
  final String addressGu;
  final String facebookUrl;
  final String instagramUrl;
  final String twitterUrl;
  final double deliveryCharge;
  final double freeDeliveryThreshold;
  final bool enableCOD;

  StoreConfigModel({
    this.logoUrl = '',
    this.storeName = 'Dada Store',
    this.storeNameHi = '',
    this.storeNameGu = '',
    this.storeDescription = '',
    this.storeDescriptionHi = '',
    this.storeDescriptionGu = '',
    this.bannerUrl = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.address = '',
    this.addressHi = '',
    this.addressGu = '',
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
      storeNameHi: data['storeNameHi'] ?? '',
      storeNameGu: data['storeNameGu'] ?? '',
      storeDescription: data['storeDescription'] ?? '',
      storeDescriptionHi: data['storeDescriptionHi'] ?? '',
      storeDescriptionGu: data['storeDescriptionGu'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      address: data['address'] ?? '',
      addressHi: data['addressHi'] ?? '',
      addressGu: data['addressGu'] ?? '',
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
      'storeNameHi': storeNameHi,
      'storeNameGu': storeNameGu,
      'storeDescription': storeDescription,
      'storeDescriptionHi': storeDescriptionHi,
      'storeDescriptionGu': storeDescriptionGu,
      'bannerUrl': bannerUrl,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address,
      'addressHi': addressHi,
      'addressGu': addressGu,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'twitterUrl': twitterUrl,
      'deliveryCharge': deliveryCharge,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'enableCOD': enableCOD,
    };
  }

  String localizedStoreName(String langCode) {
    if (langCode == 'hi' && storeNameHi.isNotEmpty) return storeNameHi;
    if (langCode == 'gu' && storeNameGu.isNotEmpty) return storeNameGu;
    return storeName;
  }

  String localizedStoreDescription(String langCode) {
    if (langCode == 'hi' && storeDescriptionHi.isNotEmpty) return storeDescriptionHi;
    if (langCode == 'gu' && storeDescriptionGu.isNotEmpty) return storeDescriptionGu;
    return storeDescription;
  }

  String localizedAddress(String langCode) {
    if (langCode == 'hi' && addressHi.isNotEmpty) return addressHi;
    if (langCode == 'gu' && addressGu.isNotEmpty) return addressGu;
    return address;
  }
}
