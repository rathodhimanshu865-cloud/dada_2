import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/store_config_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store Branding
  Stream<StoreConfigModel> getStoreConfig() {
    return _firestore
        .collection('storeConfig')
        .doc('settings')
        .snapshots()
        .map((snapshot) => StoreConfigModel.fromFirestore(snapshot));
  }

  // Categories
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  // Featured Products
  Stream<List<ProductModel>> getFeaturedProducts({int limit = 10}) {
    return _firestore
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Latest Products
  Stream<List<ProductModel>> getLatestProducts({int limit = 10}) {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Popular Products
  Stream<List<ProductModel>> getPopularProducts({int limit = 10}) {
    // Ordering by salesCount descending
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .orderBy('salesCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Search Products (Prefix Search)
  Future<List<ProductModel>> searchProducts(String queryText) async {
    if (queryText.isEmpty) return [];
    
    String searchKey = queryText.toLowerCase();
    final snapshot = await _firestore
        .collection('products')
        .where('name_lowercase', isGreaterThanOrEqualTo: searchKey)
        .where('name_lowercase', isLessThanOrEqualTo: '$searchKey\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }
}
