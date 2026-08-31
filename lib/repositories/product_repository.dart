import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/store_config_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Store Branding
  Stream<StoreConfigModel> getStoreConfig() {
    return _firestore
        .collection('storeConfig')
        .doc('settings')
        .snapshots()
        .map((snapshot) => StoreConfigModel.fromFirestore(snapshot));
  }

  Future<void> updateStoreConfig(StoreConfigModel config) async {
    await _firestore
        .collection('storeConfig')
        .doc('settings')
        .set(config.toFirestore(), SetOptions(merge: true));
  }

  Future<String> uploadStoreLogo(File imageFile) async {
    final ref = _storage.ref().child('store_assets').child('logo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
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

  // Admin: Get all products (including inactive)
  Stream<List<ProductModel>> getAdminProducts() {
    return _firestore.collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // All Products Stream (Public)
  Stream<List<ProductModel>> getAllProductsStream({int limit = 100}) {
    return _firestore.collection('products')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }

  // Paginated All Products
  Future<List<ProductModel>> getAllProducts({DocumentSnapshot? startAfter, int limit = 20}) async {
    Query query = _firestore.collection('products').limit(limit);
    
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
        .where('nameLower', isGreaterThanOrEqualTo: searchKey)
        .where('nameLower', isLessThanOrEqualTo: '$searchKey\uf8ff')
        .limit(100)
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
    int limit = 100 // Increased default limit to 100
  }) async {
    Query query = _firestore.collection('products');

    if (categoryId != null && categoryId != 'All Sacred Products' && categoryId != 'all' && categoryId.isNotEmpty) {
      // Normalize to match how it's stored in ProductModel.toFirestore
      final normalizedId = categoryId.toLowerCase().trim();
      query = query.where('categoryId', isEqualTo: normalizedId);
    }
    
    // User wants to see EVERYTHING they add from admin side.
    // So we don't filter by isActive here.

    if (onlyInStock) {
      query = query.where('stock', isGreaterThan: 0);
    }

    // Apply Sort
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

  // --- Admin CRUD Operations ---

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).set(product.toFirestore());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).update(product.toUpdateFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    // Delete Firestore document
    await _firestore.collection('products').doc(productId).delete();
    
    // Delete images from Storage
    try {
      final listResult = await _storage.ref().child('product_images').child(productId).listAll();
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      debugPrint("Error deleting product images: $e");
    }
  }

  Future<String> uploadProductImage(File imageFile, String productId) async {
    final ref = _storage.ref().child('product_images').child(productId).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  UploadTask getUploadTask(File imageFile, String productId) {
    final ref = _storage.ref().child('product_images').child(productId).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    return ref.putFile(imageFile);
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint("Error deleting image from storage: $e");
    }
  }

  // Category CRUD
  Future<void> addCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).set(category.toFirestore());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).update(category.toFirestore());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  Future<bool> hasProductsInCategory(String categoryId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // --- Maintenance & Migrations ---
  Future<void> migrateCategory(String oldId, String newId) async {
    final batch = _firestore.batch();
    
    // 1. Get old category data
    final oldCatDoc = await _firestore.collection('categories').doc(oldId).get();
    if (!oldCatDoc.exists) return;
    
    // 2. Create new category with same data
    final data = oldCatDoc.data()!;
    batch.set(_firestore.collection('categories').doc(newId), data);
    
    // 3. Find and update all products
    final productsSnap = await _firestore.collection('products')
        .where('categoryId', isEqualTo: oldId)
        .get();
        
    for (var doc in productsSnap.docs) {
      batch.update(doc.reference, {'categoryId': newId});
    }
    
    // 4. Delete old category
    batch.delete(oldCatDoc.reference);
    
    await batch.commit();
  }
}
