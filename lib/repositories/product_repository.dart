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

  // Paginated All Products
  Future<List<ProductModel>> getAllProducts({DocumentSnapshot? startAfter, int limit = 20}) async {
    Query query = _firestore.collection('products')
        .where('isActive', isEqualTo: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  // Featured Products
  Stream<List<ProductModel>> getFeaturedProducts({int limit = 10}) {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Latest Products
  Stream<List<ProductModel>> getLatestProducts({int limit = 10}) {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Products by Category
  Stream<List<ProductModel>> getProductsByCategory(String categoryId, {int limit = 20}) {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Popular Products
  Stream<List<ProductModel>> getPopularProducts({int limit = 10}) {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('salesCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Search Products (Prefix Search using nameLower)
  Future<List<ProductModel>> searchProducts(String queryText) async {
    if (queryText.isEmpty) return [];
    
    String searchKey = queryText.toLowerCase();
    final snapshot = await _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('nameLower', isGreaterThanOrEqualTo: searchKey)
        .where('nameLower', isLessThanOrEqualTo: '$searchKey\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  // Filtered & Sorted Products
  Future<List<ProductModel>> getFilteredProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool onlyInStock = false,
    String sortBy = 'createdAt', // 'price', 'name', 'createdAt'
    bool descending = true,
    int limit = 20
  }) async {
    Query query = _firestore.collection('products').where('isActive', isEqualTo: true);

    if (categoryId != null && categoryId != 'All Sacred Products') {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (onlyInStock) {
      query = query.where('stock', isGreaterThan: 0);
    }

    // Sort
    query = query.orderBy(sortBy, descending: descending);

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  // Single Product Details
  Stream<ProductModel?> getProductDetails(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .snapshots()
        .map((snapshot) => snapshot.exists ? ProductModel.fromFirestore(snapshot) : null);
  }
}
